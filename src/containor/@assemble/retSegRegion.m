function regions_segs = retSegRegion(obj)

regions_segs = NaN([2 2 obj.segs.num]);
for i=1:obj.segs.num
    pts = obj.segs(i).points;
    coors = obj.points(pts).coordinate; 
    regions_segs(:,:,i) = [min(coors(:,1)), max(coors(:,1)); min(coors(:,2)), max(coors(:,2))];
end

end

