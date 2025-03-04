function [assembleOne,pcoor] = particleRectangle(x1,y1,x2,y2)
    % calculate the point coordinate
    pcoor(:,1) = [x1;x2;x2;x1];
    pcoor(:,2) = [y1;y1;y2;y2];
    % convert to the geo objs
    points = point((1:4)',pcoor);
    segs = segment((1:4)',[{[1;2]};{[2;3]};{[3;4]};{[4;1]}], ...
        repmat([NaN, 1], 4, 1),SEGMENT_TYPE.GRAIN_PARTICLE*ones([4,1]));
    loops = loop(1,{[1;2;3;4]});
    parts = part(1,{[1]},PART_TYPE.PARTICLE);
    assembleOne = assemble(points,segs,loops,parts);
end