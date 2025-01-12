clc
clear
close all
warning('off','MATLAB:polyshape:repairedBySimplify');  
%% make grains
% mtex reconstruct grains
CS = crystalSymmetry.load('Al-Aluminum.cif');
ebsd_data_dir = 'scan_7_clean_gd.ang';
ebsd = EBSD.load(ebsd_data_dir,CS,'interface','ang', ...
    'convertSpatial2EulerReferenceFrame','setting 2');
%%
ind = inpolygon(ebsd,[-150,-150,100,100]); % select indices by poylgon
ebsd = ebsd(ind);
%%

[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'), ...
    'angle',10*degree);
ebsd(grains(grains.grainSize<20)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'), ...
    'angle',10*degree);
grains = smooth(grains,5);
meanGrainRadius = mean(diameter(grains))/2;

% convert the grains to geometry
[assembleGbs, ~, ~, ~, ~] = mtexgrain2Gmshgeo(grains);
assembleGbs.initSegType();
assembleGbs.reorder();
for i=1:4; assembleGbs.simplifyGb(); assembleGbs.reorder(); end
assembleGbs.simplifySegs(5);
assembleGbs.reorder();

%% basic parameters
numParticle = 40;
radius = meanGrainRadius*0.08;
resolution = 20;
[regionRangeX,regionRangeY] = retRegionRange(assembleGbs);
% regionRangeX(1) = regionRangeX(1) + 1.1*radius;
% regionRangeX(2) = regionRangeX(2) - 1.1*radius;
% regionRangeY(1) = regionRangeY(1) + 1.1*radius;
% regionRangeY(2) = regionRangeY(2) - 1.1*radius;
% regionRangeX = [-180.574,-180.573]; 
% regionRangeY = [-171.7094,-171.7093];
particlePartId = 1;

% init a containor
assemblePbs = assemble();
currNumParticle = 0;

while currNumParticle < numParticle
   
    % make new particle
    seedCoor = randomSeeds(regionRangeX,regionRangeY,1);
    boundaryCoor = circle(seedCoor(1,1),seedCoor(1,2),radius,resolution);
    % convert to a assemble
    pid = (1:resolution)'; points = point(pid,boundaryCoor);
    segs = segment(1,{[pid;pid(1)]},[NaN,particlePartId],SEGMENT_TYPE.GRAIN_PARTICLE);
    loops = loop(1,{[1]});
    parts = part(1,{[1]},PART_TYPE.PARTICLE);
    assembleOne = assemble(points,segs,loops,parts);
    % chekc whether is outside the other loops
    if currNumParticle > 0
        if chkInOutRegion(assemblePbs, assembleOne)
            assemblePbs.append(assembleOne);
            currNumParticle = currNumParticle + 1;
            fprintf('Have inserted %d particles.\n', currNumParticle);
        else
            hold on
        end
    else
        assemblePbs.append(assembleOne);
        currNumParticle = currNumParticle + 1;
        fprintf('Have inserted %d particles.\n', currNumParticle);
    end

end

%% combine 
assembleAll = assembleGbs.copy();
[~, infoCombine] = assembleAll.append(assemblePbs);
cutloopIdxs = find(infoCombine.loopsBelong == 2); % particle
assembleAll = cropLoopsOutside(assembleAll,cutloopIdxs);

%%
assembleAll2 = assembleAll.copy();
organizePartsLoopForGmsh(assembleAll2);
assembleAll2.write('test_combine.geo',1);

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


%% seeds function
function seedCoor = randomSeeds(xRange,yRange,numSeeds)
    seedCoor = NaN(numSeeds,2);
    seedCoor(:,1) = xRange(1) + (xRange(2)-xRange(1)) * rand(numSeeds, 1);
    seedCoor(:,2) = yRange(1) + (yRange(2)-yRange(1)) * rand(numSeeds, 1);
end

%% curve function
function boundaryCoor = circle(x0,y0,radius,resolution)
    boundaryCoor = NaN(resolution,2);
    theta = linspace(0, 2*pi, resolution)';
    boundaryCoor(:,1) = radius * cos(theta) + x0;
    boundaryCoor(:,2) = radius * sin(theta) + y0;
end