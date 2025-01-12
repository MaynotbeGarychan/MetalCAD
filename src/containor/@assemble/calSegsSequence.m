function sequence = calSegsSequence(obj, segsIdx)
    segs = obj.segs(segsIdx);
    sequence = orderLoopSegsInSequence(segs);
end

function aloop_segs = orderLoopSegsInSequence(segs)
    sequence = correctSequence(segs.points);
    aloop_segs = reorderSegs(segs.id, sequence);
end

function sequence = correctSequence(segs_points)
    
    % forming the segs end points
    num_segs = numel(segs_points); 
    seg_endpoints = NaN(num_segs,2);
    for i=1:num_segs
        points = segs_points{i};
        seg_endpoints(i,1) = points(1);
        seg_endpoints(i,2) = points(end);
    end

    % init a bool array to check whether this seg is used
    num_segs = size(seg_endpoints,1); 
    used_arr = false(num_segs,1);
    
    % begin with the first segs
    sequence = 1;
    curr_seg_idx = 1;
    curr_point_id = seg_endpoints(curr_seg_idx,2);
    used_arr(curr_seg_idx) = true;
    
    % begin to check
    while any(used_arr == false)
        [rows,cols] = find(seg_endpoints == curr_point_id);
        not_itself = (rows ~= curr_seg_idx);
        row_idx = rows(not_itself);
        col_idx = cols(not_itself);
        
        % check some error situation
        if used_arr(row_idx)
            error('current segment has been appended into the sequence.\n');
        end
        if isempty(row_idx)
            error('cannot find the segs for linkage.\n');
        elseif ~isscalar(row_idx)
            error('multiple linkage occurs.\n');
        end
        
        % save
        used_arr(row_idx) = true;
        if col_idx == 1
            sequence = [sequence; row_idx];
            curr_point_id = seg_endpoints(row_idx,2);
        
        elseif col_idx == 2
            sequence = [sequence; -row_idx];
            curr_point_id = seg_endpoints(row_idx,1);
        else
            error('\n');
        end
    
        % update
        curr_seg_idx = row_idx;
    end

end

function aloop_segs = reorderSegs(segs_id, sequence)
    aloop_segs = zeros([length(segs_id) 1]);
    for i=1:length(segs_id)
        val = sequence(i);
        idx = abs(val);
        aloop_segs(i) = segs_id(idx);
        if val<0; aloop_segs(i) = -aloop_segs(i); end
    end
end