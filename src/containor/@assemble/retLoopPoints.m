function [pointsCoor, points, pointsSeg, pointsInsegIdx] = retLoopPoints(obj, idx, varargin)
    if nargin == 2
        [pointsCoor, points, pointsSeg, pointsInsegIdx] = retLoopPointsReordered(obj,idx);
    else
        str1 = varargin{1}; 
        if strcmp(str1,'Unreordered')
            [pointsCoor, points, pointsSeg, pointsInsegIdx] = retLoopPointsUnreordered(obj, idx);
        end
    end
end


function [pointsCoor, points, pointsSeg, pointsInsegIdx] = retLoopPointsReordered(obj, idx)
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

function [loopPtsCoor, loopPtsId, loopPtsSegs, loopPtsInSegIdx] = retLoopPointsUnreordered(obj, idx)
% Obtain the corresponding segs
loopIdx = idx;
loopSegsId = abs(obj.loops(loopIdx).segs);
flipBool = (obj.loops(loopIdx).segs < 0);
% Obtain the corresponding pts
loopPtsId = []; loopPtsSegs = []; loopPtsInSegIdx = [];
for i=1:length(loopSegsId)
    % Append the pts id
    curr_loop_segs_idx = find(obj.segs.id == loopSegsId(i));
    temp = obj.segs(curr_loop_segs_idx).points;
    numPts = length(temp);
    if flipBool(i) == 1
        temp = flip(temp);
    end
    loopPtsId = [loopPtsId; temp(1:end-1)];
    % Append the seg id of each pts
    loopPtsSegs = [loopPtsSegs; loopSegsId(i)*ones([numPts 1])];
    % point in its own segment position index
    inSegIdxs = (1:numPts)';
    if flipBool; inSegIdxs = flip(inSegIdxs); end
    loopPtsInSegIdx = [loopPtsInSegIdx; inSegIdxs];
end
% Obtain the pts coordinate
numPts = length(loopPtsId);
loopPtsCoor = NaN([numPts 2]);
for i=1:numPts
    pts_idx = find(obj.points.id == loopPtsId(i));
    loopPtsCoor(i,:) = obj.points.coordinate(pts_idx,:);
end

end