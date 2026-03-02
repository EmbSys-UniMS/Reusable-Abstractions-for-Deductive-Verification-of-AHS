% #############################################################
% script for the function approximation learning experiment
% trains and simulates a safe or unsafe (depending on value of safe) Q
% learning agent with the case study model
% #############################################################

setSimulationVariables;

% Train with a safe agent? true | false
safe=false;

% Settings for JobScheduler goals and initial positions
GOALSRL=[[-5;5],[6;5],[-5;-5],[6;-5]];

GOALSA=[[0;12],[0;8],[0;-8],[0;-12]];
INITAX=[0,0];
INITAY=[-12,12];

GOALSB=[[1;12],[1;8],[1;-8],[1;-12]];
INITBX=[1,1];
INITBY=[-12,12];

% #############################################################
%                      prepare environment
% #############################################################

environmentObservationInfo = rlNumericSpec([12,1]);
mdl = 'RLFactory';
agentActionInfo = createAgentActionInfo([0.5,1,1.5,2]);

open_system(mdl);
% prepare environment with environment observationscrashes
env = rlSimulinkEnv(mdl,[mdl '/RLServiceRLRobot/RLServiceRLAgent/RL Agent'],...
    environmentObservationInfo,agentActionInfo);


% #############################################################
%                      Settings for RL-agent
% #############################################################

%creates qAgent and Critic
critic = rlQValueRepresentation({@(obs,a) basisFunction(obs,a),rand([6 1])},...
    environmentObservationInfo,agentActionInfo);
agentOpts = rlQAgentOptions;
agentOpts.SampleTime = TSRL;

if(false) % if(safe)
    disp('RL with safe agent');
    % qAgent = SafeRLQAgent(critic,agentOpts, ...
    %     'SafeRLMonitorFor2Robots.c', ...
    %     @inputMapping2Opps, simParameters);
    % Note: Due to copyright restrictions, the full implementation of the
    % SafeRLQAgent used in these experiments cannot be shared. The file
    % SafeRLQAgent.m still illustrates the key concepts, such as loading
    % monitors and filtering actions for safety, for reference.
else
    disp('RL with default agent');
    qAgent = rlQAgent(critic,agentOpts);
end

% #############################################################
%                      Run Simulation
% #############################################################

maxEpisodesTraining = 250;
maxStepsTraining = 120;
maxStepsSim = 100000;

%RL training settings
trainOpts = rlTrainingOptions;
trainOpts.MaxStepsPerEpisode = maxStepsTraining;
trainOpts.StopTrainingCriteria = "EpisodeCount";
trainOpts.StopTrainingValue = maxEpisodesTraining;
trainOpts.MaxEpisodes = maxEpisodesTraining;
agentOpts.EpsilonGreedyExploration.Epsilon = 0.25;
agentOpts.EpsilonGreedyExploration.EpsilonMin = 0.001;
disp(['training for ' int2str(trainOpts.MaxEpisodes) ' episodes with ' int2str(maxStepsTraining) ' steps']);
%train the agent in the simulated environment
trainingStart = tic;
    trainingStats = train(qAgent,env,trainOpts);
trainingtime = toc(trainingStart);
disp(["time for training: "; trainingtime;" seconds"]); 

% used for comparing average time spent in RL loop for the two agents
% averageRLTime = qAgent.timeRunTrain/qAgent.timesCalled;
% disp(["averageRLLoopTime "; averageRLTime;" seconds"]); 

opt = rlSimulationOptions('MaxSteps',maxStepsSim);

disp(['running sim for ' int2str(maxStepsSim) ' steps']);
%run the agent in the simulated environment
simStart = tic;
    result = sim(qAgent,env,opt);
simtime = toc(simStart);
disp(["time for simulation: "; simtime;" seconds"]); 

crashesTraining = countCrashes(trainingStats);
goalsReached = result.SimulationInfo.Arrived;
timesBelowThreshold = result.SimulationInfo.BelowThresh;
crashesSim = result.SimulationInfo.Crash;

disp(["Crashes training: "; crashesTraining]);
disp(["Crashes simulation: "; crashesSim]);
disp(["GoalsReached: "; goalsReached]);
disp(["TimesBelowThreshold: "; timesBelowThreshold]);

visualizeResult(result.SimulationInfo,maxStepsSim);
