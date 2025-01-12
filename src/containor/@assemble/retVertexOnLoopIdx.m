function ret = retVertexOnLoopIdx(obj, loopIdx, segId, vertexIdx)

[~, ~, pointsSeg, pointsInsegIdx] = obj.retLoopPoints(loopIdx);

ret = find((pointsSeg == segId) & (pointsInsegIdx == vertexIdx));

end

