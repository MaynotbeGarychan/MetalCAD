function assemble_temp = makeRectangle(x1,y1,x2,y2,seg_type,part_type)

    % calculate the point coordinate
    pcoor(:,1) = [x1;x2;x2;x1];
    pcoor(:,2) = [y1;y1;y2;y2];

    % convert to the geo objs
    pts = point((1:4)',pcoor);
    segs = segment((1:4)',[{[1;2]};{[2;3]};{[3;4]};{[4;1]}], ...
        repmat([NaN, 1], 4, 1),seg_type*ones([4,1]));
    loops = loop(1,{[1;2;3;4]});
    parts = part(1,{[1]},part_type);

    % init an assemble
    assemble_temp = assemble(pts,segs,loops,parts);
    
end