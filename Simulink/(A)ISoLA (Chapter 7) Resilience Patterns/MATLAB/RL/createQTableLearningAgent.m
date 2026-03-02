% ##########################################################
% creates a set of possible actions for a given velocity
% ##########################################################
function qAgent  = createQTableLearningAgent(obsInfo, actInfo)
    if ~exist('qTable','var')
        qTable = rlTable(obsInfo,actInfo);
    end
    
    critic = rlQValueFunction(qTable,obsInfo,actInfo);
    qAgent = rlQAgent(critic);

    qAgent.AgentOptions.EpsilonGreedyExploration.Epsilon = .15;
    qAgent.AgentOptions.CriticOptimizerOptions.LearnRate = 0.1;
    qAgent.AgentOptions.SampleTime = 10;
    qAgent.AgentOptions.DiscountFactor = 0.95;
end