function crashes = getEpsWithCrashes(trainingStats)
    simulationInfo = trainingStats.SimulationInfo;
    len = length(simulationInfo);
    crashes = [];
    for i = 1:len
        curInfo = simulationInfo(i,:);
        crashArr = curInfo.Crash;
        if (sum(crashArr(:) == 1)>0)
           crashes = [crashes,i];
    end
end