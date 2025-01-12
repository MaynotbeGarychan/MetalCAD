clc
clear
%% analyze the jpg using the matlab toolbox functions
fig_dir = "D:\progress\composites\particle_repo\cut\p20cut1_x2700.jpg";
num_dpi = 271;
mfy = 2700;
thres_size = 300;
thres_smooth = 5;
[pbs_smooth, pbs] = analyzeParticleFig(fig_dir, num_dpi, mfy, thres_size, thres_smooth);
%% plot the particle
close all
for i=1:numel(pbs_smooth)
    onepb = pbs_smooth{i};
    plot(onepb(:,2), onepb(:,1), 'LineWidth', 1.5);
    hold on
end
axis equal
hold off
%% generate single crystal model
[assemble_pbs,all_points,all_segs,all_loops,all_parts] = particles2Gmshgeo(pbs_smooth);
assemble_pbs.simplifySegs(10);
assemble_pbs.reorder();
assemble_pbs.write('D:\progress\composites\particle_repo\geo_single_crystal\test.geo',1.0);
%% save to mat file
file_name = dir(fig_dir).name;
case_name = erase(file_name,'.jpg');
save(['D:\progress\composites\particle_repo\mat\' case_name '.mat'],'assemble_pbs');

%% add a outter bound
bound_coor = [-50,-50;50,-50;50,50;-50,50];
bound_points_id = (1:size(bound_coor,1))';
assemble_bound = assemble();
assemble_bound.points.append(point(bound_points_id,bound_coor));
assemble_bound.segs.append(segment(1,[bound_points_id;bound_points_id(1)],[1 NaN],SEGMENT_TYPE.GRAIN_EDGE));
assemble_bound.loops.append(loop(1,{[1]}));
assemble_bound.parts.append(part(1,{[1]},PART_TYPE.GRAIN));

assemble_all = assemble_bound.copy();
assemble_all.append(assemble_pbs);
assemble_all.parts(1).loops = [1; assemble_all.loops.id.*(-1)];

lc_arr = [ones([4 1])*10; ones([length(assemble_pbs.points) 1])*0.1];
assemble_all.write('D:\progress\composites\particle_repo\geo_single_crystal\test_singlecrystal.geo',lc_arr);