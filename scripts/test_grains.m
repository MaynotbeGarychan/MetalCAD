clc
clear
close all
%% MTEX setting
CS = crystalSymmetry.load('Al-Aluminum.cif');
SS = specimenSymmetry('triclinic');
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',20);
%% specify input data
% ebsd_data_dir = '/home/chen/Desktop/research_progress/master_work/ebsd_polycrystal_sim/sample_7/scan_7_clean_gd.ang';
ebsd_data_dir = 'scan_7_clean_gd.ang';
%% import and partition
ebsd = EBSD.load(ebsd_data_dir,CS,'interface','ang','convertSpatial2EulerReferenceFrame','setting 2');
ebsd = rotate(ebsd,45*degree);
region = [min(ebsd.x)+100 min(ebsd.y)+100 100 100];
condition = inpolygon(ebsd, region);
ebsd = ebsd(condition);
%%
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',10*degree);
ebsd(grains(grains.grainSize<20)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',10*degree);
grains = smooth(grains,5);
plot(grains);
%% convert
[grains_assemble, ~, ~, ~, ~] = mtexgrain2Gmshgeo(grains);
% grains_assemble = assemble(all_points,all_segs,all_loops,all_parts);
%% init the segment type
grains_assemble.initSegType();
%% reorder the ids
grains_assemble.reorder();
%% simplified model
grains_assemble.simplifyGb();
grains_assemble.reorder();

grains_assemble.simplifyGb();
grains_assemble.reorder();

grains_assemble.simplifyGb();
grains_assemble.reorder();

grains_assemble.simplifyGb();
grains_assemble.reorder();

grains_assemble.simplifySegs(5);
grains_assemble.reorder();
%% write the result to the geo file
lc = 2.0;
output_geo_dir = 'D:\codes\fem_cases\polycrystal_plate\test_grains_45.geo';
grains_assemble.write(output_geo_dir, lc);
%%
orientation_matrix = [grains.meanOrientation.phi1, grains.meanOrientation.Phi, grains.meanOrientation.phi2];
writematrix(orientation_matrix,'D:\codes\fem_cases\polycrystal_plate\euler_45.csv');