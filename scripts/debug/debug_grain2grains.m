clc
clear
close all
%% create a two grain region
assemble_gbs = assemble();
% points
pts_id = [1;2;3;4;5;6];
pts_coor = [0,100; 0,0; 100,0; 100,100; 50,0; 50,100];
assemble_gbs.points.append(pts_id, pts_coor);
% segment
segs_id = [1;2;3];
segs_pts = {[6;1;2;5];[5;6];[6;4;3;5]};
segs_parts = [1,NaN; 1,2; 2, NaN];
segs_type = [SEGMENT_TYPE.GRAIN_EDGE; SEGMENT_TYPE.GRAIN_GRAIN; SEGMENT_TYPE.GRAIN_EDGE];
assemble_gbs.segs.append(segs_id, segs_pts, segs_parts, segs_type);
% loops
loops_id = [1;2];
loops_segs = {[1;2];[2;3]};
assemble_gbs.loops.append(loops_id, loops_segs);
% parts
parts_id = [1;2];
parts_loops = {[1];[2]};
parts_type = [PART_TYPE.GRAIN; PART_TYPE.GRAIN];
assemble_gbs.parts.append(parts_id, parts_loops, parts_type);
% assemble_gbs.plotLoop('all','black'); hold on
%% input the particle
particle_case_dir = 'D:\progress\composites\particle_repo\mat\p4cut1_x2000.mat';
temp = load(particle_case_dir);
assemble_pbs = assemble();
assemble_pbs.append(temp.assemble_pbs);
assemble_pbs.points.translate('x',50.5);
assemble_pbs.points.translate('y',52);
% assemble_pbs.points.translate('x',50);
% assemble_pbs.points.translate('y',50);
% assemble_pbs.plotLoop('all','red');
%% crop
assemble_all = assemble_gbs.copy();
[~, infoCombine] = assemble_all.append(assemble_pbs);
assemble_all.plotLoop('all','black')
cutloopIdxs = find(infoCombine.loopsBelong == 2); % particle
assembleCopy = assemble_all.copy();
assembleCopy = cropLoopsOutside(assembleCopy,cutloopIdxs);
assembleCopy.write('./scripts/debug/test_combine.geo',1.0);

%%
% assemble_gbs.write('./scripts/debug/test.geo',1);