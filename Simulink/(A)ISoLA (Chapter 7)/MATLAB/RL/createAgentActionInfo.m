% ##########################################################
% creates a set of possible actions for a given velocity
% ##########################################################
function agentActionInfo = createAgentActionInfo()
    %stop action

    agentActions = {
     [0 0 0] ;
     [0 0 1] ;
     [0 1 0] ;
     [0 1 1] ;
     [1 0 0] ;
     [1 0 1] ;
     [1 1 0] ;
     [1 1 1] ;
     };

    %create action triplets consisting of direction vector and velocities
    agentActionInfo = rlFiniteSetSpec(agentActions);
    agentActionInfo.Name = 'pump activations';
end