function assemble1 = fixAssembleRegion2Rect(assemble0)
% init
assemble1 = assemble0.copy();
[region,~,~] = assemble1.retRegion();
x_min = region(1,1); x_max = region(1,2);
y_min = region(2,1); y_max = region(2,2);
fprintf('fixAssembleRegion2Rect: Begined to fix the the region of the assemble to a tatic rectangle (%d,%d) to (%d,%d).\n', ...
    x_min,y_min,x_max,y_max);
% obtain x,y
x = assemble1.points.coordinate(:,1);
y = assemble1.points.coordinate(:,2);
%   D 4 C
%     --
%  1 |  | 3
%     --
%   A 2 B
% line 1,2,3,4
condition_l1 = (x == x_min);
condition_l2 = (y == y_min);
condition_l3 = (x == x_max);
condition_l4 = (y == y_max);
% check A
condition_A = (condition_l1) & (condition_l2);
if ~any(condition_A) % fix A
    pts_idx_l2 = find(condition_l2);
    pts_x_l2 = assemble1.points(condition_l2).coordinate(:,1);
    [~,idx] = min(pts_x_l2);
    pts_minx_idx_l2 = pts_idx_l2(idx);
    assemble1.points.coordinate(pts_minx_idx_l2,1) = x_min;
end
% check B
condition_B = (condition_l2) & (condition_l3);
if ~any(condition_B)
    pts_idx_l2 = find(condition_l2);
    pts_x_l2 = assemble1.points(condition_l2).coordinate(:,1);
    [~,idx] = max(pts_x_l2);
    pts_max_idx_l2 = pts_idx_l2(idx);
    assemble1.points.coordinate(pts_max_idx_l2,1) = x_max;
end
% check C
condition_C = (condition_l4) & (condition_l3);
if ~any(condition_C)
    pts_idx_l4 = find(condition_l4);
    pts_x_l4 = assemble1.points(condition_l4).coordinate(:,1);
    [~,idx] = max(pts_x_l4);
    pts_max_idx_l4 = pts_idx_l4(idx);
    assemble1.points.coordinate(pts_max_idx_l4,1) = x_max;
end
% check C
condition_C = (condition_l4) & (condition_l3);
if ~any(condition_C)
    pts_idx_l4 = find(condition_l4);
    pts_x_l4 = assemble1.points(condition_l4).coordinate(:,1);
    [~,idx] = max(pts_x_l4);
    pts_max_idx_l4 = pts_idx_l4(idx);
    assemble1.points.coordinate(pts_max_idx_l4,1) = x_max;
end
% check D
condition_D = (condition_l4) & (condition_l1);
if ~any(condition_D)
    pts_idx_l4 = find(condition_l4);
    pts_x_l4 = assemble1.points(condition_l4).coordinate(:,1);
    [~,idx] = min(pts_x_l4);
    pts_min_idx_l4 = pts_idx_l4(idx);
    assemble1.points.coordinate(pts_min_idx_l4,1) = x_min;
end

fprintf('fixAssembleRegion2Rect: Finished to fix the the region of the assemble to a tatic rectangle (%d,%d) to (%d,%d).\n', ...
    x_min,y_min,x_max,y_max);
end

