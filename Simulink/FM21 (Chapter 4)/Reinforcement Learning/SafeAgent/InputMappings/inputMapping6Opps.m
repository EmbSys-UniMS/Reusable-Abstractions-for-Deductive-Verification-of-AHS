% #########################################################################
% Input Mapping for the model with 6 Opponents
% #########################################################################

% maps Simulink observations, workspaceConstants and current action to
% monitor input format
% the agent state is defined by its current action.
% - pre is the previous state, which is not used and can be set to 0 for
%   simplicity
% - post is the current state
% - params is the current environment state consisting of observations and
%   workspace constants
function [pre, post, params] = inputMapping6Opps(observation,  action, constants)

        DiffAX = observation(5);
        DiffAY = observation(6);
        DiffBX = observation(9);
        DiffBY = observation(10);
        DiffCX = observation(13);
        DiffCY = observation(14);
        DiffDX = observation(17);
        DiffDY = observation(18);
        DiffEX = observation(21);
        DiffEY = observation(22);
        DiffFX = observation(25);
        DiffFY = observation(26);

        stepTSRL = constants{1};
        oppAProp = constants{2};
        oppBProp = constants{3};
        oppCProp = constants{4};
        oppDProp = constants{5};
        oppEProp = constants{6};
        oppFProp = constants{7};

        MAXVELOA = oppAProp(1);
        MAXVELOB = oppBProp(1);
        MAXVELOC = oppCProp(1);
        MAXVELOD = oppDProp(1);
        MAXVELOE = oppEProp(1);
        MAXVELOF = oppFProp(1);

        THRESHOLDA = oppAProp(2);
        THRESHOLDB = oppBProp(2);
        THRESHOLDC = oppCProp(2);
        THRESHOLDD = oppDProp(2);
        THRESHOLDE = oppEProp(2);
        THRESHOLDF = oppFProp(2);

        pre.DirMX = 0; pre.DirMY = 0; pre.Velocity = 0;
        post.DirMX = action(1); post.DirMY = action(2); post.Velocity = action(3);

        params.DiffAX = DiffAX;
        params.DiffAY = DiffAY;
        params.DiffBX = DiffBX;
        params.DiffBY = DiffBY;
        params.DiffCX = DiffCX;
        params.DiffCY = DiffCY;
        params.DiffDX = DiffDX;
        params.DiffDY = DiffDY;
        params.DiffEX = DiffEX;
        params.DiffEY = DiffEY;
        params.DiffFX = DiffFX;
        params.DiffFY = DiffFY;

        params.MAXVELOA = MAXVELOA;
        params.MAXVELOB = MAXVELOB;
        params.MAXVELOC = MAXVELOC;
        params.MAXVELOD = MAXVELOD;
        params.MAXVELOE = MAXVELOE;
        params.MAXVELOF = MAXVELOF;

        params.MINDISTA = THRESHOLDA;
        params.MINDISTB = THRESHOLDB;          
        params.MINDISTC = THRESHOLDC;
        params.MINDISTD = THRESHOLDD;       
        params.MINDISTE = THRESHOLDE;
        params.MINDISTF = THRESHOLDF;

        params.STEPTSRL = stepTSRL;
end