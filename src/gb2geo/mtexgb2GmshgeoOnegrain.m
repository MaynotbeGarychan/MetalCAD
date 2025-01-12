% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% convert one grain boundary to the geometry information
%
% Input: 
% gb - Type: grain.boundary , 
%  Description: the information of grain boundary from MTEX
%
% Output:
% [gb_points, gb_segs, gb_loops, gb_parts]
% - Type: array of points, segments, loops, and parts
%  Description: the geometry information of one grain
% ------------------------------------------------------------------------
function [gb_points, gb_segs, gb_loops, gb_parts] = mtexgb2GmshgeoOnegrain(gb)

% number of points
num_midpoint = size(gb.midPoint,1);
num_edgepoint = length(gb.x);
num_total_point = num_midpoint + num_edgepoint;

% find the edge point couple
edgepoints_ids = find_edgepoints_ids_midpoints(gb);

% find the edge point for the middle point
edgepoints_ids = arrange_edgepoints_loop_order(edgepoints_ids);

% combine the total point array
points_coordinates = init_total_points_coordinates(gb,edgepoints_ids);
gb_points = point((1:num_total_point)',points_coordinates(:,:));

% convert functions
grain_type = identify_grain_type(gb.grainId,edgepoints_ids);
switch grain_type
case 1
    [gb_segs, gb_loops, gb_parts] = gb2gmshgeo_normal_grain(gb);
case 2
    [gb_segs, gb_loops, gb_parts] = gb2gmshgeo_inner_grain(gb);
case 3
    [gb_segs, gb_loops, gb_parts] = gb2gmshgeo_hollow_grain(gb,edgepoints_ids);
otherwise
    error('This grain is not supproted.')
end
% gbseg_points_id_cell = gbseg_points_id_cell';

end

%% the convert functions
function [gb_segs, gb_loops, gb_parts] = gb2gmshgeo_inner_grain(gb)
    % --------------------------------------------------------------------
    % Description: 
    % convert the grian boundary information to the gmsh script geometry
    % for an inner grain
    % --------------------------------------------------------------------
    num_midpoint = size(gb.midPoint,1);
    num_edgepoint = length(gb.x);
    num_total_point = num_midpoint + num_edgepoint;
    gb_segs = segment(1,{[(1:num_total_point)';1]},gb.grainId(1,:),NaN);
    gb_loops = loop(1,{[1]});
    gb_parts = part(1,{[1]},PART_TYPE.GRAIN);
end

function [gb_segs, gb_loops, gb_parts] = gb2gmshgeo_normal_grain(gb)
    % --------------------------------------------------------------------
    % Description: 
    % convert the grian boundary information to the gmsh script geometry
    % for an normal grain
    % --------------------------------------------------------------------
    % form gb segs
    edge_midpoint_id_list = ret_gbseg_edge_midpoint(gb.grainId);
    num_seg = size(edge_midpoint_id_list,1);
    points = arrayfun(@(b, e) (b:e)', ...
        [1; edge_midpoint_id_list(1:end-1,2).*2], edge_midpoint_id_list(:,2).*2, 'UniformOutput', false);
    gb_segs = segment((1:num_seg)', points, ...
        gb.grainId(edge_midpoint_id_list(:,1),:),NaN([num_seg 1]));
    if chk_midpoint_same_gbseg(gb.grainId(1,:),gb.grainId(end,:))
        new_points =  [gb_segs(end).points; gb_segs(1).points]; 
        gb_segs(1).points = new_points; 
        gb_segs(end) = [];
        num_seg = num_seg - 1;
    else
        gb_segs(1).points = [gb_segs(end).points(length(gb_segs(end).points)); gb_segs(1).points];
    end
    % form gb loop and part
    gb_loops = loop(1,{(1:num_seg)'});
    gb_parts = part(1,{[1]},PART_TYPE.GRAIN);
end

function [gb_segs, gb_loops, gb_parts] = gb2gmshgeo_hollow_grain(gb,edgepoints_ids)
    % --------------------------------------------------------------------
    % Description: 
    % convert the grian boundary information to the gmsh script geometry
    % for a hollow grain
    % --------------------------------------------------------------------
    % init some basic
    num_midpoint = size(gb.grainId,1);
    % identify the beginning and ending mid point index for each line loop
    % (grain boundary loop) iteratively
    gbloop_edge_midpoint_id = ret_gbloop_midpoint(edgepoints_ids,num_midpoint);
    num_loop = size(gbloop_edge_midpoint_id,1);
    % obtain the edge point for each grain boundary segment of each grain
    % boundary loop, save them into a cell
    gbseg_edge_midpoint_id_list = ret_gbseg_edge_midpoint(gb.grainId);
    gbseg_edge_midpoint_id_cell = ret_gbseg_edge_midpoint_list2cell(gbseg_edge_midpoint_id_list,gbloop_edge_midpoint_id);
    % 
    [gb_segs, gb_loops, gb_parts] = gb2gmshgeo_hollow_grain_sub(gb, gbseg_edge_midpoint_id_cell);
end
function [gb_segs, gb_loops, gb_parts] = gb2gmshgeo_hollow_grain_sub(gb,gbseg_edge_midpoint_id_cell)
    % init    
    curr_gbseg_id = 1;
    begin_gbseg_id = 1;
    begin_point_id = 0;

    gb_segs = segment();
    % gb_segs.id_array = [];
    % gb_segs.points_cell = cell(0);
    % gb_segs.parts_array = [];

    gb_segs_id = [];
    gb_segs_points = cell(0);
    gb_segs_parts = [];

    num_loop = length(gbseg_edge_midpoint_id_cell);
    gb_loops_segs = cell([num_loop 1]);
    % iter
    for i=1:length(gbseg_edge_midpoint_id_cell)
        aloop_gbseg_edge_midpoint_list = gbseg_edge_midpoint_id_cell{i};
        %
        [aloop_gbseg_points_id_cell, gbseg_line_idx_list, end_gbseg_id, end_point_id, aloop_gbseg_graincouple_id_list] = gb2gmshgeo_hollow_grain_aloop( ...
            gb.grainId, aloop_gbseg_edge_midpoint_list, begin_gbseg_id, begin_point_id);
        % save result
        aloop_num_gbseg = length(aloop_gbseg_points_id_cell);
        gb_segs_id = [gb_segs_id; (begin_gbseg_id:begin_gbseg_id+aloop_num_gbseg-1)'];
        gb_segs_points(end+1:end+aloop_num_gbseg,1) = aloop_gbseg_points_id_cell;
        gb_segs_parts = [gb_segs_parts; aloop_gbseg_graincouple_id_list];
        % gb_segs.id_array = [gb_segs.id_array;(begin_gbseg_id:begin_gbseg_id+aloop_num_gbseg-1)'];
        % gb_segs.points_cell(end+1:end+aloop_num_gbseg,1) = aloop_gbseg_points_id_cell;
        % gb_segs.parts_array = [gb_segs.parts_array;aloop_gbseg_graincouple_id_list];
        % gb_loops.segs_cell{i} = gbseg_line_idx_list;
        gb_loops_segs{i} = gbseg_line_idx_list;
        % update
        begin_gbseg_id = end_gbseg_id + 1;
        begin_point_id = end_point_id + 1;
    end
    % form segs
    gb_segs = segment(gb_segs_id,gb_segs_points,gb_segs_parts,NaN([length(gb_segs_id) 1]));
    % form loop
    gb_loops = loop((1:num_loop)',gb_loops_segs);
    % form part
    gb_parts = part(1,{(1:num_loop)'},PART_TYPE.GRAIN);
end
function [gbseg_points_id_cell, gbseg_line_idx_list, end_gbseg_id, end_point_id, gbseg_graincouple_id_list] = gb2gmshgeo_hollow_grain_aloop( ...
    gb_grainid, aloop_gbseg_edge_midpoint_list, begin_gbseg_id, begin_point_id)
    % init
    aloop_begin_midpoint_id = aloop_gbseg_edge_midpoint_list(1,1); % begin mid point idx in the line loop
    aloop_end_midpoint_id = aloop_gbseg_edge_midpoint_list(end,2); % end mid point idx in the line loop
    bool_inner_lineloop = (size(unique(gb_grainid(aloop_begin_midpoint_id:aloop_end_midpoint_id,:),'row'),1) == 1);
    aloop_num_gbseg = size(aloop_gbseg_edge_midpoint_list,1);
    gbseg_points_id_cell = cell([aloop_num_gbseg 1]);
    % obtain the point id for each gbseg and store them into a cell
    for i=1:aloop_num_gbseg
        begin_midpoint_id = aloop_gbseg_edge_midpoint_list(i,1);
        end_midpoint_idx = aloop_gbseg_edge_midpoint_list(i,2);
        seg_num_midpoint = end_midpoint_idx - begin_midpoint_id + 1;
        % for inner line loop, number of edge and mid point is the same
        seg_num_edgepoint = seg_num_midpoint + ~bool_inner_lineloop;
        seg_num_point = seg_num_midpoint + seg_num_edgepoint;
        end_point_id = begin_point_id + seg_num_point - 1;
        gbseg_points_id_cell{i} = (begin_point_id:end_point_id)';
        begin_point_id = end_point_id;
    end
    %
    % at the same time, obtain the grain couple id for each gbseg
    gbseg_graincouple_id_list = gb_grainid(aloop_gbseg_edge_midpoint_list(:,1),:);
    % checking the start and end seg is in the same segment
    if ~bool_inner_lineloop
        if chk_midpoint_same_gbseg(gb_grainid(aloop_begin_midpoint_id,:),gb_grainid(aloop_end_midpoint_id,:))
            gbseg_points_id_cell{1} = [gbseg_points_id_cell{end}; gbseg_points_id_cell{1}(2:end)];
            gbseg_points_id_cell(end) = [];
            num_gbseg_loop = size(aloop_gbseg_edge_midpoint_list,1) - 1;
            gbseg_graincouple_id_list = gbseg_graincouple_id_list(1:end-1,:);
        else
            gbseg_points_id_cell{1} = [gbseg_points_id_cell{end}(end);gbseg_points_id_cell{1}(2:end)];
            num_gbseg_loop = size(aloop_gbseg_edge_midpoint_list,1);
        end
    else
        gbseg_points_id_cell{1} = [gbseg_points_id_cell{1}(end);gbseg_points_id_cell{1}];
        num_gbseg_loop = 1;
    end
    % calculate the end gbseg id and form the line index list
    end_gbseg_id = begin_gbseg_id + num_gbseg_loop - 1;
    gbseg_line_idx_list = (begin_gbseg_id:end_gbseg_id)';
end

%% other functions 
function edgepoint_ids = find_edgepoints_ids_midpoints(gb)
    % --------------------------------------------------------------------
    % Description: 
    % calculate the coordinates of mid points by every two edge point
    % store them into a 2d uppper triangle matrix
    % --------------------------------------------------------------------
    x_matrix = repmat(gb.x,1,length(gb.x));
    x_matrix = triu((x_matrix+x_matrix')/2);
    x_matrix = symm_matrix_lowertri_NaN(x_matrix);
    y_matrix = repmat(gb.y,1,length(gb.y));
    y_matrix = triu((y_matrix+y_matrix')/2);
    y_matrix = symm_matrix_lowertri_NaN(y_matrix);
    edgepoint_ids = zeros([size(gb.midPoint,1) 2]);
    % find the edges point for each mid points
    for i=1:size(gb.midPoint,1)
        [x1, x2] = find(x_matrix == gb.midPoint(i,1));
        [y1, y2] = find(y_matrix == gb.midPoint(i,2));
        x = [x1 x2];
        y = [y1 y2];
        [~, idx, ~] = intersect(x, y, 'rows');
        if length(idx) == 1
            edgepoint_ids(i,:) = x(idx,:);
        elseif length(idx) > 1
            temp = x1(idx);
            dx = gb.x(temp) - gb.midPoint(i,1);
            dy = gb.y(temp) - gb.midPoint(i,2);
            distance = dx.^2 + dy.^2;
            [~,min_idx] = min(distance);
            aidx = idx(min_idx);
            edgepoint_ids(i,:) = x(aidx,:);
        else
            hold on
        end
    end
end

function edgepoints_ids_ordered = arrange_edgepoints_loop_order(edgepoints_ids)
    % --------------------------------------------------------------------
    % Description: 
    % arrange the edge points ids to be the order as the loop               
    % by checking the sharing point
    % --------------------------------------------------------------------
    edgepoints_ids_ordered = zeros(size(edgepoints_ids));
    edgepoints_ids_loop = [edgepoints_ids;edgepoints_ids(1,:)];
    % for the first mid point, we find its begin point 
    couple1 = edgepoints_ids_loop(1,:);
    couple2 = edgepoints_ids_loop(2,:);
    end_point = intersect(couple1,couple2);
    begin_point = couple1(couple1~=end_point);
    edgepoints_ids_ordered(1,2) = end_point;
    edgepoints_ids_ordered(1,1) = begin_point;
    % for the others, if in the same loop the begin point is the end point 
    % of the last mid point
    for i=2:size(edgepoints_ids,1)
        couple = edgepoints_ids_loop(i,:);
        begin_point = edgepoints_ids_ordered(i-1,2);
        end_point = couple(couple~=begin_point);
        if length(end_point) == 1
            edgepoints_ids_ordered(i,1) = begin_point;
            edgepoints_ids_ordered(i,2) = end_point;
        elseif length(end_point) == 2
            % sometimes go to the begin of the second curve loop
            % we need to find the begin point again
            couple1 = edgepoints_ids_loop(i,:);
            couple2 = edgepoints_ids_loop(i+1,:);
            end_point = intersect(couple1,couple2);
            begin_point = couple1(couple1~=end_point);
            edgepoints_ids_ordered(i,1) = begin_point;
            edgepoints_ids_ordered(i,2) = end_point;
        else
            error('Fail to find the edge point!');
        end
    end
end

function coordinates = init_total_points_coordinates(gb,edgepoints_ids)
    % --------------------------------------------------------------------
    % Description: 
    % init the coordinates for the points with the loop's order
    % --------------------------------------------------------------------
    num_midpoint = size(gb.midPoint,1);
    num_edgepoint = length(gb.x);
    num_total_point = num_midpoint + num_edgepoint;
    coordinates = zeros([num_total_point 2]);
    for i=1:num_midpoint
        idx = 2*i-1;
        coordinates(idx,:) = gb.midPoint(i,:);
        edgepoint_id = edgepoints_ids(i,2);
        coordinates(idx+1,:) = [gb.x(edgepoint_id) gb.y(edgepoint_id)];
    end 
end

function gbseg_edge_midpoint_id_cell = ret_gbseg_edge_midpoint_list2cell(gbseg_edge_midpoint_id_list,gbloop_edge_midpoint_id)
    % --------------------------------------------------------------------
    % Description: 
    % convert the gbseg_edge_midpoint_id_list to a cell, each cell element
    % for a gb loop
    % --------------------------------------------------------------------
    num_loop = size(gbloop_edge_midpoint_id,1);
    gbseg_edge_midpoint_id_cell = cell([num_loop 1]);
    for i=1:num_loop
        begin_midpoint = gbloop_edge_midpoint_id(i,1);
        end_midpoint = gbloop_edge_midpoint_id(i,2);
        begin_point_id = find(gbseg_edge_midpoint_id_list(:,1) == begin_midpoint);
        end_point_id = find(gbseg_edge_midpoint_id_list(:,2) == end_midpoint);
        gbseg_edge_midpoint_id_cell{i} = gbseg_edge_midpoint_id_list(begin_point_id:end_point_id,:);
    end
end

function gbloop_edge_midpoint_id = ret_gbloop_midpoint(edgepoints_ids, num_midpoint)
    % --------------------------------------------------------------------
    % Description: 
    % identify the beginning and ending mid point index for each line loop
    % (grain boundary loop) iteratively
    % --------------------------------------------------------------------
    begin_midpoint_id = 1;
    curr_begin_edgepoint_id = edgepoints_ids(begin_midpoint_id,1);
    end_midpoint_idx = find(edgepoints_ids(:,2) == curr_begin_edgepoint_id);
    gbloop_edge_midpoint_id = [begin_midpoint_id end_midpoint_idx];
    while end_midpoint_idx ~= num_midpoint % iter till we find the end
        begin_midpoint_id = end_midpoint_idx + 1;
        curr_begin_edgepoint_id = edgepoints_ids(begin_midpoint_id,1);
        end_midpoint_idx = find(edgepoints_ids(:,2) == curr_begin_edgepoint_id);
        gbloop_edge_midpoint_id = [gbloop_edge_midpoint_id;begin_midpoint_id end_midpoint_idx];
    end
end

function edge_midpoint_id_list = ret_gbseg_edge_midpoint(gb_grainid)
    % --------------------------------------------------------------------
    % Description: 
    % loop over the grain id of the midpoint in the sequence, return the 
    % the id list of the edge midpoint of the gb
    % --------------------------------------------------------------------
    edge_midpoint_id_list = [];
    begin_midpoint_id = 1;
    status = gb_grainid(1,:);
    % gbseg_graincouple_id_list = status;
    num_midpoint = size(gb_grainid,1);
    for i=2:num_midpoint
        curr = gb_grainid(i,:);
        if ~chk_midpoint_same_gbseg(status,curr)
            status = curr;
            end_midpoint_id = i - 1;
            edge_midpoint_id_list = [edge_midpoint_id_list;[begin_midpoint_id end_midpoint_id]];
            begin_midpoint_id = i;
        end
    end
    edge_midpoint_id_list = [edge_midpoint_id_list;[begin_midpoint_id num_midpoint]];
end

function bool_midpoint_same_gbseg = chk_midpoint_same_gbseg(grainid1,grainid2)
    % --------------------------------------------------------------------
    % Description: 
    % Check whether two midpoint is in the same gb segment
    % --------------------------------------------------------------------
    bool_midpoint_same_gbseg = 0;
    if grainid1(1) == grainid2(1) && grainid1(2) == grainid2(2)
        bool_midpoint_same_gbseg = 1;
    end
end

%% identify grain type
function cst = identify_grain_type(gb_grainids,edge_points_ids_list)
    % --------------------------------------------------------------------
    % Description: 
    % Identify the grain type
    % --------------------------------------------------------------------
    if chk_inner_grain(gb_grainids)
        cst = 2;
    else
        if chk_with_inner_grain(edge_points_ids_list)
            cst = 3;
        else
            cst = 1;
        end
    end
end
function bool_with_inner_grain = chk_with_inner_grain(edge_points_ids_list)
    % --------------------------------------------------------------------
    % Description: 
    % Check whether this grain has an inner grain
    % --------------------------------------------------------------------
    bool_with_inner_grain = (edge_points_ids_list(1,1) ~= edge_points_ids_list(end,2));
end
function bool_ingrain = chk_inner_grain(gb_grainids)
    % --------------------------------------------------------------------
    % Description: 
    % check whether it is a grain inside another grain
    % --------------------------------------------------------------------
    bool_ingrain = (size(unique(gb_grainids,'row'),1) == 1);
end

%% Math tools
function amatrix_with_NaN = symm_matrix_lowertri_NaN(amatrix)
    % --------------------------------------------------------------------
    % Description: 
    % return the upper tri part of a symm matrix and the lower tri part
    % filled with NaN
    % --------------------------------------------------------------------
    amatrix_with_NaN = amatrix;
    lower_tri_idx = tril(true(size(amatrix_with_NaN)), -1);
    amatrix_with_NaN(lower_tri_idx) = NaN;
end

