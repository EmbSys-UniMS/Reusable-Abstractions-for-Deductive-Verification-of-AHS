% #########################################################################
% Input Mapping for the model with 2 Opponents
% #########################################################################

function isSafe = shieldWDSWOBNo(curObs, curAction)
    supNo = 0;
    d=curAction(4);
    isSafe = d==supNo;
end