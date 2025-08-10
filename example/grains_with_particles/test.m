clc
clear
close all
%% Make grains via MTEX
% load ebsd data
CS = crystalSymmetry.load('Al-Aluminum.cif');
SS = specimenSymmetry('triclinic');
ebsd_dir = '.\example\grains_with_particles\ebsd.ang';
ebsd = EBSD.load(ebsd_dir,CS,'interface','ang','convertSpatial2EulerReferenceFrame','setting 2');
% ebsd = rotate(ebsd,90*degree);
% if you want a smaller region, crop the ebsd region
center_x = (max(ebsd.x) + min(ebsd.x))/2; center_y = (max(ebsd.y) + min(ebsd.y))/2;
len = 350;
region = [center_x-len/2 center_y-len/2 len len];
ebsd = ebsd(inpolygon(ebsd,region));
% construct grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',8*degree);
ebsd(grains(grains.grainSize<20)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',8*degree);
grains = smooth(grains,5);
% plot grains for checking
ipf_key = ipfHSVKey(grains.CS.Laue);
ipf_key.inversePoleFigureDirection = vector3d.X;
fig_1=figure;
ipf_color =  ipf_key.orientation2color(grains.meanOrientation);
plot(grains,ipf_color,'coordinates','off','micronbar','on');
set(fig_1, 'Units', 'Inches', 'Position', [0, 0, 8, 8]);
%% Construct grains assemble
[assemble_gbs, ~, ~, ~, ~] = mtexgrain2Gmshgeo(grains);
assemble_gbs.initSegType();
assemble_gbs.reorder();
for i=1:4
    assemble_gbs.simplifyGb();
    assemble_gbs.reorder();
end
assemble_gbs.simplifySegs(5);
assemble_gbs.reorder();
[gbs_region,gbs_center,gbs_region_size] = assemble_gbs.retRegion();
% output gbs model
assemble_gbs.write('.\example\grains_with_particles\gb_cad.geo',2.8);
%% Construct particle assemble (using the particle geo in the folder)
frac_particle = 0.023; % the realistc particle area fraction
particle_repo_dir = '.\example\grains_with_particles\particle_repo';
dl_region = 18;
pbs_region = [gbs_region(1,1)+dl_region,gbs_region(1,2)-dl_region;
    gbs_region(2,1)+dl_region,gbs_region(2,2)-dl_region];
gbs_region_area = gbs_region_size(1) * gbs_region_size(2);
assemble_pbs = particleMacro.getAssemblePbsFromRepo(particle_repo_dir, frac_particle, pbs_region, gbs_region_area);
assemble_pbs.write('.\example\grains_with_particles\pb_cad.geo',2.0);
%% Boolean the grain geometry using the particle geometry
assemble_all = assemble_gbs.copy();
[~, infoCombine] = assemble_all.append(assemble_pbs);
cutloopIdxs = find(infoCombine.loopsBelong == 2); % particle
assembleCopy = assemble_all.copy();
assembleCopy = cropLoopsOutside(assembleCopy,cutloopIdxs);
% assembleCopy.write('test_combine.geo',1.0);
%% Adjust for the gmsh bugs of the parts ordering
csv_dir = '.\example\grains_with_particles\data.csv';
[assembleCopy2,particle_id] = gmshTool.fixGmshPartLoopsOrder(assembleCopy, csv_dir, length(grains));
%% Checking the four nodes of the rectangle region
assembleCopy3 = fixAssembleRegion2Rect(assembleCopy2);
%% Output the full microstructure geometry
parts_idxs = find(assembleCopy3.parts.type == PART_TYPE.PARTICLE);
density = gmshTool.calGmshDensity(assembleCopy3, 3.3, 0.55, 'part', parts_idxs);
assembleCopy3.write('.\example\grains_with_particles\microstructure_cad.geo',density);
%% output the orientation
orientation_matrix = [grains.meanOrientation.phi1, grains.meanOrientation.Phi, grains.meanOrientation.phi2];
writematrix(orientation_matrix,'.\example\grains_with_particles\euler.csv');