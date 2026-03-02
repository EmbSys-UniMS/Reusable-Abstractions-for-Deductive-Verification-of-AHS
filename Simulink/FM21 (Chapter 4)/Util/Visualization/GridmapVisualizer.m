% #########################################################################
% Class for visualizing a gridmap
% #########################################################################
classdef GridmapVisualizer < handle
    %GridmapVisualizer Summary of this class goes here
    %   Detailed explanation goes here
    properties
        grid;
        robotHandles;
        goalHandles;
        borderHandles;
        xLines;
        yLines;
        offset=0.5;
        minX,minY,maxX,maxY;

    end
    
    methods
        function obj = GridmapVisualizer(gridmap)
            obj.grid = gridmap;
            obj.robotHandles = {};
            obj.borderHandles={};
            obj.xLines = {};
            obj.yLines = {};
            obj.addObstacles();
            obj.addGoals();
            [obj.minX,obj.minY,obj.maxX,obj.maxY] = obj.getBounds();
            obj.drawGrid();
            obj.drawBorders();
            axis equal;
        end
        
        % draws obstacles with data from the gridmap TODO
        function addObstacles(obj)
            obstacles= obj.grid.obstacles;
            for i = 1:length(obstacles)
                obstacle = obstacles{i};
                rectangle('Position',[obstacle(1) obstacle(2) (obstacle(3)-obstacle(1)) (obstacle(4)-obstacle(2))],'FaceColor',Colour.Red.toVector(),'Curvature',0);
            end
        end
        
        function drawBorders(obj)
            if ~ isempty(obj.grid.minBorderX)%left
                %obj.borderHandles{1} = rectangle('Position',[obj.grid.minBorderY obj.grid.minY (1) (obj.maxY-obj.minY)],'FaceColor',Colour.Red.toVector(),'Curvature',0);
            end
            if ~ isempty(obj.grid.minBorderY)%bottom
                obj.borderHandles{2} = rectangle('Position',[obj.minX-obj.offset obj.grid.minBorderY-2*obj.offset (obj.maxX-obj.minX+2*obj.offset) (2*obj.offset)],'FaceColor',Colour.Red.toVector(),'Curvature',0);   
            end
            %TODO
            %if ~ isempty(obj.grid.maxBorderX)%right
            %    obj.borderHandles{3} = rectangle('Position',[obj.minX obj.grid.maxBorderX (obj.maxX-obj.minX) (1)],'FaceColor',Colour.Red.toVector(),'Curvature',0);
            %end
            %if ~ isempty(obj.grid.maxBorderY)%top
            %    obj.borderHandles{4} = rectangle('Position',[obj.minX obj.grid.maxBorderY (obj.maxX-obj.minX) (1)],'FaceColor',Colour.Red.toVector(),'Curvature',0);
            %end
        end
        
        % draws the positions of different robots
        function addCurPos(obj)
            positions = obj.grid.curPos;
            for i = 1:obj.grid.getNumRobots()
                colour = Colour.OpponentColour;
                if i == 1
                    colour = Colour.AgentColour;
                end
                pos = positions{i};
                obj.setPos(pos,colour,i);
            end
        end
        
        % draws the positions of current goals
        function addCurGoals(obj)
            goals = obj.grid.curGoals;
            for i = 1:length(goals)
                colour = Colour.OpponentColour;
                if i == 1
                    colour = Colour.AgentColour;
                end
                goal = goals{i};
                obj.setCurGoal(goal,colour,i);
            end
        end
        
        % sets goal coordingates to blue
        function addGoals(obj)
            goals= obj.grid.goals;
            for i = 1:size(goals,1)
                goal = goals(i,:);
                rectangle('Position',[goal(1)-obj.offset  goal(2)-obj.offset 2*obj.offset 2*obj.offset],'FaceColor',Colour.Blue.toVector(),'Curvature',0);
            end
        end
        
        % refresh grid
        function removeGrid(obj)
            xLSize = size(obj.xLines);
            for i = 1:xLSize(2)
                delete(obj.xLines{i});
            end
            yLSize = size(obj.yLines);
            for i = 1:yLSize(2)
                delete(obj.yLines{i});
            end
        end
        
        function drawGrid(obj)
            obj.removeGrid();
            xSize=abs(obj.maxX-obj.minX);
            ySize=abs(obj.maxY-obj.minY);
            for i = 0:xSize+1
               obj.xLines{i+1} = line([obj.minX+i-obj.offset,obj.minX+i-obj.offset],[obj.minY-obj.offset,obj.maxY+obj.offset]);
            end
            for i = 0:ySize+1
               obj.yLines{i+1} = line([obj.minX-obj.offset ,obj.maxX+obj.offset],[obj.minY+i-obj.offset,obj.minY+i-obj.offset]);
            end
        end
        
        function b = sizeChanged(obj)
            [minXN,minYN,maxXN,maxYN] = getBounds(obj);
            if minXN~=obj.minX || minYN~=obj.minY || maxXN~=obj.maxX || maxYN~=obj.maxY
                b = true;
            else
                b = false;
            end
        end
        
        function [minX,minY,maxX,maxY] = getBounds(obj)
            bounds = obj.grid.getMapBounds();
            minX = bounds{1}(1);
            minY = bounds{1}(2);
            maxX = bounds{2}(1);
            maxY = bounds{2}(2);
        end

        % updates the representation with data from the gridmap
        function update(obj)
            if obj.sizeChanged()
                [obj.minX,obj.minY,obj.maxX,obj.maxY] = obj.getBounds();
                obj.drawGrid();
                obj.drawBorders();
            end
            obj.addCurPos();
            obj.addCurGoals();
        end
        
        % Sets a circle with the specified colour at pos
        function setPos(obj,pos,colour,nr)
            siz = size(obj.robotHandles);
            %[x,y] = obj.getUpperLeftGridPixel(xGrid,yGrid);
            circPos = [pos(1)-obj.offset  pos(2)-obj.offset 2*obj.offset 2*obj.offset];
            if siz(2)<nr
               obj.robotHandles{nr}=rectangle('Position',circPos,'FaceColor',colour.toVector(),'Curvature',1);
            else
                robCircle = obj.robotHandles{nr};
                robCircle.Position = circPos;
            end
        end
        
                
        % Sets a circle with the specified colour at pos
        function setCurGoal(obj,goal,colour,nr)
            siz = size(obj.goalHandles);
            %[x,y] = obj.getUpperLeftGridPixel(xGrid,yGrid);
            goalPos = [goal(1)-obj.offset  goal(2)-obj.offset 2*obj.offset 2*obj.offset];
            if siz(2)<nr
               obj.goalHandles{nr}=rectangle('Position',goalPos,'FaceColor',colour.toVector(),'Curvature',0);
            else
                goalRect = obj.goalHandles{nr};
                goalRect.Position = goalPos;
            end
        end
    end
end

