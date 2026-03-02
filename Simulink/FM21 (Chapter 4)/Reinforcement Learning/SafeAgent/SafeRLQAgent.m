% #############################################################
%   Safe Q-learning agent that implements the run time monitoring approach described in the thesis
% #############################################################

% Note: The OriginalRLQAgent from which this class inherits was based on
% MATLAB’s RLQAgent from the RL Toolbox, with modified access permissions
% to enable monitoring within the RL loop. This file cannot be shared due
% to copyright restrictions. However, the monitoring code is included here
% for reference.
classdef SafeRLQAgent < OriginalRLQAgent 
    
    properties (Access = private)
        % Private options to configure RL agent
        pathToMonitorFolder = '';
        monitorName =  '';
        originalActionInfo;
        inputMapping;
        monitorConstants;
    end
     
    methods
        % constructor accepts additional arguments to that of the default
        % agent
        %
        % pathToKeYmaeraMonitor = specifies the path to the run time monitor derived from KeYmaera X
        %
        % inputMapping = function that maps observations and constants
        % monitorConstants = additional constants used for the mapping
        function this = SafeRLQAgent(Critic, Option, pathToKeYmaeraMonitor, inputMapping, monitorConstants)
            
            this = this@OriginalRLQAgent(Critic, Option);
            this.originalActionInfo = Critic.ActionInfo;
            % creates a library from the monitor at the specified path and
            % loads it
            [~,name,~] = fileparts(pathToKeYmaeraMonitor);
            
            this.pathToMonitorFolder = 'monitorLib';
            this.monitorName = append(name,'Lib');
            
            %create monitor library from monitor c file
            [pathToLib,pathToHeader] = makemonitor(pathToKeYmaeraMonitor,this.monitorName,this.pathToMonitorFolder);
            % unload the library if it was previously loaded
            loadlibrary(pathToLib,pathToHeader);
            
            % input mapping is used for mapping observation data to monitor
            % parameters
            this.inputMapping = inputMapping;
            % additional constant monitor paramters
            this.monitorConstants = monitorConstants;
        end  
        
        % Given the current state of the system, return an action that
        % is allowed by the runtime monitor
        function safeActionInfo = getSafeActions(this, observation)
            curObs = observation{1};
            
            safeActions = {};
            
            %filters the set of actions for action that comply with the
            %contract
            for i = 1:length(this.originalActionInfo.Elements)
                curAction = this.originalActionInfo.Elements{i};
                % maps Simulink observations, workspaceConstants and current action to
                % monitor input format
                % the agent state is defined by its current action.
                % - pre is the previous state (not used -> set to 0)
                % - post is the current state
                % - params is the current environment state consisting of observations and
                %   workspace constants
                [pre,post,params] = this.inputMapping(curObs, curAction, this.monitorConstants);
                % calls the monitor function
                result = calllib(this.monitorName,'HCMonitor',pre,post,params);
                
                if(result)
                    safeActions{end+1} = curAction;
                end
                %TODO handle case in which no actions are safe ([0,0,0] is always allowed in our case study)
            end
            safeActionInfo = rlFiniteSetSpec(safeActions);
        end
    end
    
    %======================================================================
    % Implementation of abstract methods
    %======================================================================
    methods (Access = public)
       
        function Action = getActionWithExploration(this,observation)
            % Return a SAFE action with exploration
            this.ActionInfo = this.getSafeActions(observation);
            Action = getActionWithExploration@OriginalRLQAgent(this, observation);
            this.ActionInfo = this.originalActionInfo;
            
        end 
    end
    
    
    methods (Access = protected)
        
        function Action = getActionImpl(this,observation)
            % Return a SAFE action
            this.ActionInfo = this.getSafeActions(observation);
            Action = getActionImpl@OriginalRLQAgent(this, observation);
            this.ActionInfo = this.originalActionInfo;
        end
    end
end