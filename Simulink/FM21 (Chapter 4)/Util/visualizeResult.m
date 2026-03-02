% #############################################################
%                      Visualization
% #############################################################
function visualizeResult(simulationInfo, maxSteps)
    clf;
    grid = OccupancyGridmap();
    grid.setSize(-10,-10,10,10);
    vizualizer = GridmapVisualizer(grid);
    
    maxSteps = min(length(simulationInfo.RLPos),maxSteps);
    for i = 1:maxSteps
            job = simulationInfo.Job(i,:);
            RLPos = simulationInfo.RLPos(i,:);
            grid.setPos(RLPos, 1);
            grid.setCurGoal(job,1);
            traces = simulationInfo.OppPos(i,:);
            for j = 1:length(traces)/2
                pos = [traces(1+(j-1)*2); traces(2+(j-1)*2)];
                grid.setPos(pos,j+1);
            end
            vizualizer.update();
            pause(0.05);
    end

end