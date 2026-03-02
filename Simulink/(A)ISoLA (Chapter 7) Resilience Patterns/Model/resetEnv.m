function in = resetEnv(in,mdl)
 randVal=randi(100000);
 %disp(randVal);
 in = setVariable(in,"rngSeed",randVal,"Workspace",mdl);
 %randBlock = "WaterDistSystem/Water Distribution System with Failure Repair Model/Failure Repair Model/Pump 1 FailureRepair/PumpRunning/Resettable Subsystem/FailureDelaySampler/Random Number";
 %in = setBlockParameter(in,randBlock,'Seed',num2str(randVal));
 %randBlock = "WaterDistSystem/Water Distribution System with Failure Repair Model/Failure Repair Model/Pump 1 FailureRepair/PumpRunning/Resettable Subsystem/FailureDelaySampler/Random Number"

 %constantBlock = "WaterDistSystem/Water Distribution System with Failure Repair Model/Failure Repair Model/Pump 1 FailureRepair/ffff";
 %in = setBlockParameter(in,constantBlock,'Value',num2str(randVal));
end

