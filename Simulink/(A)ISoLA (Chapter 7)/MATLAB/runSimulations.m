%Runs Monte Carlo simulations 

%Perform runs
tic
simOpts = rlSimulationOptions(MaxSteps=maxSteps, NumSimulations=runs, UseParallel=useParallel);
rlSimResult = sim(qAgent,env,simOpts);

% Calculate results using confidence interval
resultGenerator;
simTime=toc
fprintf(fileID,'simtime,%6.6f\r\n',simTime);
fclose(fileID);