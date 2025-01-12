function uniqueValsArr = retUniqueAbsValsOfCellArr(cells)
uniqueValsArr = [];
for i=1:numel(cells)
    uniqueValsArr = [uniqueValsArr; abs(cells{i})];
end
uniqueValsArr = unique(uniqueValsArr);
end

