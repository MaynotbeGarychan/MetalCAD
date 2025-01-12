function [pointsCoor, points, pointsSeg, pointsInsegIdx] = retLoopPoints(obj, idx)
    aloop_segs = obj.loops(idx).segs;
    pointsCoor = []; points = []; pointsSeg = []; pointsInsegIdx = [];
    for i=1:length(aloop_segs)
        seg_id = aloop_segs(i); seg_id_abs = abs(seg_id);
        temp = obj.segs(seg_id_abs).points;
        if seg_id < 0; temp = flip(temp); end
        temp = temp(1:end-1); num_points = length(temp);
        points = [points; temp];
        % points coordinates
        pointsCoor = [pointsCoor; obj.points.coordinate(temp,1:2)];
        % the segment id of the points
        pointsSeg = [pointsSeg; seg_id_abs*ones([num_points 1])];
        % point in its own segment position index
        inseg_idx = (1:length(temp))';
        if seg_id < 0; inseg_idx = flip(inseg_idx); end
        pointsInsegIdx = [pointsInsegIdx; inseg_idx];
    end
end