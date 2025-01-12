function loops_with_seg = ret_seg_loops(obj, seg_id)

    % init
    loops_with_seg = [];
    
    % find it in all the loops
    ret = cellfun(@(x) (x == seg_id) | (x == -seg_id), obj.segs, 'UniformOutput',false);
    
    % summarize the results
    for i=1:numel(ret)
        bool = any(ret{i});
        if bool
            loops_with_seg = [loops_with_seg; obj.id(i)];
        end
    end

end