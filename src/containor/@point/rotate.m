function rotate(obj,pt_origin,deg)
    
    num_pts = obj.num;
    coor_pts = [obj.coordinate, ones([num_pts 1])];
    
    M = rotationMatrix2D(pt_origin(1),pt_origin(2),deg2rad(deg));
    coor_pts_rotated = coor_pts * M;

    obj.coordinate = coor_pts_rotated(:,1:2);
end

function M = rotationMatrix2D(x0,y0,theta)
    % 平移矩阵 T1
    T1 = [1, 0, -x0; 0, 1, -y0; 0, 0, 1];
    
    % 旋转矩阵 R
    R = [cos(theta), -sin(theta), 0; sin(theta), cos(theta), 0; 0, 0, 1];
    
    % 平移矩阵 T2
    T2 = [1, 0, x0; 0, 1, y0; 0, 0, 1];
    
    % 组合变换矩阵
    M = T2 * R * T1;
end