function assembleCopy = cropPartByInsideLoop(assembleAll, partIdx, loopIdx)

% init
assembleCopy = assembleAll.copy();

% crop
oldLoops = assembleCopy.parts(partIdx).loops;
if isscalar(loopIdx) && ismatrix(loopIdx)
    assembleCopy.parts(partIdx).loops = [oldLoops; -loopIdx];
elseif iscell(loopIdx)
    extLoops = [];
    for i=1:numel(loopIdx)
        extLoops = [extLoops; loopIdx{i}];
    end
    assembleCopy.parts(partIdx).loops = [oldLoops; -extLoops];
end

end

