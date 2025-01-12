function bool = chkLoopInsideLoop(obj,loop1Idx,loop2Idx)

% init
bool = false;
[loop1Coor,~,~,~] = obj.retLoopPoints(loop1Idx);
[loop2Coor,~,~,~] = obj.retLoopPoints(loop2Idx);

% check point inside the loops
[all, on] = inpolygon(loop1Coor(:,1), loop1Coor(:,2), loop2Coor(:,1), loop2Coor(:,2));
in = all & (~on);

% if any points outside, loops would not be inside
if any(~all) 
    return
end

% now we know all the points is contained at the loop
% if any points inside the loop, the loops is inside
if any(in)
    bool = true;
    return
end

% sometimes there is no point in or out but we can check it using polygon
% method
polygon1 = obj.retLoopPolygon(loop1Idx);
polygon2 = obj.retLoopPolygon(loop2Idx);

itsecPolygon = intersect(polygon1,polygon2);
if itsecPolygon.NumRegions == 0
    bool = false;
else
    bool = true;
end

end

