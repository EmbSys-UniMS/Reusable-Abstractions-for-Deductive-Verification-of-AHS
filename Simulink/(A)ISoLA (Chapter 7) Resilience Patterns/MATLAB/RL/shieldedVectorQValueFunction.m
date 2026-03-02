% Adapted from rlVectorQValueFunction
% This file implements a shielded vector-valued Q-function that can be
% used with safe deep neural network agents.
classdef shieldedVectorQValueFunction < rl.function.rlVectorQValueFunction

    properties (Access = private)
        localObservationInfo
        localActionInfo
        shields
    end
    
    methods
        function this = shieldedVectorQValueFunction(model, observationInfo, actionInfo, modelInputMap, shields)
            % Constructor
            this = this@rl.function.rlVectorQValueFunction(model, observationInfo, actionInfo, modelInputMap);
            this.localObservationInfo = observationInfo;
            this.localActionInfo = actionInfo;
            this.shields = shields;
        end
        
    end

    methods (Access = protected)
        function [maxQ, maxQIndex, state] = getMaxQValue_(this, observation)
            % Evaluate Q-values, state, batch size, and sequence length based on the observation
            [QValues, state, BatchSize, SequenceLength] = evaluate(this, observation);
            
            % Initialize variables
            maxQs = -Inf(BatchSize, SequenceLength); % max Q-values for each batch, start with the lowest possible value
            maxQIndexs = zeros(BatchSize, SequenceLength); % Indices of max Q-values that pass the safety check
        
            if iscell(QValues)
                QValues = QValues{1}; % Assume QValues is a cell array, we need to extract the first element
            end
            
            % Precompute shield values for all actions and shields
            numActions = size(QValues, 1);
            numShields = length(this.shields); % Number of shields
            shielded = false(numActions, BatchSize, SequenceLength);
            
            % Iterate over batches and sequences to apply each shield
            for b = 1:BatchSize
                for s = 1:SequenceLength
                    % Start by assuming no valid actions for this batch and sequence
                    foundValidAction = false;
                    
                    % Check each shield
                    for shieldIdx = 1:numShields
                        currentShield = this.shields{shieldIdx};
                        
                        % Apply the current shield to all actions
                        for i = 1:numActions
                            shielded(i, :, :) = currentShield(observation, getElementValue(this.localActionInfo, i));
                        end
                        
                        % Get valid indices for this shield
                        validIndicesForShield = find(shielded(:, b, s));
                        
                        % If valid actions found, break the loop
                        if ~isempty(validIndicesForShield)
                            % Use validIndicesForShield to select valid Q-values
                            validQValues = QValues(:, b, s);
                            validQValues = validQValues(validIndicesForShield);
                            
                            [maxQs(b, s), maxIdx] = max(validQValues);
                            maxQIndexs(b, s) = validIndicesForShield(maxIdx);
                            foundValidAction = true;
                            break; % Exit the shield loop once a valid action is found
                        end
                    end
                    
                    % If no valid action was found for any shield, throw an error
                    if ~foundValidAction
                        error(['No action enabled for observation ' num2str(observation{1})]);
                    end
                end
            end
            % Reshape outputs to match the BatchSize and SequenceLength
            maxQ = reshape(maxQs, [1, BatchSize, SequenceLength]);
            maxQIndex = reshape(maxQIndexs, [1, BatchSize, SequenceLength]);
        end 
    end
end
