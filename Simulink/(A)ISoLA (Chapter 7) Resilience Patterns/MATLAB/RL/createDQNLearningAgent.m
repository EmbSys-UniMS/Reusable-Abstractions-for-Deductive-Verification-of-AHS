% ##########################################################
% creates a set of possible actions for a given velocity
% ##########################################################
function qAgent  = createDQNLearningAgent(obsInfo, actInfo)
qAgent = rlDQNAgent(obsInfo,actInfo); %default DQN agent

    qAgent.AgentOptions.EpsilonGreedyExploration.Epsilon = .15;
    qAgent.AgentOptions.CriticOptimizerOptions.LearnRate = 0.1;
    qAgent.AgentOptions.SampleTime = 10;
    qAgent.AgentOptions.DiscountFactor = 0.95;
end