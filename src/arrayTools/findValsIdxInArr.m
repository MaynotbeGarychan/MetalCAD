function indices = findValsIdxInArr(baseArr,searchArr)
    indices = arrayfun(@(x) find(baseArr == x), searchArr);
end

