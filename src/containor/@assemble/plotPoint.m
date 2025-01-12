function plotPoint(assemble,pid,color)

for i=1:length(pid)
    pcoor = assemble.points(pid(i)).coordinate(:,1:2);
    scatter(pcoor(1,1), pcoor(1,2), 'filled', 'o', 'MarkerFaceColor', color); hold on
end

end

