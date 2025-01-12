function coor = retSegCoordinate(obj,seg_idx)

% chk reorderer
if ~obj.chkReordered()
    error('retSegCoordinate: this function is only validated when the assemble is reordered.\n');
end

% obtain the points id
points = obj.segs(seg_idx).points;

% return the segment coordinate
coor = obj.points(points).coordinate;

end