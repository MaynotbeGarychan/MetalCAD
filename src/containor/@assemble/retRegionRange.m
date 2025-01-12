function [region_range,center_pos] = retRegionRange(obj)

region_range = [min(obj.points.coordinate(:,1)), max(obj.points.coordinate(:,1));
    min(obj.points.coordinate(:,2)), max(obj.points.coordinate(:,2))];
center_pos = [(region_range(1,1)+region_range(1,2))/2; (region_range(2,1)+region_range(2,2))/2];

end

