classdef assemble < handle
    properties
        % geomtry
        points
        segs
        loops
        parts
    end
    methods
        function obj = assemble(points,segs,loops,parts)
            if nargin > 0
                obj.points = points; obj.segs = segs;
                obj.loops = loops; obj.parts = parts;
            else
                obj.points = point(); obj.segs = segment();
                obj.loops = loop(); obj.parts = part();
            end
        end

        function assemble_copy = copy(obj)
            assemble_copy = assemble();
            assemble_copy.points.append(obj.points);
            assemble_copy.segs.append(obj.segs);
            assemble_copy.loops.append(obj.loops);
            assemble_copy.parts.append(obj.parts);
        end

        %% reorder function
        bool = chkReordered(obj);
        reorder(obj);

        %% append function
        [obj, info] = append(obj, assemble2);

        %% io functions
        write(obj,file_dir, lc);

        %% point tools
        [region_range,center_pos,region_size] = retRegionRange(obj);
        [pts_ids, segs_ids, loops_ids, pts_idxs, segs_idxs, loops_idxs] = retPartsBaseGeo(obj,parts_idxs);

        %% segment tools
        % return information
        coor = retSegCoordinate(obj,seg_idx);
        [loopsId, loopsIdx] = retLoopsOfTheSeg(obj,segId);
        initSegType(obj);

        % simplification
        simplifyGb(obj);
        simplifySegs(obj, deg_thres);

        % split function 
        segs = splitSegByPoint(obj, segIdx, pId, pPosIdx);
        
        % check function
        [bool, intersectionInfo] = chkItsecTwoSegs(obj, segIdx1, segIdx2); % 检测两个多段线是否相交
        bool = chkSegInsideLoop(obj, loopIdx, segIdx); % polygon related

        % sequence function
        sequence = calSegsRouteSequence(obj, segsIdx, startPointIdx, endPointIdx) % 给定一系列segs找到他们的顺序

        %% loops tool
        sequence = calSegsSequence(obj, segs_idx);

        % return information
        [partsId,partsIdx] = retPartOfTheLoop(obj, loopId);
        % [pointsCoor, points, pointsSeg, pointsInsegIdx] = retLoopPoints(obj, idx);
        [pointsCoor, points, pointsSeg, pointsInsegIdx] = retLoopPoints(obj, idx, varargin);
        [itsecSegsIds,itsecSegsIdxs] = retLoopItsecSegs(obj, loopIdx, additionalInput);
        [itsecLoopsIds, itsecLoopsIdxs] = retLoopItsecLoops(obj, loopIdx, additionalInput);
        ret = retVertexOnLoopIdx(obj, loopIdx, segId, vertexIdx);
        polygon = retLoopPolygon(obj, loop_idx); % polyshape related
        points_id = retPointsInLoops(obj,loop_idx); % polyshape related
        bool = chkLoopInsideLoop(obj,loop1Idx,loop2Idx); % polyshape related
        area = retLoopArea(obj,loopIdx); % 返回回环的面积

        % check function
        [bool, shared_segs] = chkShareSegsOfLoops(obj, loop1_idx, loop2_idx);
        [bool, intersectionInfo] = chkItsecTwoLoops(obj, loopIdx1, loopIdx2); % 检车两个回环是否相交
        [bool,itsecInfo] = chkItsecLoopSeg(obj,loopIdx,segIdx); % 检查多段线是否与回环相交

        % splot function
        loops = splitLoopByItsecSeg(obj, loopIdx, segIdx); % 在回环里的线段对回环进行切割，支持迭代
        loops = splitLoopBySegsInSeq(obj,loopIdx,segsSequence); % 在回环里的连续线段对回环进行切割

        %% plot function
        plotSeg(obj, seg_idx, color);
        plotLoop(obj, loop_idx, color);
        plotPoint(obj,pid,color);

        %% crop function
        assembleCopy = cropLoopsOutside(assembleAll,cutloopIdxs); % 提供几个环，取环外面的几何

        %% clear function
        obj = clearFreeGeo(obj);

        %% region functions
        regions_loops = retLoopRegion(obj, input); % 返回所有loops的矩形regions
        regions_segs = retSegRegion(obj); % 返回所有segs的矩形regions
    end

% -------------------------------------------------------------------------
% static method
% -------------------------------------------------------------------------
    methods (Static)
        function obj = empty(varargin); obj = assemble(varargin{:}); end
    end
end

