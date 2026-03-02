function coord = getRandomSafeCoord(RLCoord, SAFETYDIST, epsilon)
% initializes the coordinates of the opponents to a safe distance: 
%d > SAFETYDIST
sign = 1;
if (randi([0,1],1) > 0.5)
    sign = -1;
end

% init between SAFETYDIST+EPS and SAFETYDIST*5;
min = SAFETYDIST+epsilon;
max = SAFETYDIST*5;

coord = min + (max-min)*rand(1,1);
coord = coord*sign;
end

