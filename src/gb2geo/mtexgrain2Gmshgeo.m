% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% convert the grains information from MTEX to geometry information for 
%   gmsh as a geo.file
%
% Input: 
% grains - Type: array of grain2d from MTEX, 
%  Description: the information of grains from MTEX
% output_geo_dir - Type: string
%  Description: directory to the .geo file for gmsh
%
% Output:
% [all_points, all_segs, all_loops, all_parts]
% - Type: array of points, segments, loops, and parts
%  Description: the geometry information of the grains
% ------------------------------------------------------------------------
function [grains_assemble, all_points, all_segs, all_loops, all_parts] = mtexgrain2Gmshgeo(grains)
% init
fprintf("=============================================================\n");
fprintf("mtexgrain2Gmshgeo: began with %d grains.\n", length(grains));
all_points = point(); all_segs = segment(); all_loops = loop(); all_parts = part();
gbseg_delete_arr = []; gbseg_original_arr = [];
% loading all grains
for i=1:length(grains)
    % obtain the geometry of each grain boundary
    [gb_points, gb_segs, gb_loops, gb_parts] = mtexgb2GmshgeoOnegrain(grains(i).boundary);
    % check the duplicate segment
    [gbseg_idx_arr, gbseg_existed_arr] = ret_gbseg_idx_onegrain(gb_segs, gb_points,all_segs,all_points);
    gbseg_delete_arr = [gbseg_delete_arr; gbseg_existed_arr];
    gbseg_original_arr = [gbseg_original_arr; gbseg_idx_arr];
    % cat the one grain information to all
    curr_num_point = size(all_points,1);
    gb_points.id = gb_points.id + curr_num_point;
    all_points = cat(1,all_points,gb_points);
    curr_num_seg = size(all_segs,1);
    gb_segs.id = gb_segs.id + curr_num_seg;
    gb_segs.points = cellfun(@(x) x + curr_num_point, gb_segs.points, 'UniformOutput', false);
    all_segs = cat(1,all_segs,gb_segs);
    curr_num_loop = size(all_loops,1);
    gb_loops.id = gb_loops.id + curr_num_loop;
    gb_loops.segs = cellfun(@(x) x + curr_num_seg, gb_loops.segs, 'UniformOutput', false);
    all_loops = cat(1,all_loops,gb_loops);
    curr_num_part = size(all_parts,1);
    gb_parts.id = gb_parts.id + curr_num_part;
    gb_parts.loops = cellfun(@(x) x + curr_num_loop, gb_parts.loops, 'UniformOutput', false);
    all_parts = cat(1,all_parts,gb_parts);
    fprintf("mtexgrain2Gmshgeo: analyzed grain boundary %d.\n",i);
end
% obtain delete point and tripple point information
% obtain tripple point and its replacement array
[all_segs, delete_tripple_points] = link_tripple_points(all_segs, all_points);
fprintf("mtexgrain2Gmshgeo: linked the tripple points of grain boundary.\n");

% replaced the duplicated gb segment
all_loops = replace_duplicated_gbseg(all_loops, gbseg_delete_arr, gbseg_original_arr);
fprintf("mtexgrain2Gmshgeo: replaced the duplicated gbseg.\n");

% the sequence may be wrong after repalcing the duplicated segment,
% for example, it may be revsersed with the loops sequence
% this function fix the wrong direction of the gb segment
all_loops = fix_loops_gbseg_sequence(all_loops, all_segs);
fprintf("mtexgrain2Gmshgeo: fixed the sequence of gbseg in the loops.\n");

% delete some useless points
delete_inner_points = all_segs.ret_inner_points(find(gbseg_delete_arr));
all_points([delete_inner_points;delete_tripple_points]) = [];
gbseg_delete_arr = logical(gbseg_delete_arr);
all_segs(gbseg_delete_arr) = [];
fprintf("mtexgrain2Gmshgeo: deleted the duplicated points and segs.\n");

% finish convert
grains_assemble = assemble(all_points,all_segs,all_loops,all_parts);
fprintf("mtexgrain2Gmshgeo: finished with %d grains.\n", length(grains));
fprintf("=============================================================\n");
end
%% functions for the operaction of combination
function all_loops_new = fix_loops_gbseg_sequence(all_loops, all_segs)
    % --------------------------------------------------------------------
    % Description: 
    % fix the direction of the the gb segments in the loops, since some 
    % segments will be in wrong direction after replacement. The direction
    % cannot be changed by -id in the loop.segs
    % --------------------------------------------------------------------
    all_loops_new = all_loops;
    for i=1:length(all_loops)
        segs = all_loops(i).segs;
        points1 = all_segs(segs(end)).points;
        for j=1:length(segs)
            points2 = all_segs(segs(j)).points;
            if points1(end) ~= points2(1)
                if points1(end) == points2(end)
                    segs(j) = (-segs(j));
                    points2 = flip(points2);
                elseif points1(1) == points2(end)
                    segs(j) = (-segs(j));
                    points2 = flip(points2);
                end
            end
            points1 = points2;
        end
        all_loops_new(i).segs = segs;
    end
end

function all_loops_new = replace_duplicated_gbseg(all_loops, ...
    gbseg_delete_arr, gbseg_original_arr)
    % --------------------------------------------------------------------
    % Description: 
    % replaced the duplicated segments of the gbs
    % --------------------------------------------------------------------
    all_loops_new = all_loops;
    for i=1:length(all_loops.id)
        segs = all_loops(i).segs;
        for j=1:length(segs)
            segs_id = segs(j);
            if gbseg_delete_arr(segs_id)
                segs(j) = gbseg_original_arr(segs_id);
            end
        end
        all_loops_new(i).segs = segs;
    end
end

function [all_segs_new, delete_points_arr] = link_tripple_points(all_segs, all_points)
    % --------------------------------------------------------------------
    % Description: 
    % after replacement of duplicated gb, other segment in the loop may
    % not be linked due to they still have the previous tripple points
    % at its beginning and its end. So, replacing the correct tripple 
    % points in the points list of the segment can solve this problem.
    % --------------------------------------------------------------------
    % obtain the duplicated tripple point
    tripplepoint_idx = all_segs.ret_tripple_points();
    tripplepoint_coor = all_points(tripplepoint_idx).coordinate;
    tripplepoint_replaced = zeros([length(tripplepoint_idx) 1]);
    for i=1:length(tripplepoint_idx)
        a = ismember(tripplepoint_coor, tripplepoint_coor(i,:), 'rows');
        b = (tripplepoint_replaced == 0);
        condition = a & b;
        tripplepoint_replaced(condition) = tripplepoint_replaced(condition) + tripplepoint_idx(i);
    end
    gbpoint_new_id = (1:length(all_points))';
    for i=1:length(tripplepoint_replaced)
        gbpoint_new_id(tripplepoint_idx(i)) = tripplepoint_replaced(i);
    end
    % check which tripple point should be delete
    condition = (tripplepoint_idx ~= tripplepoint_replaced);
    delete_points_arr = tripplepoint_idx(condition);
    % give the real point id to the start and end of the gbseg
    all_segs_new = all_segs;
    for i=1:length(all_segs_new)
        points = all_segs_new(i).points;
        points(1) = gbpoint_new_id(points(1));
        points(end) = gbpoint_new_id(points(end));
        all_segs_new(i).points = points;
    end
end

%% functions for duplicated gb segments
function [gbseg_idx_arr, gbseg_existed_arr] = ret_gbseg_idx_onegrain(gb_segs, ...
    gb_points,all_segs,all_points)
    % --------------------------------------------------------------------
    % Description: 
    % obtain the duplicated gb segment, check it whether it should be 
    % deleted. This is a dynamic operation.
    % --------------------------------------------------------------------
    gb_num_seg = length(gb_segs.points);
    gbseg_existed_arr = zeros([gb_num_seg 1]); gbseg_idx_arr = zeros([gb_num_seg 1]);
    for i=1:gb_num_seg
        [gbseg_existed_arr(i), ret] = chk_gbseg_existed(all_segs.parts, gb_segs.parts(i,:));
        if isscalar(ret)
            gbseg_idx_arr(i) = ret;
        elseif length(ret) > 1
            own_pos = gb_points(gb_segs(i).points(1)).coordinate + gb_points(gb_segs(i).points(end)).coordinate;
            for j=1:length(ret)
                cmp_pos = all_points(all_segs(ret(j)).points(1)).coordinate + all_points(all_segs(ret(j)).points(end)).coordinate;
                if chk_same_pos(own_pos,cmp_pos)
                    gbseg_idx_arr(i) = ret(j);
                    break
                end
            end
        end
    end
end
function [bool, gbseg_idx] = chk_gbseg_existed(all_gbseg_couple,one_gbseg_couple)
    if size(all_gbseg_couple,1) == 0
        bool = false; gbseg_idx = 0;
        return
    end
    [bool, gbseg_idx] = chk_gbseg_existed_sub(all_gbseg_couple, one_gbseg_couple);
    if bool
        return
    else
        temp = [one_gbseg_couple(1,2), one_gbseg_couple(1,1)];
        [bool, gbseg_idx] = chk_gbseg_existed_sub(all_gbseg_couple, temp);
    end
end
function [bool, gbseg_idx] = chk_gbseg_existed_sub(all_gbseg_couple, one_gbseg_couple)
    bool_array = ismember(all_gbseg_couple, one_gbseg_couple, 'rows');
    bool = logical(any(bool_array));
    gbseg_idx = 0;
    if bool
        indices = find(bool_array);
        gbseg_idx = indices;
    end
end
function bool = chk_same_pos(coor1,coor2)
    if (coor1(1) == coor2(1)) && (coor1(2) == coor2(2)); bool = true; else; bool = false; end
end

