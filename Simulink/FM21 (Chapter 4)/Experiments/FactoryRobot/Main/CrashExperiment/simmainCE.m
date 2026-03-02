% #############################################################
% script for the random agent experiment
% trains safe and unsafe random agents with the model from the case study
% (with 2 and 6 opponents)
% for a desired number of training episodes
% learning agent with the case study model
% #############################################################

setSimulationVariablesCE;

episodes = 1000;
stepsPerEpisode = 120;

% simulate
[trainingStatsUnsafe2,trainingStatsSafe2] = trainCE(2, episodes, stepsPerEpisode, simParameters);
[trainingStatsUnsafe6,trainingStatsSafe6] = trainCE(6, episodes, stepsPerEpisode, simParameters);

% evaluate
disp(["Crashes unsafe agent 2 opponents:"; countCrashes(trainingStatsUnsafe2)]);
%disp(["Crashes safe agent 2 opponents:"; countCrashes(trainingStatsSafe2)]);
disp(["Crashes unsafe agent 6 opponents:"; countCrashes(trainingStatsUnsafe6)]);
%disp(["Crashes safe agent 6 opponents:"; countCrashes(trainingStatsSafe6)]);


