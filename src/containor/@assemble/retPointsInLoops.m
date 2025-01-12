function points_id = retPointsInLoops(obj,loop_idx)
% return the points inside the loop region

[loop_coor, ~, ~, ~] = obj.retLoopPoints(loop_idx);

[bool_all, bool_on] = inpolygon(obj.points.coordinate(:,1), obj.points.coordinate(:,2), loop_coor(:,1), loop_coor(:,2));
bool_in = (bool_all & (~bool_on));

points_id = obj.points.id(bool_in);

end