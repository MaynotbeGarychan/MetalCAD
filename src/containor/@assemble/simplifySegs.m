% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% simplify the segments by delete some points which is not important to the
% overall geometry, for example, the two adjacent line is in a very similar
% direction
%
% Input: 
% obj.points, all_segs - Type: array of points and segments
%  Description: the information of the points and segment of the geometry
% deg_thres - Type: double
%  Description: a threshold to judge the similar direction
%
% Output:
% [obj_new.points, obj_new.segs]
% - Type: array of points, segments
%  Description: the geometric information of the geometry after
%  simplification
% ------------------------------------------------------------------------
function simplifySegs(obj, deg_thres)
    % copy
    obj_new = obj;
    % find useless points
    all_points_delete = [];
    for i=1:length(obj.segs)
        points_in_loop = obj.segs(i).points;
        points_c = points_in_loop(2:end-2);
        points_b = points_in_loop(1:end-3);
        points_f = points_in_loop(3:end-1);
        pos_c = obj.points(points_c).coordinate;
        pos_b = obj.points(points_b).coordinate;
        pos_f = obj.points(points_f).coordinate;
        vec_b = pos_c - pos_b;
        vec_f = pos_f - pos_c;
        theta = cal_angle_distance(vec_b(:,1),vec_b(:,2),vec_f(:,1),vec_f(:,2));
        condition = theta < deg_thres;
        points_delete = points_c(condition);
        all_points_delete = [all_points_delete;points_delete];
        % delete
        bool_arr = ismember(points_in_loop,points_delete);
        points_in_loop(bool_arr) = [];
        obj_new.segs(i).points = points_in_loop;
    end
    obj_new.points(all_points_delete) = [];
    % copy back
    obj = obj_new;
    fprintf("simplify_segments: simplified the segments and points by delete some points which is not important for the geometry.\n");
end

function deg = cal_angle_distance(x1,y1,x2,y2)
    dot_prod = x1.*x2 + y1.*y2;
    norm1 = sqrt(x1.^2 + y1.^2);
    norm2 = sqrt(x2.^2 + y2.^2);
    deg = rad2deg(acos(dot_prod./(norm1.*norm2)));
end