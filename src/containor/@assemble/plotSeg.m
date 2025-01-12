function plotSeg(assemble, segsIdxs, color)

for i=1:length(segsIdxs)
    seg_idx = segsIdxs(i);
    points = assemble.segs(seg_idx).points;
    
    coor = assemble.points(points).coordinate(:,1:2);
    
    plot(coor(:,1), coor(:,2), "LineWidth", 1, 'Color', color, 'Marker', 'o', 'MarkerSize', 2);
    
    hold on

end

end