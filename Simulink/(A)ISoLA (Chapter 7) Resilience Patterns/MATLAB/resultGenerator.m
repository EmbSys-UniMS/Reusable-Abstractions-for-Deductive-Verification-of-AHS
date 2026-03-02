%Calculates results

% counts successes
safety=0;
resilience=0;
performance=0;
for i = 1:runs 
    curRun = rlSimResult(i).SimulationInfo;
    if(curRun.safetyCheck(:,2)==1)
        safety=safety+1;
    end
    if(curRun.resilienceCheck(:,2)==1)
        resilience=resilience+1;
    end
    if(curRun.performanceCheck(:,2)==1)
        performance=performance+1;
    end
end

% calculate confidence interval
[midpointSafety,lowerBoundarySafety, upperBoundarySafety] = wilsonCI(safety,runs,0.95);
[midpointResilience,lowerBoundaryResilience,upperBoundaryResilience] = wilsonCI(resilience,runs,0.95);
[midpointPerformance, lowerBoundaryPerformance, upperBoundaryPerformance] = wilsonCI(performance,runs,0.95);

% Format the results
resultSafety = sprintf('Safety: Midpoint = %.4f, Lower Boundary = %.4f, Upper Boundary = %.4f', midpointSafety, lowerBoundarySafety, upperBoundarySafety);
resultResilience = sprintf('Resilience: Midpoint = %.4f, Lower Boundary = %.4f, Upper Boundary = %.4f', midpointResilience, lowerBoundaryResilience, upperBoundaryResilience);
resultPerformance = sprintf('Performance: Midpoint = %.4f, Lower Boundary = %.4f, Upper Boundary = %.4f', midpointPerformance, lowerBoundaryPerformance, upperBoundaryPerformance);

% Display the results
disp(resultSafety);
disp(resultResilience);
disp(resultPerformance);
fprintf(fileID,'safetylow,%6.6f\r\n',lowerBoundarySafety);
fprintf(fileID,'safetymid,%6.6f\r\n',midpointSafety);
fprintf(fileID,'safetyhigh,%6.6f\r\n',upperBoundarySafety);
fprintf(fileID,'resiliencelow,%6.6f\r\n',lowerBoundaryResilience);
fprintf(fileID,'resiliencemid,%6.6f\r\n',midpointResilience);
fprintf(fileID,'resiliencehigh,%6.6f\r\n',upperBoundaryResilience);
fprintf(fileID,'performancelow,%6.6f\r\n',lowerBoundaryPerformance);
fprintf(fileID,'performancemid,%6.6f\r\n',midpointPerformance);
fprintf(fileID,'performancehigh,%6.6f\r\n',upperBoundaryPerformance);