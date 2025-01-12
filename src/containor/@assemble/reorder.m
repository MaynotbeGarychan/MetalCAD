function reorder(obj)

% check whether is ordered
if chkReordered(obj); return; end

% copy information
obj_new = obj;

% reodrder points
new_id_arr = (1:length(obj_new.points.id))';
if ~isequal(obj_new.points.id, new_id_arr)
    map_arr = NaN([max(obj_new.points.id) 1]);
    map_arr(obj_new.points.id) = new_id_arr;
    % update
    obj_new.points.id = new_id_arr;
    for i=1:length(obj_new.segs)
        points = obj_new.segs(i).points;
        for j=1:length(points)
            points(j) = map_arr(points(j));
        end
        obj_new.segs(i).points = points;
    end
end

% reorder segs
new_id_arr = (1:length(obj_new.segs.id))';
if ~isequal(obj_new.segs.id, new_id_arr)
    map_arr = NaN([max(obj_new.segs.id) 1]);
    map_arr(obj_new.segs.id) = new_id_arr;
    % update
    obj_new.segs.id = new_id_arr;
    for i=1:length(obj_new.loops)
        segs = obj_new.loops(i).segs;
        for j=1:length(segs)
            if segs(j) < 0
                segs(j) = -map_arr(abs(segs(j)));
            else
                segs(j) = map_arr(segs(j));
            end
        end
        obj_new.loops(i).segs = segs;
    end
end

% reorder loops
new_id_arr = (1:length(obj_new.loops.id))';
if ~isequal(obj_new.loops.id, new_id_arr)
    map_arr = NaN([max(obj_new.loops.id) 1]);
    map_arr(obj_new.loops.id) = new_id_arr;
    % update
    obj_new.loops.id = new_id_arr;
    for i=1:length(obj_new.parts)
        loops = obj_new.parts(i).loops;
        for j=1:length(loops)
            loops(j) = map_arr(loops(j));
        end
        obj_new.parts(i).loops = loops;
    end
end

% copy back
obj = obj_new;
fprintf("reorder_geometry: reordered the geometry.\n");
end