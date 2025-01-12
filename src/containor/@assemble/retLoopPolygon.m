function polygon = retLoopPolygon(obj, loop_idx)

[points_coor, ~, ~, ~] = obj.retLoopPoints(loop_idx);
polygon = polyshape(points_coor(:,1), points_coor(:,2));

end

