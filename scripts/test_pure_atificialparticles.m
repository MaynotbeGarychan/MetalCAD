clc
clear
close all
warning('off','MATLAB:polyshape:repairedBySimplify');  
%%
assemblePbs = assemble();

%
currNumParticle = 0;
numParticle = 20;
radius=0.01;
resolution = 30;
while currNumParticle < numParticle
   
    % make new particle
    seedCoor = randomSeeds([0.05,0.95],[0.05,0.95],1);
    [temp,~] = circlePaticle(seedCoor(1,1),seedCoor(1,2),radius,resolution);
    % chekc whether is outside the other loops
    if currNumParticle > 0
        if chkInOutRegion(assemblePbs, temp)
            assemblePbs.append(temp);
            currNumParticle = currNumParticle + 1;
            fprintf('Have inserted %d particles.\n', currNumParticle);
        end
    else
        assemblePbs.append(temp);
        currNumParticle = currNumParticle + 1;
        fprintf('Have inserted %d particles.\n', currNumParticle);
    end

end

%% combine 
assembleAll = assemble();
% assembleAll.append(retParticleRectangle(0,0,1,1));
% assembleAll.segs(1).type = SEGMENT_TYPE.GRAIN_EDGE;

[~, infoCombine] = assembleAll.append(assemblePbs);
cutloopIdxs = find(infoCombine.loopsBelong == 2); % particle
assembleAll = cropLoopsOutside(assembleAll,cutloopIdxs);

%%

assembleAll.write('test.geo',2);

%% quick check out region
function bool = chkInOutRegion(assembleAll, assembleOne)
    % init
    bool = true;

    % init the points of new particle
    [newParticleCoor,~,~,~] = assembleOne.retLoopPoints(1);

    % make sure all the points is not inside the new loop
    allPointsCoor = assembleAll.points.coordinate(:,1:2);
    [all, ~] = inpolygon(allPointsCoor(:,1), allPointsCoor(:,2), newParticleCoor(:,1), newParticleCoor(:,2));
    if any(all)
        bool = false;
        return
    end
    % make sure new assemble is not inside other loop
    for i=1:length(assembleAll.loops)
        [oldParticleCoor,~,~,~] = assembleAll.retLoopPoints(i);
        [all, ~] = inpolygon(newParticleCoor(:,1), newParticleCoor(:,2), oldParticleCoor(:,1), oldParticleCoor(:,2));
        if any(all)
            bool = false;
            return
        end
    end

end