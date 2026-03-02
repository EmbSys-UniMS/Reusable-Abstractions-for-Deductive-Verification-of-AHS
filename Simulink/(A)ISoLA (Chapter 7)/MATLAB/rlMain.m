% file for results
fileID=fopen(ids,'w');
fprintf(fileID,'key,value\r\n');
fprintf(fileID,'tmax,%d\r\n',maxTime);

% convert maxTime to RL steps
steps = ceil(maxTime/10);
maxSteps = steps;
% cost scales with maxTime
maxCost = maxTime*0.225;

% unused:
RewardSafety=0;
RewardCost=0;
PenaltySafety=0;
PenaltyCost=0;

runs=5000;
useParallel=false;

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
    if useDQN 
        obsInfo = rlNumericSpec([8 1]) ; % continuous observation space
    else
        obsInfo = createDiscreteObservationInfo(); % observations for Q-Table
    end
    actInfo = createAgentActionInfo();

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
        if useDQN 
            disp('creating new DQN agent');
            initOpts = rlAgentInitializationOptions(NumHiddenUnit=512); % double NumHiddenUnits
            qAgent = rlDQNAgent(obsInfo,actInfo,initOpts); % default DQN agent
            critic = getCritic(qAgent);
            criticNet = getModel(critic);
            plot(criticNet);

            qAgent.AgentOptions.SampleTime=10;
            qAgent.AgentOptions.MiniBatchSize=256;
            qAgent.AgentOptions.ExperienceBufferLength=100000;
        else
            disp('creating new Q-Table agent');
            qAgent = createQTableLearningAgent(obsInfo, actInfo);
        end
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
    if useDQN
        trainOpts.UseParallel = useParallel;
    end
    % Train the agent.
    tic
    trainingStats = train(qAgent,env,trainOpts);
    disp("training done");
    trainRuns=max(trainingStats.EpisodeIndex)
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
