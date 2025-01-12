function bool = chkSegInsideLoop(obj, loopIdx, segIdx)
% check whether a seg is inside a loop

bool = false;

segPoints = obj.segs(segIdx).points;
segCoor = obj.points(segPoints).coordinate(:,1:2);

[loopCoor, loopPoints, ~,~] = obj.retLoopPoints(loopIdx);

[in, on] = inpolygon(segCoor(:,1), segCoor(:,2), loopCoor(:,1), loopCoor(:,2));

if ~any(~in)
    bool = true;
    return
end

if length(find(on)) == 2
    idx1 = find(loopPoints == segPoints(1)); idx2 = find(loopPoints == segPoints(end));
    dist = min([abs(idx1-idx2), length(loop_points)-abs(idx1-idx2)]);
    if dist > 0
        bool = true;
        return
    end
end

end

