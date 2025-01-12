% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% convert particles boundaries to the geometry information
% this function is mainly for cat the information obtained from 
% function particle_to_gmshgeo_oneparticle
%
% Input: 
% pbs - Type: cell with array of coordinates for each particle boundary
%  Description: cell contains arrays of coordinates for each particle 
%               boundary
%
% Output:
% [all_points,all_segs,all_loops,all_parts]
% - Type: array of points, segments, loops, and parts
%  Description: the geometry information of particles
% ------------------------------------------------------------------------
function [pbs_assemble,all_points,all_segs,all_loops,all_parts] = particles2Gmshgeo(pbs)
    % init
    fprintf("=============================================================\n");
    fprintf("particles2Gmshgeo: began with %d particles.\n", length(pbs));
    all_points = point(); all_segs = segment(); all_loops = loop(); all_parts = part();
    % process the boundary before the convert
    pbs = deleteOuterLoopsPbs(pbs);
    % convert
    for i=1:length(pbs)
        [pb_points, pb_segs, pb_loops, pb_parts] = particle2GmshgeoOneparticle(pbs{i});
        % cat point information
        curr_num_point = size(all_points,1);
        pb_points.id = pb_points.id + curr_num_point;
        all_points = cat(1,all_points,pb_points);
        % cat seg information
        curr_num_seg = size(all_segs,1);
        pb_segs.id = pb_segs.id + curr_num_seg;
        pb_segs.points = cellfun(@(x) x + curr_num_point, pb_segs.points, 'UniformOutput', false);
        all_segs = cat(1,all_segs,pb_segs);
        % cat loop information
        curr_num_loop = size(all_loops,1);
        pb_loops.id = pb_loops.id + curr_num_loop;
        pb_loops.segs = cellfun(@(x) x + curr_num_seg, pb_loops.segs, 'UniformOutput', false);
        all_loops = cat(1,all_loops,pb_loops);
        % cat part information
        curr_num_part = size(all_parts,1);
        pb_parts.id = pb_parts.id + curr_num_part;
        pb_parts.loops = cellfun(@(x) x + curr_num_loop, pb_parts.loops, 'UniformOutput', false);
        all_parts = cat(1,all_parts,pb_parts);
        fprintf("particles2Gmshgeo: analyzed particle boundary %d.\n",i);
    end
    %
    pbs_assemble = assemble(all_points,all_segs,all_loops,all_parts);
    fprintf("particles2Gmshgeo: finished with %d particles.\n", length(pbs));
    fprintf("=============================================================\n");
end

