% #########################################################################
% Input Mapping for the model with 2 Opponents
% #########################################################################

function isSafe = shieldWDSWOBDeg(curObs, curAction)
    hDeg = 2;
    hMin = 0;
    supDeg = 0.2;
    inflow=0.15;
    sampleTime=10;

    a1=curAction(1);
    a2=curAction(2);
    a3=curAction(3);
    d=curAction(4);
    h=curObs{1}(1);
    isSafe = d==supDeg &&(h+((a1+a2+a3)*inflow-d)*sampleTime>hDeg && h+((0)-d)*sampleTime>hMin);
end