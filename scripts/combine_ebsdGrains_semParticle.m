clc
clear
%% grain boundary
% import
CS = crystalSymmetry.load('Al-Aluminum.cif');
SS = specimenSymmetry('triclinic');
ebsd_data_dir = './eg4input/ebsd.ang';
ebsd = EBSD.load(ebsd_data_dir,CS,'interface','ang','convertSpatial2EulerReferenceFrame','setting 2');
ebsd = rotate(ebsd,45*degree);
region = [min(ebsd.x)+100 min(ebsd.y)+100 100 100];
condition = inpolygon(ebsd, region);
ebsd = ebsd(condition);
% construct
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',10*degree);
ebsd(grains(grains.grainSize<20)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',10*degree);
grains = smooth(grains,5);
% convert
[assemble_gbs, ~, ~, ~, ~] = mtexgrain2Gmshgeo(grains);
assemble_gbs.initSegType();
assemble_gbs.reorder();
assemble_gbs.simplifyGb();
assemble_gbs.reorder();
assemble_gbs.simplifyGb();
assemble_gbs.reorder();
assemble_gbs.simplifyGb();
assemble_gbs.reorder();
assemble_gbs.simplifyGb();
assemble_gbs.reorder();
assemble_gbs.simplifySegs(5);
assemble_gbs.reorder();
% info
[~,gbs_center] = assemble_gbs.retRegionRange();
%% import particle boundary
particle_repo_dir = 'eg4input';
file_list = dir(particle_repo_dir);
assemble_pbs = assemble();
for i=1:numel(file_list)
    if endsWith(file_list(i).name, '.mat')
        particle_case_dir = [particle_repo_dir '\' file_list(i).name];
        temp = load(particle_case_dir);
        assemble_pbs.append(temp.assemble_pbs);
    end
end
%% combine

[~,pbs_center] = assemble_pbs.retRegionRange();

dxy =  gbs_center - pbs_center;
assemble_pbs.points.translate('x',dxy(1));
assemble_pbs.points.translate('y',dxy(2));

%% combine test
assemble_all = assemble_gbs.copy();
[~, infoCombine] = assemble_all.append(assemble_pbs);
cutloopIdxs = find(infoCombine.loopsBelong == 2); % particle
assembleCopy = assemble_all.copy();
assembleCopy = cropLoopsOutside(assembleCopy,cutloopIdxs);
assembleCopy.write('test_combine.geo',1.0);

%% write
% assembleCopy.write('D:\progress\composites\polycrystal_with_particle_model\test.geo',0.5);

%% calculate the particle area
area = assemble_pbs.retLoopArea('all');
