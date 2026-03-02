classdef OccupancyGridmap < handle
    properties(Access = public)
        minBorderX
        maxBorderX
        minBorderY
        maxBorderY
        
        minX
        maxX
        minY
        maxY
        
        obstacles
        goals
        curGoals
        curPos
    end
    
    methods(Static)
        function stInd = getStateIndex(numTilesX, numTilesY, x,y) %TODO
            stInd = sub2ind([numTilesX, numTilesY],x,y);
        end
        
        function observations = getPossibleLocations(minX, minY,maxX,maxY)            
            numTiles = (abs(minX-maxX)+1)*(abs(minY-maxY)+1);
            observations = {};
            k = 1;
            for x = minX-1:maxX+1
                for y = minY-1:maxY+1
                    observations{k} = [x;y];
                    k = k+1;
                end
            end
        end
    end
    
    methods
        function corners = getMapBounds(obj)
            corners = {[obj.minX;obj.minY],[obj.maxX;obj.maxY]};
        end

        function numTilesX = getNumX(obj)
            numTilesX = abs(obj.minX-obj.maxX)+1;
        end
        
        function numTilesY = getNumY(obj)
            numTilesY = abs(obj.minY-obj.maxY)+1;
        end
        
        function resizeIfOutOfBounds(obj,pos)
            if pos(1) > obj.maxX
                obj.maxX = ceil(pos(1));
            end
            if pos(1) < obj.minX
                obj.minX = floor(pos(1));
            end
            if pos(2) > obj.maxY
                obj.maxY = ceil(pos(2));
            end
            if pos(2) < obj.minY
                obj.minY = floor(pos(2));
            end
        end
                
        function obj = OccupancyGridmap()
            obj.setSize(0,0,0,0);
            obj.goals = [];
            obj.obstacles = {};
            obj.curGoals = {};
            obj.curPos = {};
        end
        
        function setSize(obj,minX,minY,maxX,maxY)
            obj.minX = minX;
            obj.maxX = maxX;
            obj.minY = minY;
            obj.maxY = maxY;
        end
        
                
        function setBorder(obj,minBorderX,minBorderY,maxBorderX,maxBorderY)
            obj.resizeIfOutOfBounds([minBorderX,minBorderY]);
            obj.resizeIfOutOfBounds([maxBorderX,maxBorderY]);
            obj.minBorderX = minBorderX;
            obj.maxBorderX = maxBorderX;
            obj.minBorderY = minBorderY;
            obj.maxBorderY = maxBorderY;
        end
        
        function setBorderMinX(obj,minBorderX)
            obj.minBorderX = minBorderX;
        end
        
        function setBorderMinY(obj,minBorderY)
            obj.minBorderY = minBorderY;
            obj.resizeIfOutOfBounds([0,minBorderY]);
        end
        
        function setPos(obj, pos, nr)
            obj.resizeIfOutOfBounds(pos);
            obj.curPos{nr} = pos;
        end
        
        function setCurGoal(obj, goal, nr)
            obj.resizeIfOutOfBounds(goal);
            obj.curGoals{nr}=goal;
        end
        
        function setGoals(obj,list)%TODO
            obj.goals = cat(1,obj.goals, list);
        end
        
        function setGoal(obj,goal)%TODO
            obj.resizeIfOutOfBounds(goal);
            obj.goals = cat(1,obj.goals, goal);
        end
        
        function resetGoal(obj,goal)%TODO
            obj.resizeIfOutOfBounds(goal);
            obj.goals = [];
            obj.goals = cat(1,obj.goals, goal);
            
        end
        
        function setObstacles(obj,list)
            for obst = 1:length(list)
                curObst = list{obst};
                obj.resizeIfOutOfBounds([curObst(1),curObst(2)]);
                obj.resizeIfOutOfBounds([curObst(3),curObst(4)]);
            end
            obj.obstacles = [obj.obstacles, list];
        end
        
        function setObstacle(obj,obstacle)%TODO
            obj.resizeIfOutOfBounds([obstacle(1),obstacle(2)]);
            obj.resizeIfOutOfBounds([obstacle(3),obstacle(4)]);
            obj.obstacles = [obj.obstacles, obstacle];
        end
        
        function nr = getNumRobots(obj)
           nr = numel(obj.curPos);
        end
        
        function pos = getPos(obj,nr)
           pos = obj.curPos{nr};
        end
  
    end
end
