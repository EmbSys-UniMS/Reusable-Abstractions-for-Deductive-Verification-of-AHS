% ##########################################################
% creates a set of possible actions for a given velocity
% ##########################################################
function agentActionInfo = createAgentActionInfo(supFull, supDeg, supNo)
    % Define possible values for each column
    valuesPerColumn = {
        [0, 1],  
        [0, 1], 
        [0, 1],
        [supNo, supDeg, supFull]   
    };
    % Number of columns
    numCols = numel(valuesPerColumn);
    
    % Generate all possible combinations
    combs = cell(1, numCols);
    [combs{:}] = ndgrid(valuesPerColumn{:}); % Cartesian product of different sets
    
    % Convert to a cell array where each row contains a numeric array
    agentActions = arrayfun(@(idx) cell2mat(cellfun(@(x) x(idx), combs, 'UniformOutput', false)), ...
                            (1:numel(combs{1}))', 'UniformOutput', false);
    
    % Display the result
    disp(agentActions);

    %create action triplets consisting of direction vector and velocities
    agentActionInfo = rlFiniteSetSpec(agentActions);
    agentActionInfo.Name = 'pump activations and supply';
end