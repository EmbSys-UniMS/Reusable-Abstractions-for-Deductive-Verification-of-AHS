function in = resetEnv(in,mdl)
 randVal=randi(100000);
 in = setVariable(in,"rngSeed",randVal,"Workspace",mdl);
end

