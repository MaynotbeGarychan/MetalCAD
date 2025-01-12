function val = distance(obj,basePIdx,otherPIdx)

coor1 = obj.coordinate(basePIdx,1:2);
coor2 = obj.coordinate(otherPIdx,1:2);

val = sqrt((coor1(1)-coor2(:,1)).^2+(coor1(2)-coor2(:,2)).^2);

end