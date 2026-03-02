% file for results
fileID=fopen(ids,'w');
fprintf(fileID,'key,value\r\n');
fprintf(fileID,'tmax,%d\r\n',maxTime);

% convert maxTime to RL steps
steps = ceil(maxTime/10);
maxSteps = steps;
% cost scales with maxTime
maxCost = maxTime*0.225;

doTraining = true;  % true -> train agent
doSim = true;      % true -> sim agent after training
loadAgent = false;  % true -> load agent from "loadAgentName.mat" file
saveAgent = false;   % true -> save agent as "saveAgentName.mat" file"
reuseAgent = false;  % true -> reuse agent if already in workspace, disables 'loadagent'

mdl= "WaterDistSystem";
open_system(mdl);


if reuseAgent && exist('qAgent','var') && exist('obsInfo','var') && exist('actInfo','var') && exist('env','var')
    disp('reusing previous agent');
else
    % ################ CREATE ACTION AND OBSERVATION INFO ############
    disp("creating observation and action info")
    obsInfo = rlNumericSpec([5 1]) ; % continuous observation space
    actInfo = createAgentActionInfo(supFull, supDeg, supNo);

    % ################ CREATE RL ENVIRONMENT ############
    disp("creating environment")
    agentBlk= mdl + "/Monitored Agent/RL Agent";
    env = rlSimulinkEnv(mdl,agentBlk,obsInfo,actInfo);
   
    env.ResetFcn = @(in) resetEnv(in,mdl);


    % ################ CREATE RL AGENT ############
    if loadAgent % load agent from file
        disp('loading agent');
        if useDQN
            load("WDSDQNAgent.mat","qAgent");
        else
            load("WDSQTableAgent.mat","qAgent");
        end
    else % create new agent
        disp('creating new DQN agent');
        qAgent=createAgent(512, obsInfo, actInfo, true, sampleTime);
        critic=qAgent.getCritic();
    end
end 




% sanity check
if isequal(class(qAgent),'rl.agent.rlDQNAgent')
    disp("using rlDQNAgent");
elseif isequal(class(qAgent),'rl.agent.rlQAgent')
    disp("using Q-Table agent");
else
    disp("WARNING: using unknown agent");
end

% ################ TRAIN AGENT ############
if doTraining
    disp("starting training");
    trainOpts = rlTrainingOptions;
    if singleReward == 1
        trainOpts.StopTrainingValue = 1;
    else
        trainOpts.StopTrainingValue = maxSteps;
    end
    trainOpts.MaxStepsPerEpisode = maxSteps;
    trainOpts.MaxEpisodes= runs;
    trainOpts.StopTrainingCriteria = "AverageReward";
    trainOpts.ScoreAveragingWindowLength = 100;
    trainOpts.UseParallel = true;
    % Train the agent.
    tic
    trainingStats = train(qAgent,env,trainOpts);
    disp("training done");
    trainRuns =max(trainingStats.EpisodeIndex);
    fprintf(fileID,'trainruns,%d\r\n',trainRuns);
    trainTime=toc
    fprintf(fileID,'traintime,%6.6f\r\n',trainTime);
    % ### SAVE AGENT AFTER TRAINING ###
    if saveAgent
        disp("saving agent");
        if useDQN
            save("WDSDQNAgent.mat","qAgent");
        else
            save("WDSQTableAgent.mat","qAgent");
        end
    end
end

% ################ SIMULATE TRAINED AGENT ############
if doSim
    disp("simulating trained agent");
    runSimulations;
end

function agent= createAgent(hiddenUnits, obsInfo, actInfo, safe, sampleTime)

    inputLayer = [
        featureInputLayer(obsInfo.Dimension(1),"Name","obs")];

    fullReluLayer1 = [
        fullyConnectedLayer(hiddenUnits,"Name","full1")
        reluLayer("Name","relu_1")];

    fullReluLayer2 = [
        fullyConnectedLayer(hiddenUnits,"Name","full2")
        reluLayer("Name","relu_2")];

    outputLayer = [
          fullyConnectedLayer(length(actInfo.Elements),"Name","out")];

    lgraph = layerGraph(inputLayer);
    lgraph = addLayers(lgraph,fullReluLayer1);
    lgraph = addLayers(lgraph,fullReluLayer2);
    lgraph = addLayers(lgraph,outputLayer);

    lgraph = connectLayers(lgraph,"obs","full1");
    lgraph = connectLayers(lgraph,"relu_1","full2");
    lgraph = connectLayers(lgraph,"relu_2","out");

    net = dlnetwork(lgraph);
    plot(net);

    dnn = initialize(net);
    if(safe)
        critic = createSafeVectorQValueFunction(dnn, obsInfo, actInfo, {@ shieldWDSWOBFull, @ shieldWDSWOBDeg, @ shieldWDSWOBNo} );
    else
         critic = rlVectorQValueFunction(dnn,obsInfo,actInfo);
    end
    agent = rlDQNAgent(critic);

    agent.AgentOptions.CriticOptimizerOptions.LearnRate = 1e-5;
    
    agent.AgentOptions.DiscountFactor = 1;
    agent.AgentOptions.SampleTime = sampleTime;
    
    agent.AgentOptions.TargetSmoothFactor = 0.005;
    
    agent.AgentOptions.MiniBatchSize = 512;
    
    agent.AgentOptions.EpsilonGreedyExploration.Epsilon     = 1.0;   % start fully random
    agent.AgentOptions.EpsilonGreedyExploration.EpsilonMin  = 0.001;  % near-greedy
    
    agent.AgentOptions.UseDoubleDQN = true;
    
    agent.AgentOptions.ExperienceBufferLength = 100000; 
end
