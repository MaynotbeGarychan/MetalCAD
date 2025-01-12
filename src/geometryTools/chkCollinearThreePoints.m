function is_collinear = chkCollinearThreePoints(P1,P2,P3)
    % init
    x1 = P1(1); y1 = P1(2);
    x2 = P2(1); y2 = P2(2);
    x3 = P3(1); y3 = P3(2);

    % Calculate the area of the triangle
    area = 0.5 * abs(x1*(y2 - y3) + x2*(y3 - y1) + x3*(y1 - y2));
    
    % Check if the area is zero (collinear points)
    is_collinear = (area == 0);
end

