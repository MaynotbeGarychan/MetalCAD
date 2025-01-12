function [replace_bool, new_id] = equiv(obj,thres)
    % obtain points should be replaced, and the what point can replace it
    [replace_bool, new_idx] = equiv_sub(obj.coordinate(:,1), obj.coordinate(:,2), thres);
    new_id = obj.id(new_idx);
end

function [replace_bool, new_id] = equiv_sub(x, y, threshold)
    % Number of points
    num = length(x);
    % Initialize output arrays
    replace_bool = false(num, 1); % Boolean array for points to be replaced
    new_id = (1:num)'; % Array to hold the replacement indices
    % Iterate through each point
    for i = 1:num
        if ~replace_bool(i) % Only process points that have not been replaced
            for j = i+1:num
                if ~replace_bool(j) % Only consider points not yet replaced
                    % Calculate the Euclidean distance between points i and j
                    distance = sqrt((x(i) - x(j))^2 + (y(i) - y(j))^2);
                    if distance <= threshold
                        % Replace point j with point i
                        replace_bool(j) = true;
                        new_id(j) = i;
                    end
                end
            end
        end
    end
end