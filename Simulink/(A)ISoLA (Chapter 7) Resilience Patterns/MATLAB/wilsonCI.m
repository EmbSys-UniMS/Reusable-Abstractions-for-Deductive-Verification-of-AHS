function [midpoint,lowerBoundary, upperBoundary] = wilsonCI(success,numberRuns,confidenceLevel)
%wilsonCI Computes Wilson Score Confidence Interval
%CI is [lowerBoundary, upperBoundary]
%   success are number of runs where property is fulfilled, 
% numberRuns number of runs, and 
% confidenceLevel, confidence level between 0 and 1
mean = success/numberRuns;
alphaHalf = (1-confidenceLevel)/2;
z= norminv(1-alphaHalf);
if (success==0)
    lowerBoundary = 0;
else
    lowerBoundary = (mean+(z^2)/(2*numberRuns)-z*sqrt((mean*(1-mean))/numberRuns+z^2/(4*numberRuns^2)))/(1+z^2/numberRuns);
end 
if (success==numberRuns)
    upperBoundary = 1;
else
    upperBoundary= (mean+(z^2)/(2*numberRuns)+z*sqrt((mean*(1-mean))/numberRuns+z^2/(4*numberRuns^2)))/(1+z^2/numberRuns);
end
%halfIntervalWidth = 0.5 * (upperBoundary-lowerBoundary);
midpoint = mean*(numberRuns/(numberRuns+(z^2)))+0.5*((z^2)/(numberRuns+z^2));
end