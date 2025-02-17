function assemble1 = fixGmshPartLoopsOrder(assemble0,csv_dir)

assemble1 = assemble0.copy();

% init
numParts = assemble1.parts.num;
lsppPartTransInfo_arr = [];
% begin to check over the parts
for i=1:numParts
    % obtain the parts loops
    partLoops = assemble1.parts(i).loops;
    conditionPositive = (partLoops > 0); 

    % if simple case like [+] or [+,-,-], we can skip it directly
    if sum(conditionPositive) <= 1
        continue
    end

    % generate the new set
    if all(conditionPositive) % all positive loops
        newPartLoopsCells = generateNewPartLoopCells_AllPositive(partLoops);
    else
        newPartLoopsCells = generateNewPartLoopCells_WithNegative(assemble1, partLoops);
    end

    % obtain the info for lspp transformation of multiple parts
    % change the parts
    temp = modifyPartLoop(assemble1, i, newPartLoopsCells);
    lsppPartTransInfo_arr = [lsppPartTransInfo_arr; temp];

end

% output the transform info for lspp
outputPartTransformInfo2CSV(assemble1,lsppPartTransInfo_arr,csv_dir);

end

%% Generate New parts loops cells
function newPartLoopsCells = generateNewPartLoopCells_AllPositive(partLoops)

numLoops = length(partLoops);
newPartLoopsCells = cell([numLoops 1]);
for j=1:numLoops
    newPartLoopsCells{j} = partLoops(j);
end

end


function newPartLoopsCells = generateNewPartLoopCells_WithNegative(assemble1, partLoops)

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
    idxNegative = find(assemble1.loops.id == idNegative);
    negativeLoopCoor = assemble1.retLoopPoints(idxNegative,'Unreordered');
    for k=1:numPositiveLoops
        idPositive = partLoopsPositive(k);
        idxPositive = find(assemble1.loops.id == idPositive);
        positiveLoopCoor = assemble1.retLoopPoints(idxPositive,'Unreordered');
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

function lsppPartTransInfo_arr = modifyPartLoop(assemble1, currIdx, newPartLoopsCells)

lsppPartTransInfo_moms = [];
lsppPartTransInfo_kids = [];
assemble1.parts(currIdx).loops = newPartLoopsCells{1};

for j=2:numel(newPartLoopsCells)
    newPartId = assemble1.parts(end).id+1;
    assemble1.parts.append(part(newPartId, [newPartLoopsCells(j)], PART_TYPE.GRAIN));
    lsppPartTransInfo_kids = [lsppPartTransInfo_kids; newPartId];
    lsppPartTransInfo_moms = [lsppPartTransInfo_moms; assemble1.parts(currIdx).id];
end

lsppPartTransInfo_arr = [lsppPartTransInfo_kids, lsppPartTransInfo_moms];

end


function outputPartTransformInfo2CSV(assemble1,lsppPartTransInfo_arr,csv_dir)
    % all parts to one id
    particle_parts_idxs = find(assemble1.parts.type == PART_TYPE.PARTICLE);
    particle_parts_ids = assemble1.parts.id(particle_parts_idxs);
    num_particles = length(particle_parts_ids);
    particle_id = max(assemble1.parts.id) + 1;
    parts_transform_array = [particle_parts_ids, ones([num_particles 1]).*particle_id];
    % unlinked parts to the same id
    parts_transform_array = [parts_transform_array; lsppPartTransInfo_arr];
    % output
    writematrix(parts_transform_array,csv_dir);

end