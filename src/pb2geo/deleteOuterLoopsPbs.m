% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% this function deletes the outer loops of the particle boundary
%
% Input: 
% pb - Type: n*2 array
%  Description: the coordinates of the points of a particle with 
%               outer small loop
%
% Output:
% pb_new
% - Type: n*2 array
%  Description: the coordinates of the points of a particle without 
%               outer small loop
% ------------------------------------------------------------------------
function pbs_new = deleteOuterLoopsPbs(pbs)
    pbs_new = cell(size(pbs));
    for i=1:size(pbs,1)
        pbs_new{i} = delete_outerloop_pb(pbs{i});
    end
end

function pb_new = delete_outerloop_pb(pb)
    % init
    pb_new = pb;
    % find the cross points
    [unique_rows, ~, idx] = unique(pb, 'rows');
    duplicated_rows = unique_rows(accumarray(idx, 1) > 1, 1:2);

    rows_to_delete = ismember(duplicated_rows, pb(1,1:2), 'rows');
    duplicated_rows(rows_to_delete,:) = [];

    delete_arr = false([size(pb,1) 1]);
    for i=1:size(duplicated_rows,1)
        arow = duplicated_rows(i,1:2);
        indices = find(pb(:,1) == arow(1) & pb(:,2) == arow(2));
        len1 = abs(indices(1) - indices(2)) - 1; 
        len2 = size(pb,1) - len1;
        if len2 > len1
            delete_arr(indices(1):(indices(2)-1)) = true;
        else
            delete_arr(1:indices(1)) = true;
            delete_arr(indices(2)+1:end) = true;
        end
    end
    pb_new(delete_arr,:) = [];
end