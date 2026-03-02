% #########################################################################
% Input Mapping for the model with 2 Opponents
% #########################################################################

% maps Simulink observations, workspaceConstants and current action to
% monitor input format
% the agent state is defined by its current action.
% - pre is the previous state, which is not used and can be set to 0 for
%   simplicity
% - post is the current state
% - params is the current environment state consisting of observations and
%   workspace constants
function [pre, post, params] = inputMapping2Opps(observation, action, constants)

        DiffAX = observation(5);
        DiffAY = observation(6);
        DiffBX = observation(9);
        DiffBY = observation(10);
        
        stepTSRL = constants{1};
        oppAProp = constants{2};
        oppBProp = constants{3};
        
        MAXVELOA = oppAProp(1);
        MAXVELOB = oppBProp(1);
        THRESHOLDA = oppAProp(2);
        THRESHOLDB = oppBProp(2);

        pre.DirMX = 0; pre.DirMY = 0; pre.Velocity = 0;
        post.DirMX = action(1); post.DirMY = action(2); post.Velocity = action(3);

        params.DiffAX = DiffAX;
        params.DiffAY = DiffAY;
        params.DiffBX = DiffBX;
        params.DiffBY = DiffBY;
        params.MAXVELOA = MAXVELOA;
        params.MAXVELOB = MAXVELOB;
        params.MINDISTA = THRESHOLDA;
        params.MINDISTB = THRESHOLDB;
        params.STEPTSRL = stepTSRL;
end