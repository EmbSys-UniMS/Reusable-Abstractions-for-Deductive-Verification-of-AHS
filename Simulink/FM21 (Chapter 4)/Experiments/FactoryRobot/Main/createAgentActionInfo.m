% ##########################################################
% creates a set of possible actions for a given velocity
% ##########################################################
function agentActionInfo = createAgentActionInfo(velocities)
    %stop action
    agentActions = {[0;0;0]};
    %create action triplets consisting of direction vector and velocities
    for i = 1:length(velocities)
       if ~(velocities(i) == 0)
           agentActions = [agentActions,{[1;0;velocities(i)],[-1;0;velocities(i)],[0;1;velocities(i)],[0;-1;velocities(i)],[1;1;velocities(i)],[-1;-1;velocities(i)],[1;-1;velocities(i)],[-1;1;velocities(i)]}];
       end
           
    end
    agentActionInfo = rlFiniteSetSpec(agentActions);
    agentActionInfo.Name = 'Moves';
end