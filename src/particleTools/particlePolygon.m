function [assembleOne,boundaryCoor] = particlePolygon(x0,y0,radius)

    

end

function [points, segments] = generatePolygon(n, radius)
    % Generates the points and segments of an n-sided regular polygon
    % n - number of sides
    % radius - radius of the circumscribed circle
    % Initialize arrays for points and segments
    points = zeros(n, 2);
    % segments = zeros(n, 2, 2);
    % Calculate the angle between each point
    angle = 2 * pi / n;
    % Generate the points
    for i = 1:n
        points(i, 1) = radius * cos((i-1) * angle);
        points(i, 2) = radius * sin((i-1) * angle);
    end
    % 
    % % Generate the segments
    % for i = 1:n
    %     segments(i, 1, :) = points(i, :);
    %     segments(i, 2, :) = points(mod(i, n) + 1, :);
    % end
end
