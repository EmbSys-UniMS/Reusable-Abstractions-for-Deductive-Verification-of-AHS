function crashes = countCrashes(trainingStats)
    simulationInfo = trainingStats.SimulationInfo;
    len = length(simulationInfo);
    crashes = 0;
    for i = 1:len
        curInfo = simulationInfo(i,:);
        crashArr = curInfo.Crash;
        if (sum(crashArr(:) == 1)>0)
           crashes = crashes+1;
    end
end