function loops = splitLoopBySegsInSeq(obj,loopIdx,segsSequence)

% init containor
loops = loop();
loops.append(obj.loops(loopIdx));

% obtain the end point
if segsSequence(1) > 0
    segsEndPoint1 = obj.segs(abs(segsSequence(1))).points(1);
else
    segsEndPoint1 = obj.segs(abs(segsSequence(1))).points(end);
end
if segsSequence(end) > 0
    segsEndPoint2 = obj.segs(abs(segsSequence(end))).points(end);
else
    segsEndPoint2 = obj.segs(abs(segsSequence(end))).points(1);
end

% split
newLoops = split(obj, loopIdx, abs(segsSequence), segsEndPoint1, segsEndPoint2);
loops = appendAndReplaceConsideringExistence(loops, newLoops);

end

% split sub function
function loops = split(obj, loopIdx, segsIdx, segsEndPoint1, segsEndPoint2)
    % init containor
    loops = loop(); 

    % init loops information
    [~, loopPoints, loopSegs, ~] = obj.retLoopPoints(loopIdx);
    
    % split the loop point
    [~, ~, newLoopIdxs1, newLoopIdxs2] = splitArrByItsVals(loopPoints,segsEndPoint1,segsEndPoint2);
    newLoopIdxs1 = newLoopIdxs1(1:end-1);
    newLoopIdxs2 = newLoopIdxs2(1:end-1);

    % new loop segs
    newLoopSegs1 = [unique(loopSegs(newLoopIdxs1));segsIdx];
    newLoopSegs2 = [unique(loopSegs(newLoopIdxs2));segsIdx];

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
