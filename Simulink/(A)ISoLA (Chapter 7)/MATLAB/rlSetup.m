mdl= "WaterDistSystem";
open_system(mdl)

%Setup enviroment for agent with contract

obsInfo = rlNumericSpec([2 1]);
actInfo= rlFiniteSetSpec([1 2 3 4 5 6 7 8 ]);

obsInfo.Name="observations";
actInfo.Name="pumpChoice";

agentBlk= mdl + "/RL Agent";
env = rlSimulinkEnv(mdl,agentBlk,obsInfo,actInfo);
env.ResetFcn = @(in) setVariable(in,"rngSeed",randi(100000),"Workspace",mdl);


%Setup enviroment for agent without contract (RL agent manages the supply)
obsInfoNC = rlNumericSpec([2 1]);
actInfoNC= rlFiniteSetSpec([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]);

agentBlk= mdl + "/RL Agent";
envNoContract = rlSimulinkEnv(mdl,agentBlk,obsInfo,actInfo);
envNoContract.ResetFcn = @(in) setVariable(in,"rngSeed",randi(100000),"Workspace",mdl);