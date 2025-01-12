%% init
clc
clear
close all
warning('off','MATLAB:polyshape:repairedBySimplify');                       % turn off the wanring of polygon init
%% make grain assemble
% mtex reconstruct grains
CS = crystalSymmetry.load('Al-Aluminum.cif');
ebsd_data_dir = 'scan_7_clean_gd.ang';
ebsd = EBSD.load(ebsd_data_dir,CS,'interface','ang', ...
    'convertSpatial2EulerReferenceFrame','setting 2');
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'), ...
    'angle',10*degree);
ebsd(grains(grains.grainSize<20)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'), ...
    'angle',10*degree);
grains = smooth(grains,5);

% convert the grains to geometry
[assemble_gbs, ~, ~, ~, ~] = mtexgrain2Gmshgeo(grains);
assemble_gbs.initSegType();
assemble_gbs.reorder();
for i=1:4; assemble_gbs.simplifyGb(); assemble_gbs.reorder(); end
assemble_gbs.simplifySegs(5);
assemble_gbs.reorder();

%% make particle assemble
% matlab built-in function to analyze the figure to obatin the particle
% geometry
fig_dir = 'particle.jpg';
RGB = imread(fig_dir);
I = im2gray(RGB);
bw = imbinarize(I);
[pbs,~] = bwboundaries(bw,"noholes");
condition = cellfun(@length, pbs) > 100;
pbs = pbs(condition);

% convert the particles to geometry
[assemble_pbs, ~,~,~,~] = particles2Gmshgeo(pbs);
assemble_pbs.simplifySegs(3);
assemble_pbs.reorder();

%% adjust and combine two assmeble
% adjust the region of particles to cover on the grains at the correct
% position
[assemble_gbs,assemble_pbs] = adjustRegion(assemble_gbs, assemble_pbs, ...
    size(RGB(:,:,1)));
assemble_pbs.points.scale('x',0.1);
assemble_pbs.points.scale('y',0.1);
% combine all the information together
assemble_all = assemble_gbs.copy();
[~, infoCombine] = assemble_all.append(assemble_pbs);

%% begin to do the loops cut loops
status = 'debug';
assembleCopy = assemble_all.copy();

% select the base loops and cut loops
% baseloopIdxs = find(info_combine.loops_belong == 1); % grain
cutloopIdxs = find(infoCombine.loopsBelong == 2); % particle

assembleCopy = cropLoopsOutside(assembleCopy,cutloopIdxs);
assembleCopy.write('test_combine.geo',1.0);
