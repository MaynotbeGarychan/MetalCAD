function [assembleOne,boundaryCoor] = circle(x0,y0,radius,resolution)
    % calculate the boundary coordinate of the circle
    boundaryCoor = NaN(resolution,2);
    theta = linspace(0, 2*pi, resolution)';
    boundaryCoor(:,1) = radius * cos(theta) + x0;
    boundaryCoor(:,2) = radius * sin(theta) + y0;
    % convert to the geo objs
    pid = (1:resolution)'; points = point(pid,boundaryCoor);
    segs = segment(1,{[pid;pid(1)]},[NaN,1],SEGMENT_TYPE.GRAIN_PARTICLE);
    loops = loop(1,{[1]});
    parts = part(1,{[1]},PART_TYPE.PARTICLE);
    assembleOne = assemble(points,segs,loops,parts);
end

