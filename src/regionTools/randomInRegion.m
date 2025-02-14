function coor = randomInRegion(region,numPoints)

x1 = region(1,1); x2 = region(1,2);
y1 = region(2,1); y2 = region(2,2);

randomX = x1 + (x2 - x1) * rand(1, numPoints); % 生成 x 坐标
randomY = y1 + (y2 - y1) * rand(1, numPoints); % 生成 y 坐标

coor = [randomX;randomY];

end