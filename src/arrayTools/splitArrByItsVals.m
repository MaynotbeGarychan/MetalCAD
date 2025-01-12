function [arr1, arr2, arr1Idxs, arr2Idxs] = splitArrByItsVals(arr,val1,val2)
% e.g.: arr=[1,5,6,2,4], val1 = 5, val2 = 2, return arr1 = [5,6,2], arr2 = [2,4,1,5] 
    
    numVal = length(arr);                                                   % init
    val1Pos = find(arr==val1); val2Pos = find(arr==val2);                   % check its position

    if (length(val1Pos) ~= 1) || (length(val2Pos) ~= 1)                     % check situation multiple vals in the arry
        error('splitArrByItsVals: Multiple values detected.\n');            % don't know which to be cut
    end

    minValPos = min([val1Pos,val2Pos]); maxValPos = max([val1Pos,val2Pos]); % ret its start and end position
    arr1Idxs = (minValPos:maxValPos)'; arr1 = arr(arr1Idxs);                % obatin array 1
    arr2Idxs = [(maxValPos:numVal)';(1:minValPos)']; arr2 = arr(arr2Idxs);  % obtain array 2

end