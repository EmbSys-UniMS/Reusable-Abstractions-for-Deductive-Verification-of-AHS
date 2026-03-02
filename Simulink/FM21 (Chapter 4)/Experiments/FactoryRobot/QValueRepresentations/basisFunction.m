% #############################################################
% Custom linear basis function used for our RL experiment
% #############################################################

function B = basisFunction(obs,act)
        
        % TODO no better way of passing sampling time as of yet.
        Ts = 0.5;
        
        pos = [obs(1),obs(2)];
        goal = [obs(3),obs(4)];
        
        actDir = [act(1),act(2)];
        
        %vector of velocities
        actSpeed = toUnitVector(actDir)*act(3);
        
        opps = [];
        %5 = offset for RL robot and goal coordinates
        i = 5;
        %itterate over opponent information
        while(i<=size(obs,1))
               opps=[opps;obs(i),obs(i+1),obs(i+2),obs(i+3)];
               i = i+4;
        end
        
        oppClosenessFeaturesBef = [];
        oppClosenessFeaturesAfter = [];
        %itterate over opponent information
        for(i=1:size(opps,1))
            opp = opps(i,:);
            diff = [opp(1), opp(2)];
            dir = toUnitVector([opp(3), opp(4)]);
            %distance to the opponent as radial basis with center 2 and bandwidth 1.5
            %values greater than 0.9 are set to 1
            oppClosenessFeaturesBef = [oppClosenessFeaturesBef, getClosenessFeatureRobot(norm(diff),1.5,2)];
            %Expected distance to the opponent after applying the current 
            %action under the assumption that the opponent moves in the same 
            %direction as before as radial basis with center 2 and bandwidth 1.5
            %values greater than 0.9 are set to 1
            %TODO this does not take the opponents velocity into account
            oppClosenessFeaturesAfter = [oppClosenessFeaturesAfter, getClosenessFeatureRobot(norm(diff+dir*Ts-actSpeed*Ts),1.5,2)];
        end

        %Quality of action with regards to the direction of the goal
        moveDirValue = radialBasis(toUnitVector(actDir),getBestDirToGoal(pos,goal),1);
        
        %Expected distance to the goal after applying the action as radial
        %basis with center goals and bandwidth 7
        %values greater than 0.9 are set to 1
        gCloseAfter = getClosenessFeature([pos+actSpeed*Ts],goal,7);
        
        %Feature of the expected closest robot after the action
        closestRob = max(oppClosenessFeaturesAfter);
        
        %wether the move is likely to increase or decrease the overall distance to
        %opponents
        incDist = closestRob<max(oppClosenessFeaturesBef);
        decDist = closestRob>max(oppClosenessFeaturesBef);

        % Final vector of features
        B = [
                incDist*closestRob;...
                decDist*closestRob;...
                closestRob;...
                moveDirValue*(1-closestRob);...
                gCloseAfter;...
                gCloseAfter*(1-closestRob)...
            ];
end

function bestDir = getBestDirToGoal(PosCoord,GoalCoord)
    diff = GoalCoord-PosCoord;
    bestDir = toUnitVector(diff);
end


function dist = getClosenessFeature(pos,center,bandWidth)
        dist = radialBasis(pos,center,bandWidth);
        if(dist>0.9)
            dist = 1;
        end
end

function dist = getClosenessFeatureRobot(dist,thresh,bandWidth)
        if(norm(dist)<=thresh)
            dist = 1;
        else
            dist = radialBasis(dist,thresh,bandWidth);
        end
end
% returns unit vector with same direction or unchanged vector
%in case norm(vector)=0
function uv = toUnitVector(vector)
        vn = norm(vector);
        if(vn~=0)
            uv=(vector/vn);
        else
            uv=vector;
        end
end