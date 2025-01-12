function segs = splitSegByPoint(obj, segIdx, pId, pPosIdx)

    numItsec = length(pId);

    if numItsec == 1
        segs = splitSegByOnePoint(obj, segIdx, pId, pPosIdx);
    elseif numItsec > 1
        segs = splitSegByMultiplePoint(obj, segIdx, pId, pPosIdx);
    else
        error('@assemble-splitSegByPoint: please check the number of pid input.\n')
    end

end

function segs = splitSegByOnePoint(obj, segIdx, pId, pPosIdx)
    
    % init 
    segs = segment(); 
    currSeg = obj.segs(segIdx);                                             % seg obj to be split
    points = currSeg.points{1};

    % copy two segs to be modified
    seg1 = currSeg.copy(); seg2 = currSeg.copy();

    % constuct two segs
    seg1.id = currSeg.id; seg1.points = {[points(1:pPosIdx);pId]};
    seg2.id = length(obj.segs) + 1; seg2.points = {[pId;points(pPosIdx+1:end)]};

    % save result
    obj.segs(segIdx) = seg1;
    obj.segs.append(seg2);
    segs.append(seg1); segs.append(seg2);

end

function segs = splitSegByMultiplePoint(obj, segIdx, pId, pPosIdx)

    % sort the sequence
    [pPosIdxSorted, sequence] = sort(pPosIdx);
    pIdSorted = pId(sequence);

    % some intersection occurred at the same vertices, we have to sort them
    % by calculating the distance
    points = obj.segs(segIdx).points;
    [sharedVertexIdxs, indices] = findDuplicates(pPosIdxSorted);
    % check the sequence
    for i=1:length(sharedVertexIdxs)
        sharedVertex = sharedVertexIdxs(i);
        sharedVertexPId = points(sharedVertex);                             % ref points
        pIdInOneSeg = pIdSorted(indices{i});                                % points to be sorted
        distance = obj.points.distance(sharedVertexPId, pIdInOneSeg);
        % sort based on the distances
        [~, sortArr] = sort(distance);
        pIdInOneSegSorted = pIdInOneSeg(sortArr);
        pIdSorted(indices{i}) = pIdInOneSegSorted;
    end

    % begin to split the seg
    % init
    segs = segment(); 
    currSeg = obj.segs(segIdx);                                             % seg obj to be split
    points = currSeg.points{1};                                             % point of this seg
    % begin to crop the segment
    pointsInsideSeg = cutArrayIntoMultipleByIndices(points, pPosIdxSorted); % cut the points into multiple
    numNewSegs = numel(pointsInsideSeg);
    beginItsecPoint = points(1); endItsecPoints = [pIdSorted;points(end)];  % begin with the first point
    idArr = [currSeg.id; (length(obj.segs)+1:length(obj.segs)+numNewSegs-1)'];
    for i=1:numNewSegs
        endItsecPoint = endItsecPoints(i);
        pointsOfTheSeg = {[beginItsecPoint;pointsInsideSeg{i};endItsecPoint]};
        beginItsecPoint = endItsecPoint;
        % construct the segs
        newSeg = currSeg.copy(); 
        newSeg.id = idArr(i); newSeg.points = pointsOfTheSeg;
        segs.append(newSeg);
    end

    % check whether is a end-to-end segment
    if points(1) == points(end)
        pointsOfTheSeg = [segs(end).points;segs(1).points];
        segs(1).points = pointsOfTheSeg;
        segs(end) = [];
    end
    
    % save the result
    obj.segs(segIdx) = segs(1);
    obj.segs.append(segs(2:end));

end

function [values, indices] = findDuplicates(arr)
    % Find unique values and their first occurrence indices
    [uniqueValues, firstIndices] = unique(arr, 'first');
    
    % Find unique values and their last occurrence indices
    [~, lastIndices] = unique(arr, 'last');
    
    % Find duplicates by comparing first and last occurrence indices
    duplicateIndices = firstIndices ~= lastIndices;
    
    % Extract duplicate values and their indices
    values = uniqueValues(duplicateIndices);
    indices = arrayfun(@(x) find(arr == x), values, 'UniformOutput', false);
end


function subArrays = cutArrayIntoMultipleByIndices(arr, indices)
    % Using Logical Indexing
    subArrays = cell(1, length(indices) + 1);
    startIdx = 1;
    for i = 1:length(indices)
        endIdx = indices(i);
        subArrays{i} = arr(startIdx:endIdx);
        startIdx = endIdx + 1;
    end
    subArrays{end} = arr(startIdx:end);
end