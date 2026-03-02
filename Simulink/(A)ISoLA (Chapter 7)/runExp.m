% 6 configurations (j):
% - Resilience: Q-Learning and DQN, single & multiple rewards
% - Performance: DQN, single & multiple rewards
% Durations (v): 24, 48, 72, 96 hours
for j = 1:1:6
    for v = 24:24:96
        clearvars -except v j
        disp(v)
        maxTime=v;
        if j==1
            % DQN, many rewards, Resilience
            ids = sprintf('resultsSimulink_DQN_manyRewards_res_%d.txt',maxTime);
            useDQN = true; % true -> use DQN agent, false -> use Q-Table agent
            singleReward = false;
            % set rewards
            RewardResilience=1;
            RewardPerformance=0;
            PenaltyResilience=-1;
            PenaltyPerformance=0;
        elseif j==2
            % DQN, single reward, resilience
            ids = sprintf('resultsSimulink_DQN_singleReward_res_%d.txt',maxTime);
            useDQN = true;     
            singleReward = true;
            RewardResilience=1;
            RewardPerformance=0;
            PenaltyResilience=-1;
            PenaltyPerformance=0;
        elseif j==3
            ids = sprintf('resultsSimulink_QTAB_manyRewards_res_%d.txt',maxTime);
            % Q-Learning, many rewards, resilience
            useDQN = false;
            singleReward = false;
            RewardResilience=1;
            RewardPerformance=0;
            PenaltyResilience=-1;
            PenaltyPerformance=0;
        elseif j==4
            % Q-Learning, single reward, resilience
            ids = sprintf('resultsSimulink_QTAB_singleReward_res_%d.txt',maxTime);
            useDQN = false;  
            singleReward = true;
            RewardResilience=1;
            RewardPerformance=0;
            PenaltyResilience=-1;
            PenaltyPerformance=0;
        elseif j==5
            % DQN, many rewards, performance
            ids = sprintf('resultsSimulink_DQN_manyRewards_perf_%d.txt',maxTime);
            useDQN = true; 
            singleReward = false;
            RewardResilience=0;
            RewardPerformance=1;
            PenaltyResilience=0;
            PenaltyPerformance=-1;
        elseif j==6
            % DQN, single rewards, performance
            ids = sprintf('resultsSimulink_DQN_singleReward_perf_%d.txt',maxTime);
            useDQN = true;  
            singleReward = true;
            RewardResilience=0;
            RewardPerformance=1;
            PenaltyResilience=0;
            PenaltyPerformance=-1;
        end
        % continue with experiment
        rlMain;
    end
end