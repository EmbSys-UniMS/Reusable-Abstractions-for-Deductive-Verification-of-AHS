%Runs Monte Carlo simulations 
runs=5000;

%Perform runs
tic
simOpts = rlSimulationOptions(MaxSteps=maxSteps,NumSimulations=runs, UseParallel=true);%'ShowProgress', 'on',
rlSimResult = sim(qAgent,env,simOpts);

% Calculate results
resultGenerator;
simTime=toc;
fprintf(fileID,'simtime,%6.6f\r\n',simTime);
fclose(fileID);