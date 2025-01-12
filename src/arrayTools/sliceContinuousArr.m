% ------------------------------------------------------------------------
% Author: Chen, Jiawei
%
% Description: 
% slices the continuous parts inside an array by referring to a give value
%
% Input: 
% arr - Type: array
%  Description: a given array with some continuous parts of certain value
% val - Type: real
%  Description: the given value, see function description
% Output:
% result - Type: a cell with multiple array
%  Description: the slice parts stored as several array in the cell
% ------------------------------------------------------------------------
function [result, discontinuity] = sliceContinuousArr(arr, val)
    ids = find(arr==val);
    % Initialize variables
    result = {};  % Cell array to store the result
    discontinuity = []; % array to store the beginning ending discontinuity
    if isempty(ids); return; end
    current_slice = ids(1);  % Start with the first element
    for i = 2:length(ids)
        if ids(i) == ids(i-1) + 1
            % If the current element is continuous with the previous one, add it to the current slice
            current_slice(end+1) = ids(i);
        else
            % If not, save the current slice and start a new one
            result{end+1} = current_slice';
            current_slice = ids(i);
        end
    end
    % Add the last slice
    result{end+1} = current_slice';
    % check start and end continuous?
    if arr(1) == val && arr(end) == val
        result{1} = [result{end};result{1}];
        result(end) = [];
    end
    % obtain the begin and ending discontinuity
    arr_len = length(arr);
    for i=1:numel(result)
        continuous_arr_ids = result{i};
        begin_id = continuous_arr_ids(1)-1; end_id = continuous_arr_ids(end)+1;
        if begin_id == 0; begin_id = arr_len; end
        if end_id == arr_len + 1; end_id = 1; end
        discontinuity = [discontinuity;begin_id,end_id];
    end
end