function segs = split(obj, segIdx, posIdx, insertPointId)

% init a containor
segs = segment();

% get the original seg
currSeg = obj(segIdx);

% obtain the points of the segment
points = obj.points(segIdx);
points = points{1};

% 
if points(1) == points(end)
    seg1
else

end


% make two new segs
seg1 = segment(obj.id(segIdx), {[points(1:posIdx);insertPointId]}, obj.parts(segIdx,:), obj.type(segIdx));
seg2 = segment(length(obj.id)+1, {[insertPointId;points(posIdx+1:end)]}, obj.parts(segIdx,:), obj.type(segIdx));

end