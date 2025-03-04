function area_arr = calPbsArea(pbs)

num = numel(pbs);
area_arr = NaN([num 1]);

for i=1:num
    pb = pbs{i};
    area_arr(i) = polyarea(pb(:,1), pb(:,2));
end

end

