function assemble_temp=  makeRectangleWithGb(x1,y1,x2,y2)

    % calculate the point coordinate
    y3 = (y1+y2)/2;
    pcoor(:,1) = [x1;x2;x2;x1;x1;x2];
    pcoor(:,2) = [y1;y1;y2;y2;y3;y3];

    % convert to the geo objs
    pts = point((1:6)',pcoor);
    segs = segment((1:3)', [{[5;1;2;6]};{[6;5]};{[5;4;3;6]}], ...
        [1,NaN;1,2;2,NaN],[SEGMENT_TYPE.GRAIN_EDGE;SEGMENT_TYPE.GRAIN_GRAIN;SEGMENT_TYPE.GRAIN_EDGE]);
    loops = loop((1:2)', [{[1;2]};{[2;3]}]);
    parts = part((1:2)',[{[1]};{[2]}],[PART_TYPE.GRAIN;PART_TYPE.GRAIN]);

    % init an assemble
    assemble_temp = assemble(pts,segs,loops,parts);

end
