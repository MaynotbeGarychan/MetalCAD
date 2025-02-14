function fixGmshPartLoopsOrder(obj, csv_dir)

% init
numParts = obj.parts.num;
% begin to check over the parts
for i=1:numParts
    % obtain the parts loops
    partLoops = obj.parts(i).loops;
    conditionPositive = (partLoops > 0); 

    % if simple case like [+] or [+,-,-], we can skip it directly
    if sum(conditionPositive) <= 1
        continue
    end

    % generate the new set
    if all(conditionPositive) % all positive loops
        newPartLoopsCells = generateNewPartLoopCells_AllPositive(partLoops);
    else
        newPartLoopsCells = generateNewPartLoopCells_WithNegative(obj, partLoops);
    end

    % obtain the info for lspp transformation of multiple parts
    % change the parts
    lsppPartTransInfo = modifyPartLoop(obj, i, newPartLoopsCells);

    % output the transform info for lspp
    outputPartTransformInfo2CSV(obj,lsppPartTransInfo,csv_dir);

end

end

%% Generate New parts loops cells
function newPartLoopsCells = generateNewPartLoopCells_AllPositive(partLoops)

numLoops = length(partLoops);
newPartLoopsCells = cell([numLoops 1]);
for j=1:numLoops
    newPartLoopsCells{j} = partLoops(j);
end

end


function newPartLoopsCells = generateNewPartLoopCells_WithNegative(obj, partLoops)

% obtain the positve and negative loop
conditionPositive = (partLoops > 0); 
partLoopsPositive = partLoops(conditionPositive);
numPositiveLoops = sum(conditionPositive);
% obtain the negative loops
conditionNegative = (~conditionPositive);
partLoopsNegative = abs(partLoops(conditionNegative));
numNegativeLoops = length(partLoopsNegative);

% check the negative loop in which positive loop
motherPositiveLoopsOfNegativeLoop = NaN([numNegativeLoops 1]);
for j=1:numNegativeLoops
    idNegative = partLoopsNegative(j);
    idxNegative = find(obj.loops.id == idNegative);
    negativeLoopCoor = obj.retLoopPoints(idxNegative,'Unreordered');
    for k=1:numPositiveLoops
        idPositive = partLoopsPositive(k);
        idxPositive = find(obj.loops.id == idPositive);
        positiveLoopCoor = obj.retLoopPoints(idxPositive,'Unreordered');
        boolArr = inpolygon(negativeLoopCoor(:,1), negativeLoopCoor(:,2), positiveLoopCoor(:,1), positiveLoopCoor(:,2));
        if all(boolArr)
            motherPositiveLoopsOfNegativeLoop(j) = idPositive;
            break
        end
    end
end

% begin to generate the cell
newPartLoopsCells = cell([numPositiveLoops 1]);
for j=1:numPositiveLoops
    idPositive = partLoopsPositive(j);
    % find whether there is a negative loop
    condition = (motherPositiveLoopsOfNegativeLoop == idPositive);
    if any(condition)
        idx = find(motherPositiveLoopsOfNegativeLoop == idPositive);
        idNegative = partLoopsNegative(idx);
        newPartLoopsCells{j} = [idPositive;-idNegative];
    else
        newPartLoopsCells{j} = [idPositive];
    end
end

end

%% generate info for lspp transformation of multiple parts

function lsppPartTransInfo = modifyPartLoop(obj, currIdx, newPartLoopsCells)

lsppPartTransInfo.moms = [];
lsppPartTransInfo.kids = [];
obj.parts(currIdx).loops = newPartLoopsCells{1};

for j=2:numel(newPartLoopsCells)
    newPartId = obj.parts(end).id+1;
    obj.parts.append(part(newPartId, [newPartLoopsCells(j)], PART_TYPE.GRAIN));
    lsppPartTransInfo.kids = [lsppPartTransInfo.kids; newPartId];
    lsppPartTransInfo.moms = [lsppPartTransInfo.moms; obj.parts(currIdx).id];
end

end


function outputPartTransformInfo2CSV(obj,lsppPartTransInfo,csv_dir)
    % all parts to one id
    particle_parts_idxs = find(obj.parts.type == PART_TYPE.PARTICLE);
    particle_parts_ids = obj.parts.id(particle_parts_idxs);
    num_particles = length(particle_parts_ids);
    particle_id = max(obj.parts.id) + 1;
    parts_transform_array = [particle_parts_ids, ones([num_particles 1]).*particle_id];
    % unlinked parts to the same id
    temp = [lsppPartTransInfo.kids, lsppPartTransInfo.moms];
    parts_transform_array = [parts_transform_array; temp];
    % output
    writematrix(parts_transform_array,csv_dir);

end