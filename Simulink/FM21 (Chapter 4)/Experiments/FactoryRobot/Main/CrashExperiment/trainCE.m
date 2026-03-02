function [trainingStatsUnsafe,trainingStatsSafe] = trainCE(numOpps,episodes,stepsPerEpisode,simParameters)
    % #############################################################
    %                      prepare environment
    % #############################################################

    environmentObservationInfo = rlNumericSpec([4+4*numOpps,1]);
    % inputMapping for shielding
    if(numOpps == 2)
        mapping = @inputMapping2Opps;
    elseif(numOpps == 6)
        mapping = @inputMapping6Opps;
    else
        ME = MException('Invalid number of opponents', 'valid numbers are 2 and 6');
        throw(ME)
    end
    mdl = ['RLFactoryEnforceCrash' int2str(numOpps) 'Opponents'];
    monitorPath = ['SafeRLMonitorFor' int2str(numOpps) 'Robots.c'];
    %Actions for the RL agent
    agentActionInfo = createAgentActionInfo([0.5,1,1.5,2]);
    %opens graphical representation of the model
    open_system(mdl);
    % prepare environment with environment observations
    env = rlSimulinkEnv(mdl,[mdl '/RLService' int2str(numOpps) 'RLRobot/RLService' int2str(numOpps) 'RLAgent/RL Agent'],...
        environmentObservationInfo,agentActionInfo);


    % #############################################################
    %                      Settings for RL-agent
    % #############################################################
    %creates Critic and set options
    critic = rlQValueRepresentation({@(obs,a) dummyFunction(obs,a),rand([1 1])},...
        environmentObservationInfo,agentActionInfo);
    agentOpts = rlQAgentOptions;
    agentOpts.SampleTime = simParameters{1};%TSRL
    agentOpts.EpsilonGreedyExploration.Epsilon = 1;
    agentOpts.EpsilonGreedyExploration.EpsilonMin = 1;

    %creates safe and unsafe agents
    %safeAgent = SafeRLQAgent(critic,agentOpts, ...
    %    monitorPath, mapping, simParameters);
    % Note: Due to copyright restrictions, the full implementation of the
    % SafeRLQAgent used in these experiments cannot be shared. The file
    % SafeRLQAgent.m still illustrates the key concepts, such as loading
    % monitors and filtering actions for safety, for reference. 
    unsafeAgent = rlQAgent(critic,agentOpts);

    % #############################################################
    %                      Run Simulation
    % #############################################################
    disp(['simulating with ' int2str(numOpps) ' opponents']);
    trainOpts = rlTrainingOptions;
    trainOpts.MaxStepsPerEpisode = stepsPerEpisode;
    trainOpts.StopTrainingCriteria = "EpisodeCount";
    trainOpts.StopTrainingValue = episodes;
    trainOpts.MaxEpisodes = episodes;

    %Train unsafe and safe agents
    qAgent=unsafeAgent;
    startUnsafe = tic;
        trainingStatsUnsafe = train(qAgent,env,trainOpts);
    time = toc(startUnsafe);
    disp(append('training unsafe agent with ', int2str(numOpps),' opponents took ', string(time), ' seconds'));
    %disp(append('average RL time unsafe agent with ', int2str(numOpps),' opponents: ', string(qAgent.timeRunTrain/qAgent.timesCalled), ' seconds'));

    %qAgent=safeAgent;
    %startSafe = tic;
    %    trainingStatsSafe = train(qAgent,env,trainOpts);
    %time = toc(startSafe);
    %disp(append('training safe agent with ', int2str(numOpps),' opponents took ', string(time), ' seconds'));
    %disp(append('average RL time safe agent with ', int2str(numOpps),' opponents: ', string(qAgent.timeRunTrain/qAgent.timesCalled), ' seconds'));
    trainingStatsSafe=0; % return 0 for unused agent 
end



