% ##########################################################
% creates a set of possible actions for a given velocity
% ##########################################################
function obsInfo = createDiscreteObservationInfo()
    %stop action

    maxPState = 0; % pState observation disabled
    maxHeight = 576; %/ 576 96*0.6=57.6 (Stunden mal maximaler inflow)
    maxCost = 432; %/ 432 % 0.45*96 (max Kosten mal Stunden)

    obsInfo = cell(((maxPState+1)^3)*(maxHeight+1)*(maxCost+1),1); % preallocate for speed


    i=1;
    for pState1 = 0:maxPState %1
        for pState2 = 0:maxPState %1
            for pState3 = 0:maxPState %1
                for height = 0:maxHeight%6 % 96*0.6=57.6 (Stunden mal maximaler inflow) 
                    for cost = 0:maxCost%2 % 0.45*96 (max Kosten mal Stunden
                        obsInfo{i}=[pState1,pState2,pState3,pState1,pState2,pState3,height,cost];
                        i = i+1;
                    end
                end
            end
        end
    end
    obsInfo = rlFiniteSetSpec(obsInfo);
end