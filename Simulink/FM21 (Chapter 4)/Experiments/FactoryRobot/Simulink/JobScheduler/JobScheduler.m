classdef JobScheduler < matlab.System
    % untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties

    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)
        donePrev = 0;
        curGoal = [0,0];
        curGoalIndex = 0;
        initial = true;
    end

    methods(Access = protected)
        
        function setupImpl(obj,workstations,done)
            obj.updateImpl(workstations, done);
        end
        
        function updateImpl(obj,workstations,done)

            if (done >=1 && obj.donePrev == 0 || obj.initial == true)
                obj.curGoal = obj.getNextGoal(workstations);
            end
            obj.donePrev = done;
            obj.initial = false;
        end
        
        function nextGoal = getNextGoal(obj, workstations)
             nW = size(workstations);
             nW = nW(2); %number of workstations

             if nW >= 1
                 i = obj.curGoalIndex;
                 % in case there is only one workstation
                 validIndices = 1;
                 if(nW>1)
                         %initial goal
                         if (i == 0)
                            validIndices = randperm(nW);
                         else
                             % randomly choose new goal without consecutive repetition
                             if (i > 1 && i < nW)
                                leftRandom = randperm(i-1);
                                rightRandom = randperm(nW-i)+i;
                                validIndices = [leftRandom, rightRandom];
                             end
                             if (i == 1)
                                validIndices = randperm(nW-1)+1;
                             end
                             if (i == nW)
                                validIndices = randperm(nW-1);
                             end
                         end
                 end
                 validIndices = validIndices(randperm(length(validIndices)));
                 obj.curGoalIndex = validIndices(1);
                 nextGoal = workstations(:,obj.curGoalIndex);
             end
             %TODO: throw exception if workspace array is empty or changes
             %during simulation
        end
        
        function [currentGoalX,currentGoalY] = outputImpl(obj,workstations,done)
            currentGoalX = obj.curGoal(1);
            currentGoalY = obj.curGoal(2);
        end

        function resetImpl(obj)
            obj.donePrev = 0;
            obj.curGoal = [0,0];
            obj.curGoalIndex = 0;
            obj.initial = true;
        end
        
        function sts = getSampleTimeImpl(obj)
            % TODO: sample time is currently the hard coded to 0.2 and the
            % same for all Job Schedulers
            sts = createSampleTime(obj,'Type','Discrete','SampleTime',0.2);
        end
    end
end
