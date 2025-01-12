function [flag, existed_id] = chk_duplicated(points, onepoint, thres)

    % init
    existed_id = NaN;
    x = onepoint.coordinate(1,1); y = onepoint.coordinate(1,2);

    % calculate distance
    x_list = points.coordinate(:,1); y_list = points.coordinate(:,2);
    distance = sqrt((x_list - x).^2 + (y_list - y).^2);
    bool_arr = distance < thres;

    % check if there is duplicated points
    flag = any(bool_arr);
    if flag
        existed_id = points.id(bool_arr);
    end

end