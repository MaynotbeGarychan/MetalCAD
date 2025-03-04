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
    
    % process the boundary before the convert, e.g., delete the cross
    % points for the loop, which causing bugs for the upcomming convert.
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

%%
% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% convert one particle boundary to the geometry information
%
% Input: 
% pb - Type: n*2 double array,
%  Description: coordinates of the particle boundary
%
% Output:
% [pb_points,pb_segs,pb_loops,pb_parts]
% - Type: array of points, segments, loops, and parts
%  Description: the geometry information of one particle
% ------------------------------------------------------------------------
function [pb_points,pb_segs,pb_loops,pb_parts] = particle2GmshgeoOneparticle(pb)
    coor = pb(1:end-1,1:2);
    pb_points = point((1:size(coor,1))', coor);
    pb_segs = segment(1,{[(1:length(pb_points))';1]},[1,NaN],SEGMENT_TYPE.PARTICLE_UNKNOWN);
    pb_loops = loop(1,{[1]});
    pb_parts = part(1,{[1]},PART_TYPE.PARTICLE);
end

%%
% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% this function deletes the outer loops of the particle boundary
%
% Input: 
% pb - Type: n*2 array
%  Description: the coordinates of the points of a particle with 
%               outer small loop
%
% Output:
% pb_new
% - Type: n*2 array
%  Description: the coordinates of the points of a particle without 
%               outer small loop
% ------------------------------------------------------------------------
function pbs_new = deleteOuterLoopsPbs(pbs)
    pbs_new = cell(size(pbs));
    for i=1:size(pbs,1)
        pbs_new{i} = delete_outerloop_pb(pbs{i});
    end
end

function pb_new = delete_outerloop_pb(pb)
    % init
    pb_new = pb;
    % find the cross points
    [unique_rows, ~, idx] = unique(pb, 'rows');
    duplicated_rows = unique_rows(accumarray(idx, 1) > 1, 1:2);

    rows_to_delete = ismember(duplicated_rows, pb(1,1:2), 'rows');
    duplicated_rows(rows_to_delete,:) = [];

    delete_arr = false([size(pb,1) 1]);
    for i=1:size(duplicated_rows,1)
        arow = duplicated_rows(i,1:2);
        indices = find(pb(:,1) == arow(1) & pb(:,2) == arow(2));
        len1 = abs(indices(1) - indices(2)) - 1; 
        len2 = size(pb,1) - len1;
        if len2 > len1
            delete_arr(indices(1):(indices(2)-1)) = true;
        else
            delete_arr(1:indices(1)) = true;
            delete_arr(indices(2)+1:end) = true;
        end
    end
    pb_new(delete_arr,:) = [];
end