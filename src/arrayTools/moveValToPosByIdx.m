function arr = moveValToPosByIdx(arr, value, toIndex)
    % Find the index of the value
    fromIndex = find(arr == value, 1);
    
    % Check if the value exists in the array
    if isempty(fromIndex)
        disp('Value not found in the array');
        return;
    end
    
    % Remove the element from its current position
    arr(fromIndex) = [];
    
    % Insert the element at the new position
    arr = [arr(1:toIndex-1); value; arr(toIndex:end)];
end