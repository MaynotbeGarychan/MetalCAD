function bool = chkReordered(obj)
    % chk whether is reordered by checking the id array
    bool1 = chk_continuous_arr(obj.points.id);
    bool2 = chk_continuous_arr(obj.segs.id);
    bool3 = chk_continuous_arr(obj.loops.id);
    bool4 = chk_continuous_arr(obj.segs.id);

    bool = bool1 & bool2 & bool3 & bool4;
end

function is_continuous = chk_continuous_arr(arr)
    % Sort the array
    sorted_arr = sort(arr);
    
    % Create the expected array from 1 to n
    expected_arr = (1:length(arr))';
    
    % Check if the sorted array matches the expected array
    is_continuous = isequal(sorted_arr, expected_arr);
end
