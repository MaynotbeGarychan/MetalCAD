function [pts_ids, segs_ids, loops_ids, pts_idxs, segs_idxs, loops_idxs] = retPartsBaseGeo(obj,parts_idxs)
    % parts_idxs = find(obj.parts.type == PART_TYPE.PARTICLE);
    loops_ids = retUniqueAbsValsOfCellArr(obj.parts(parts_idxs).loops);
    loops_idxs = findValsIdxInArr(obj.loops.id, loops_ids);
    segs_ids = retUniqueAbsValsOfCellArr(obj.loops(loops_idxs).segs);
    segs_idxs = findValsIdxInArr(obj.segs.id, segs_ids);
    pts_ids = retUniqueAbsValsOfCellArr(obj.segs(segs_idxs).points);
    pts_idxs = findValsIdxInArr(obj.points.id, pts_ids);
end

