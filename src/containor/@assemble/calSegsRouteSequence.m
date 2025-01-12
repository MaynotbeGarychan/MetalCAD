function sequence = calSegsRouteSequence(obj, segsIdx, startPointIdx, endPointIdx)
% find the route of a series of segs, only support one way
    segsIdx = abs(segsIdx);
    % init the head matrix
    twoHeadsMatrix = NaN(length(segsIdx),2);
    for i=1:length(segsIdx)
        twoHeadsMatrix(i,1) = obj.segs(segsIdx(i)).points(1);
        twoHeadsMatrix(i,2) = obj.segs(segsIdx(i)).points(end);
    end
    % init the used matrix
    usedArr = false(length(segsIdx),1);
    % init the first
    sequence = [];
    [row,col] = find(twoHeadsMatrix == startPointIdx);
    if ~isscalar(row); error('calSegsRouteSequence: Multi begining segs detected.\n');end
    if col == 1
        sequence = [sequence; segsIdx(row)];
        currEndPoint = twoHeadsMatrix(row,2);
    else
        sequence = [sequence; -segsIdx(row)];
        currEndPoint = twoHeadsMatrix(row,1);
    end
    usedArr(row) = true;
    if isscalar(segsIdx)
        return
    end
    % begin to find the incoming segs
    while currEndPoint ~= endPointIdx
        [rows,cols] = find(twoHeadsMatrix == currEndPoint);
        idx = find(~usedArr(rows));
        row = rows(idx); col = cols(idx);
        if ~isscalar(row); error('calSegsRouteSequence: Multi begining segs detected.\n');end
        if col == 1
            sequence = [sequence; segsIdx(row)];
            currEndPoint = twoHeadsMatrix(row,2);
        else
            sequence = [sequence; -segsIdx(row)];
            currEndPoint = twoHeadsMatrix(row,1);
        end
        usedArr(row) = true;
    end

end