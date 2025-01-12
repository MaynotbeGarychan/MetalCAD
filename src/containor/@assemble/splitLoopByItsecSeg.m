function loops = splitLoopByItsecSeg(obj, loopIdx, segsIdxs)

% init containor
loops = loop();
loops.append(obj.loops(loopIdx));

% split
if isscalar(segsIdxs) % only one segment directly split
    newLoops = split(obj, loopIdx, segsIdxs, obj.segs(segsIdxs).points(1), obj.segs(segsIdxs).points(end));
    loops = appendAndReplaceConsideringExistence(loops, newLoops);
else % multiple segments use dynamic method
    segUsedArr = false(length(segsIdxs),1);
    while any(segUsedArr == false)
        % update the unused segs
        segsUnusedIdxs = segsIdxs(segUsedArr == false);
        % begin to split
        for i=1:length(segsUnusedIdxs)
            % the existed loop can be split
            currLoopsIdxs = loops.id;
            % obtain the seg information
            segIdx = segsUnusedIdxs(i);
            segEndPoint1 = obj.segs(segIdx).points(1); segEndPoint2 = obj.segs(segIdx).points(end);
            % find the loop and split
            loopCanBeSplit = retLoopsCanBeSplit(obj, currLoopsIdxs, segEndPoint1, segEndPoint2);
            if ~isempty(loopCanBeSplit)
                newLoops = split(obj, loopCanBeSplit, segIdx, segEndPoint1, segEndPoint2);
                loops = appendAndReplaceConsideringExistence(loops, newLoops);
                % update
                segUsedArr(segsIdxs == segIdx) = true;
            end
        end
    end
end

end

% split sub function
function loops = split(obj, loopIdx, segId, segEndPoint1, segEndPoint2)
    % init containor
    loops = loop(); 

    % init loops information
    [~, loopPoints, loopSegs, ~] = obj.retLoopPoints(loopIdx);
    
    % split the loop point
    [~, ~, newLoopIdxs1, newLoopIdxs2] = splitArrByItsVals(loopPoints,segEndPoint1,segEndPoint2);
    newLoopIdxs1 = newLoopIdxs1(1:end-1);
    newLoopIdxs2 = newLoopIdxs2(1:end-1);

    % new loop segs
    newLoopSegs1 = [unique(loopSegs(newLoopIdxs1));segId];
    newLoopSegs2 = [unique(loopSegs(newLoopIdxs2));segId];

    % construct loops
    currLoop = obj.loops(loopIdx);
    newLoop1 = currLoop.copy();
    newLoop1.id = loopIdx;
    newLoop1.segs = {calSegsSequence(obj, newLoopSegs1)};
    loops.append(newLoop1);
    newLoop2 = currLoop.copy();
    newLoop2.id = length(obj.loops) + 1;
    newLoop2.segs = {calSegsSequence(obj, newLoopSegs2)};
    loops.append(newLoop2);

    % append result
    obj.loops(loopIdx) = newLoop1;
    obj.loops.append(newLoop2);

end

% return the loop whicn can be split
function loopCanBeSplit = retLoopsCanBeSplit(obj, loopIdxs, segEndPoint1, segEndPoint2)
    loopCanBeSplit = [];
    for i=1:length(loopIdxs)
        loopIdx = loopIdxs(i);
        [~,loopPoints,~,~] = obj.retLoopPoints(loopIdx);
        if chkSplitPossibility(loopPoints, segEndPoint1, segEndPoint2)
            loopCanBeSplit = [loopCanBeSplit;loopIdx];
        end
    end
    if length(loopCanBeSplit) > 1
        error('retLoopsCanBeSplit: Possibily the loops are wrong.\n')
    end
end

function bool = chkSplitPossibility(arr, val1, val2)
    bool = false;
    idx1 = find(arr == val1); idx2 = find(arr == val2);
    if isscalar(idx1) && isscalar(idx2)
        bool = true;
    end

    % if ~isempty(idx1) && ~isempty(idx2)
    %     if periodicDistance(length(arr), idx1, idx2) > 1
    %         bool = true;
    %     else
    %         error('@assemble-splitLoopByItsecSeg-retLoopsCanBeSplit-chkSplitPossibility: A seg on the loop is prohibited.\n');
    %     end
    % end
end

% tools
