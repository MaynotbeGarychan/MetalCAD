function simplifyGb(obj)
% copy information
obj_new = obj;
% analyze the gb, obtain the simplified points, given the simplified points
% to the segments
delete_point_arr = [];
for i=1:length(obj_new.segs)
    points = obj_new.segs(i).points;
    if (obj_new.segs(i).type == SEGMENT_TYPE.GRAIN_GRAIN) && (length(points) > 4)
        inner_points = points(2:end-1);
        new_idx = 1:2:length(inner_points);
        del_idx = setdiff(1:length(inner_points),new_idx);
        new_points = [points(1); inner_points(new_idx); points(end)];
        obj_new.segs(i).points = new_points;
        delete_point_arr = [delete_point_arr; inner_points(del_idx)];
    end
end
% delete points
obj_new.points(delete_point_arr) = [];
% copy back
obj = obj_new;
fprintf("simplify_gb: simplified the segment by directly deleting some points with specific steps.\n");
end

function theta = vect2theta(x1,y1,x2,y2)
    dot_prod = x1.*x2+y1.*y2;
    norm1 = sqrt(x1.^2+y1.^2);
    norm2 = sqrt(x2.^2+y2.^2);
    val = dot_prod./(norm1.*norm2);
    theta = real(rad2deg(acos(val)));
end