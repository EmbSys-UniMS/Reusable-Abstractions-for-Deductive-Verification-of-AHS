% 2 configurations (j):
% - Resilience: DQN with single reward
% - Performance: DQN with single reward
% Durations (v): 96 hours
for j = 1:1:2
    for v = 96:96 
        clearvars -except v j
        disp(v)
        maxTime=v;

        sampleTime=10;

        % tank settings
        hFull = 5;
        hDeg = 2;
        hMin = 0;
        supFull = 0.3;
        supDeg = 0.2;
        supNo = 0;
        inflow=0.15;
        singleReward = true;
        SMCReward=true;
        runs=5000;


        if j==1
            % DQN, single reward, performance
            ids = sprintf('MRresultsPerformance_%d.txt',maxTime);  
            %supply level for resilience check
            supCheck = supFull;
            % set rewards
            RewardResilience=0;
            RewardPerformance=1;
            PenaltyResilience=0;
            PenaltyPerformance=0;
            RewardCost=0;
            PenaltyCost=0;
            RewardSafety=0;
            PenaltySafety=0;

            % pump settings
            meanFail1=30;
            varFail1=36;
            minRep1=7;
            maxRep1=10;
            
            meanFail2=20;
            varFail2=16;
            minRep2=3;
            maxRep2=5;
            
            meanFail3=5;
            varFail3=1;
            minRep3=1;
            maxRep3=2;

            fileID=fopen(ids,'w');
            rlMain;
        elseif j==2
            % DQN, single reward, resilience (degraded service)
            ids = sprintf('MRresultsResilienceDeg_%d.txt',maxTime);
            %supply level for resilience check
            supCheck = supDeg;
            % set rewards
            RewardResilience=1;
            RewardPerformance=0;
            PenaltyResilience=0;
            PenaltyPerformance=0;
            RewardCost=0;
            PenaltyCost=0;
            RewardSafety=0;
            PenaltySafety=0;

            % pump settings (means and std. devs. are halved, repair times are doubled)
            meanFail1 = 15; % 30/2
            varFail1  = 9;  % (6/2)^2  
            minRep1   = 14;    
            maxRep1   = 20;    

            meanFail2 = 10; % 20/2
            varFail2  = 4;  % (4/2)^2  
            minRep2   = 6;
            maxRep2   = 10;
            
            meanFail3 = 2.5; % 5/2
            varFail3  = 0.25; %(1/2)^2
            minRep3   = 2;
            maxRep3   = 4;
        end
        rlMain;       
    end
end