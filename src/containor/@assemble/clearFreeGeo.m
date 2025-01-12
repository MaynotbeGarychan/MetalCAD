function obj = clearFreeGeo(obj)

% clear loop
usedLoopIds = retUniqueAbsValsOfCellArr(obj.parts.loops);
loopIds = obj.loops.id;
unUsedLoopIds = setdiff(loopIds,usedLoopIds);
if ~isempty(unUsedLoopIds)
    unUsedLoopIdxs = idsToIdxs(loopIds, unUsedLoopIds);
    obj.loops(unUsedLoopIdxs) = [];
end

% clear segs
usedSegIds = retUniqueAbsValsOfCellArr(obj.loops.segs);
segIds = obj.segs.id;
unUsedSegIds = setdiff(segIds,usedSegIds);
if ~isempty(unUsedSegIds)
    unUsedSegIdxs = idsToIdxs(segIds, unUsedSegIds);
    obj.segs(unUsedSegIdxs) = [];
end

% clear points
usedPointIds = retUniqueAbsValsOfCellArr(obj.segs.points);
pointIds = obj.points.id;
unUsedPointIds = setdiff(pointIds,usedPointIds);
if ~isempty(unUsedPointIds)
    unUsedPointIdxs = idsToIdxs(pointIds, unUsedPointIds);
    obj.points(unUsedPointIdxs) = [];
end

end

function idxs = idsToIdxs(idArr, ids)
    idxs = NaN(length(ids),1);
    for i=1:length(ids)
        idxs(i) = find(idArr == ids(i));
    end
end