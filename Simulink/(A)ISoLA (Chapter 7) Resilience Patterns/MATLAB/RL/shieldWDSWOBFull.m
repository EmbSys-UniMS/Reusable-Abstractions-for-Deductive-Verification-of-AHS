% #########################################################################
% Input Mapping for the model with 2 Opponents
% #########################################################################

function isSafe = shieldWDSWOBFull(curObs, curAction)
    hFull = 5;
    hDeg = 2;
    supFull = 0.3;
    inflow=0.15;
    sampleTime=10;

    a1=curAction(1);
    a2=curAction(2);
    a3=curAction(3);
    d=curAction(4);
    h=curObs{1}(1);
    isSafe = d==supFull && (h+((a1+a2+a3)*inflow-d)*sampleTime>hFull && h+((0)-d)*10>hDeg);
end