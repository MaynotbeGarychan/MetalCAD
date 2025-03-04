function uniqueValsArr = retUniqueAbsValsOfCellArr(cells)

if isscalar(cells)
    if iscell(cells)
        uniqueValsArr = abs(cells{1});
    else
        uniqueValsArr = abs(cells);
    end
    return
end

if iscell(cells(1))
    uniqueValsArr = [];
    for i=1:numel(cells)
        uniqueValsArr = [uniqueValsArr; abs(cells{i})];
    end
    uniqueValsArr = unique(uniqueValsArr);
    return
end

if isscalar(cells(1))
    uniqueValsArr = unique(abs(cells));
    return
end

end

