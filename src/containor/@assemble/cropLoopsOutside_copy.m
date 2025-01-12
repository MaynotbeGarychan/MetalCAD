function assembleCopy = cropLoopsOutside(assembleAll,cutloopIdxs)

% init
assembleCopy = assembleAll.copy();
status = 'debug';
loopDelete = [];

% classify
cutLoopHasItsecIdxs = [];
cutLoopInOtherLoopsIdxs = [];

fprintf('=============================================================\n');
for i=1:length(cutloopIdxs)
    % init
    cutLoopIdx = cutloopIdxs(i);
    fprintf('CropLoopByLoop: Begined with cutloop %d.\n', cutLoopIdx);
    % check the intersecting segs, and loops of the loop
    [~,itsecSegsIdxs] = assembleCopy.retLoopItsecSegs(cutLoopIdx);
    [~,itsecLoopsIdxs] = assembleCopy.retLoopItsecLoops(cutLoopIdx);        % return the intersection loops
    if strcmp(status, 'debug'); close all; assembleCopy.plotLoop(cutLoopIdx, 'black'); assembleCopy.plotLoop(itsecLoopsIdxs, 'blue'); assembleCopy.plotSeg(itsecSegsIdxs,'red'); hold on; end
    % classify 
    if isempty(itsecLoopsIdxs) & isempty(itsecSegsIdxs)
        cutLoopInOtherLoopsIdxs = [cutLoopInOtherLoopsIdxs; cutLoopIdx];
        continue
    else
        if any(assembleCopy.segs(itsecSegsIdxs).type == SEGMENT_TYPE.GRAIN_EDGE)
            loopPosType = 3;
        end
        cutLoopHasItsecIdxs = [cutLoopHasItsecIdxs;cutLoopIdx];
    end

    % Step-1: init containor to save the intersection information
    itsecInfo = retItsecInfo(assembleCopy, cutLoopIdx, itsecSegsIdxs);
    fprintf('CropLoopByLoop: Checked intersection information of cut loop %d.\n', cutLoopIdx);
    
    % Step-2: add intersection points
    itsecPoints = addItsecPoints(assembleCopy, itsecInfo.itsecPointCoor(:,1:2));
    if strcmp(status, 'debug'); assembleCopy.plotPoint(itsecPoints.id,'cyan'); hold on; end
    fprintf('CropLoopByLoop: Added the intersection points on the loop %d.\n', cutLoopIdx);

    % Step-3: split the cutloop
    newSegsOfCutLoop = splitCutLoopIntoSegs(assembleCopy, itsecInfo.itsecSeg1Id, itsecInfo.itsecVecIdxSeg1, itsecPoints.id);
    if strcmp(status, 'debug'); assembleCopy.plotSeg(newSegsOfCutLoop.id,'red'); hold on; end
    assembleCopy.loops(cutLoopIdx).segs = assembleCopy.calSegsSequence(newSegsOfCutLoop.id);
    fprintf('CropLoopByLoop: Splited the loop %d based on the intersection points and calculate its sequence.\n', cutLoopIdx);

    % Step-4: split the base seg
    [newSegsOfBaseLoops, splitSegInfo] = splitItsecSegsOfBaseLoops(assembleCopy, ...
        itsecInfo.itsecSeg2Id, itsecInfo.itsecVecIdxSeg2, itsecPoints.id);
    fprintf('CropLoopByLoop: Splited the segs intersecting with the cut loop %d.\n', cutLoopIdx);
    if strcmp(status, 'debug'); for k=1:length(newSegsOfBaseLoops); assembleCopy.plotSeg(newSegsOfBaseLoops(k).id, 'black'); end; end

    % Step-5: recalculate the sequence of base loops
    recalculateSequenceOfTheItsecLoops(assembleCopy, itsecLoopsIdxs, splitSegInfo.oldSegId, splitSegInfo.newSegsIds);
    fprintf('CropLoopByLoop: Reconstructed the base loops sequences.\n');
    
    % Step-6: distribute the segs partitioned from cut loops to the
    % corresponding base loops
    if strcmp(status, 'debug'); close all; assembleCopy.plotLoop(cutLoopIdx,'black'); hold on; end
    LoopsIdxsSplitedOfTheSeg = distributePartionedSegsToBaseLoops(assembleCopy, newSegsOfCutLoop.id, itsecLoopsIdxs);
    fprintf('CropLoopByLoop: Segs partitioned from the cut loops has been distributed to the base loops.\n');
    if strcmp(status, 'debug')
        for j=1:length(newSegsOfCutLoop.id)
            % assembleCopy.plotLoop(LoopsIdxsSplitedOfTheSeg(j),'blue'); hold on
            assembleCopy.plotSeg(newSegsOfCutLoop(j).id,'red'); hold on
        end
    end

    % Step-7: split the base loops intersecting the cut loops by the segs
    % of the cut loops
    if strcmp(status, 'debug'); close all; assembleCopy.plotLoop(itsecLoopsIdxs,'cyan'); hold on; end
    [newLoopsInsideCell, newLoopsOutSideCell] = splitItsecLoopsBySegsOfCutLoop(assembleCopy, cutLoopIdx, ...
        itsecLoopsIdxs, LoopsIdxsSplitedOfTheSeg, newSegsOfCutLoop.id);
    fprintf('CropLoopByLoop: Segs partitioned from the cut loops has been distributed to the base loops.\n');
    if strcmp(status, 'debug')
        assembleCopy.plotLoop(cutLoopIdx,'black'); hold on;
        for j=1:length(itsecLoopsIdxs)
            assembleCopy.plotLoop(newLoopsInsideCell{j},'blue'); 
            assembleCopy.plotLoop(newLoopsOutSideCell{j},'red'); 
        end
    end


    % Step-8: make new parts for the split loop
    organizeParts4OutsideLoops(assembleCopy, itsecLoopsIdxs, newLoopsOutSideCell, newLoopsInsideCell);
    for j=1:length(itsecLoopsIdxs); loopDelete = [loopDelete; newLoopsInsideCell{j}]; end
    fprintf('CropLoopByLoop: Orginized the parts for the outside loops.\n');

end
fprintf('=============================================================\n');

% only the loop-in-loop support length>1 part.loops
% for the loops originate from the same part, it should crack into multiple
% parts
% orgianze the parts with multi loops to a single loops, also provide the
% mapping
newPartIdx2MotherPartIdx = orgainzePartsFromMultiLoopsToSingle(assembleCopy);

% Step-9: for the loops inside other loops, 
modifiedPartIds = cropPartByInnerLoop(assembleCopy, cutLoopInOtherLoopsIdxs);

% clean delete some useless things
finalClear(assembleCopy, cutloopIdxs, loopDelete);

% assemble_copy.reorder(); % if use reorder, the maping should be changed

end

%% =======================================================================
% Sub function for crop part of the loops has intersection with inner
% segement
% ========================================================================

function  cropPartByItsecLoop(assembleCopy, cutLoopIdx, itsecSegsIdxs, itsecLoopsIdxs)

end

%% =======================================================================
% Sub function - Step 1 - return intersection information
% ========================================================================
function itsecInfo = retItsecInfo(assembleAll, cutLoopIdx, itsecSegsIdxs)
    itsecInfo = [];
    for j=1:length(itsecSegsIdxs)
        % init
        baseSegIdx = itsecSegsIdxs(j);
        % check itsec seg and save the intersection information
        [~,info] = assembleAll.chkItsecLoopSeg(cutLoopIdx,baseSegIdx);
        itsecInfo = structCombine(itsecInfo, info);
    end
end

%% =======================================================================
% Sub function - Step 2 - Add intersection points
% ========================================================================
function itsecPoints = addItsecPoints(assembleAll, itsecPointCoor)
    numItsec = size(itsecPointCoor,1);
    pid = (length(assembleAll.points)+1:length(assembleAll.points)+numItsec)';
    pcoor = itsecPointCoor(:,1:2);
    itsecPoints = point(pid, pcoor);
    assembleAll.points.append(itsecPoints);
end

%% =======================================================================
% Sub function - Step 3 - Split cut loop and recalculate the sequence
% ========================================================================
function newSegsOfCutLoop = splitCutLoopIntoSegs(assembleAll, itsecSegId, itsecVecIdxInSeg, itsecPointId)
    newSegsOfCutLoop = segment();
    itsecSegsInCutLoop = unique(itsecSegId);
    for j=1:length(itsecSegsInCutLoop)
        itsecSegInCutLoop = itsecSegsInCutLoop(j);
        condition = (itsecSegId == itsecSegInCutLoop);
        segs = assembleAll.splitSegByPoint(itsecSegInCutLoop, itsecPointId(condition), itsecVecIdxInSeg(condition));
        newSegsOfCutLoop.append(segs);
    end
end

%% =======================================================================
% Sub function - Step 4 - Split the itsec segs of the base loop
% ========================================================================
function [newSegsOfBaseLoops, splitSegInfo] = splitItsecSegsOfBaseLoops(assembleAll, itsecSegIds, itsecVecIdxsSeg, itsecPointsIds)
    splitSegInfo = [];
    itsecSegIdsUnique = unique(itsecSegIds);
    newSegsOfBaseLoops = segment();
    for j=1:length(itsecSegIdsUnique)
        itsecSegId = itsecSegIdsUnique(j);
        condition = (itsecSegIds == itsecSegId);
        segs = assembleAll.splitSegByPoint(itsecSegId, itsecPointsIds(condition), itsecVecIdxsSeg(condition));
        % save segment
        newSegsOfBaseLoops.append(segs);
        % save info
        info.oldSegId = itsecSegId; info.newSegsIds = {segs.id};
        splitSegInfo = structCombine(splitSegInfo, info);
    end
end

%% =======================================================================
% Sub function - Step 5 - Recalculate the sequence of the intersecting
% loops
% ========================================================================
function recalculateSequenceOfTheItsecLoops(assembleAll, itsecLoopsIdxs, oldSegIds, newSegsIdsCell)
    for j=1:length(itsecLoopsIdxs)
        % obtain the loop to be fixed
        itsecLoopIdx = itsecLoopsIdxs(j);
        % replace the segs of the loops
        oldSegs = assembleAll.loops(itsecLoopIdx).segs;
        newSegs = replaceElementsInArr(oldSegs, oldSegIds, newSegsIdsCell);
        assembleAll.loops(itsecLoopIdx).segs = assembleAll.calSegsSequence(abs(newSegs));
    end
end

function newArr = replaceElementsInArr(oldArr, oldVals, newValsCell)
    % detect the vals which has been changed
    hasReplaced = ismember(abs(oldArr), oldVals);
    valsToBeReplaced = oldArr(hasReplaced);
    % begin to replace
    newArr = oldArr;
    for i=1:length(valsToBeReplaced)
        originalArr = newArr;
        idx = find(originalArr == valsToBeReplaced(i));
        valsForReplaced = newValsCell{oldVals == abs(valsToBeReplaced(i))};
        newArr = [originalArr(1:idx-1); valsForReplaced; originalArr(idx+1:end)];
    end
end
%% =======================================================================
% Sub function - Step 6 - distribute the segs to the base loops
% ========================================================================
function LoopsIdxsSplitedOfTheSeg = distributePartionedSegsToBaseLoops(assembleAll, newSegsOfCutLoopIdxs, itsecLoopsIdxs)
    % init containor
    LoopsIdxsSplitedOfTheSeg = NaN(length(newSegsOfCutLoopIdxs),1);
    % begin to distribute
    for j=1:length(newSegsOfCutLoopIdxs)
        segIdx = newSegsOfCutLoopIdxs(j);
        for k=1:length(itsecLoopsIdxs)
            itsecLoopIdx = itsecLoopsIdxs(k);
            if chkSplitSegInsideLoop(assembleAll, itsecLoopIdx, segIdx)
                LoopsIdxsSplitedOfTheSeg(j) = itsecLoopIdx;
                break
            end
        end
    end
    % check if it's all-distributed
    if any(isnan(LoopsIdxsSplitedOfTheSeg))
        hold on
        % error('The segs has not been distributed.\n');
        % assembleAll.plotSeg(assembleAll.segs.id,'black');
    end
end

% check whether the split seg is inside the base loop
function bool = chkSplitSegInsideLoop(obj, baseLoopIdx, splitSegIdx)
    bool = false;
    segPoints = obj.segs(splitSegIdx).points;
    segCoor = obj.points(segPoints).coordinate(:,1:2);
    
    [baseLoopCoor, baseLoopPoints, ~,~] = obj.retLoopPoints(baseLoopIdx);
    
    [all, on] = inpolygon(segCoor(:,1), segCoor(:,2), baseLoopCoor(:,1), baseLoopCoor(:,2));
    in = (all & (~on));
    
    % common situation
    if any(in)
        bool = true;
        return
    end
    % in some situation, there is no inside point of the segs, but it did
    % intersect
    if (length(segPoints) == 2) && length(find(on)) == 2
        idxs = find(on);
        dist = min([max(idxs)-min(idxs), length(baseLoopPoints)-(max(idxs)-min(idxs))]);
        if dist > 0
            bool = true;
            return
        end
    end

end

%% =======================================================================
% Sub function - Step 7 - split the intersecting base loop by the segs
% partitioned from the cut loop
% ========================================================================
function [newLoopsInsideCell, newLoopsOutSideCell] = splitItsecLoopsBySegsOfCutLoop(assembleAll, cutLoopIdx, itsecLoopsIdxs, LoopsIdxsSplitedOfTheSeg, newSegsOfCutLoopIds)
    newLoopsInsideCell = {}; newLoopsOutSideCell = {};
    for j=1:length(itsecLoopsIdxs)
        % select one loop and the segs inside of it
        itsecLoopIdx = itsecLoopsIdxs(j);
        segsSplitingTheLoopIds = newSegsOfCutLoopIds(LoopsIdxsSplitedOfTheSeg == itsecLoopIdx);
        % split the loop using the segs inside
        loops = assembleAll.splitLoopByItsecSeg(itsecLoopIdx, segsSplitingTheLoopIds);
        % check the split loop is inside the base loop or the cut loop?
        splitLoopsInisdeCutLoopsIds = []; splitLoopsOutsideCutLoopsIds = [];
        for k=1:length(loops)
            if assembleAll.chkLoopInsideLoop(loops(k).id, cutLoopIdx) % if inside cut loop
                splitLoopsInisdeCutLoopsIds = [splitLoopsInisdeCutLoopsIds; loops(k).id];
            else % inside base loop
                splitLoopsOutsideCutLoopsIds = [splitLoopsOutsideCutLoopsIds; loops(k).id];
            end
        end
        % save result
        newLoopsInsideCell = [newLoopsInsideCell;splitLoopsInisdeCutLoopsIds];
        newLoopsOutSideCell = [newLoopsOutSideCell;splitLoopsOutsideCutLoopsIds];
    end
end

%% =======================================================================
% Sub function - Step 8 - make parts for the new outside loops
% ========================================================================
function organizeParts4OutsideLoops(assembleAll, itsecLoopsIdxs, newLoopsOutSideCell, newLoopsInsideCell)
    for j=1:length(itsecLoopsIdxs)
        % select the original loops and find its parts
        itsecLoopIdx = itsecLoopsIdxs(j);
        partOfItsecLoop = assembleAll.retPartOfTheLoop(itsecLoopIdx);
        currLoopsOfThePart = assembleAll.parts(partOfItsecLoop).loops;
        % modify the loops corrseponding to the parts
        currLoopsOfThePart = deleteValsInArr(currLoopsOfThePart, newLoopsInsideCell{j});
        currLoopsOfThePart = appendNewValsIntoArr(currLoopsOfThePart, newLoopsOutSideCell{j});
        assembleAll.parts(partOfItsecLoop).loops = currLoopsOfThePart;
    end
end

function newArr = appendNewValsIntoArr(oldArr, valArr)
    condition = ismember(valArr, oldArr); % index of the not existed values
    newArr = [oldArr; valArr(~condition)];
end

function newArr = deleteValsInArr(oldArr,valArr)
    condition = ismember(oldArr, valArr);
    newArr = oldArr(~condition);
end


%% =======================================================================
% Sub function - Step 9 - alter the parts of multi loops to only one loop
% ========================================================================

function newPartIdx2MotherPartIdx = orgainzePartsFromMultiLoopsToSingle(assembleAll)
    newPartIdx2MotherPartIdx = NaN(length(assembleAll.parts),1);
    for i=1:length(assembleAll.parts)
        % obatin the parts loops and check whether it's more than one loop
        partLoopsIds = assembleAll.parts(i).loops;
        newPartIdx2MotherPartIdx(i) = i;
        if length(partLoopsIds) > 1
            currPart = assembleAll.parts(i);
            extraLoopsIds = partLoopsIds(2:end);
            for j=1:length(extraLoopsIds)
               % make new part for the extra loops
               extraPart = currPart.copy();
               extraPart.id = length(assembleAll.parts) + 1;
               extraPart.loops = {[extraLoopsIds(j)]};
               assembleAll.parts.append(extraPart);
               % previous part information
               newPartIdx2MotherPartIdx = [newPartIdx2MotherPartIdx;i];
            end
            % modify the loops of the curr part
            assembleAll.parts(i).loops = partLoopsIds(1);
        end
    end
end

%% =======================================================================
% Sub function - Step 10 - clear
% ========================================================================
function finalClear(assembleAll, cutloopIdxs, LoopInsideCutLoop)
    % obatin the points to be delete
    pointsDelete = [];
    for i=1:length(cutloopIdxs)
        pointsDelete = [pointsDelete; assembleAll.retPointsInLoops(cutloopIdxs(i))];
    end
    % obatin the segs should be delete
    % these segs are from Loop inside the cut loop and which are not used
    % by other outside loops
    segCannotBeDelete = []; segMayBeDelete = [];
    loopUnDelte = setdiff((1:length(assembleAll.loops))',LoopInsideCutLoop);
    for i=1:length(loopUnDelte)
       segCannotBeDelete = [segCannotBeDelete; abs(assembleAll.loops(loopUnDelte(i)).segs)];
    end
    segCannotBeDelete = unique(segCannotBeDelete);
    for i=1:length(LoopInsideCutLoop)
        segMayBeDelete = [segMayBeDelete; abs(assembleAll.loops(LoopInsideCutLoop(i)).segs)];
    end
    segMayBeDelete = unique(segMayBeDelete);
    segDelete = setdiff(segMayBeDelete, segCannotBeDelete);
    % clear
    assembleAll.points(pointsDelete) = [];
    assembleAll.segs(segDelete) = [];
    assembleAll.loops(LoopInsideCutLoop) = []; % delete loops
end

%% =======================================================================
% Sub function for crop part by inner loop
% ========================================================================
function modifiedPartIds = cropPartByInnerLoop(assembleAll, cutLoopInOtherLoopsIdxs)
    % init containor
    modifiedPartIds = [];
    % begin to crop
    for i=1:length(cutLoopInOtherLoopsIdxs)
        % init info of the cut loop
        cutLoopIdx = cutLoopInOtherLoopsIdxs(i);
        cutLoopId = assembleAll.loops(cutLoopIdx).id;
        [cutLoopCoor,~,~,~] = assembleAll.retLoopPoints(cutLoopIdx);
        for j=1:length(assembleAll.loops)
            % init info of the other loop
            otherLoopId = assembleAll.loops(j).id;
            [otherLoopCoor,~,~,~] = assembleAll.retLoopPoints(j);
            % check whether is inside any loop
            [all,on] = inpolygon(cutLoopCoor(:,1),cutLoopCoor(:,2),otherLoopCoor(:,1),otherLoopCoor(:,2));
            in = all & (~on);
            if ~any(~in)
                % if in, crop the part by appending the loop into the part.loop
                currPartIdx = assembleAll.retPartOfTheLoop(otherLoopId);
                partLoops = assembleAll.parts(currPartIdx).loops;
                partLoops = [partLoops; cutLoopId];
                assembleAll.parts(currPartIdx).loops = partLoops;
                % save info
                modifiedPartIds = [modifiedPartIds; currPartIdx];
                break
            end
        end
    end
end