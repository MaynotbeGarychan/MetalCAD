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