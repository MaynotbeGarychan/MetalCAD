function [assemble1, info] = append(assemble1, assemble2)
%% check reordered, if not reordered, reordered it
if ~assemble1.chkReordered(); assemble1.reorder(); end
if ~assemble2.chkReordered(); assemble2.reorder(); end

%% append the information from 2 to 1
% 
num_points = length(assemble1.points); num_segs = length(assemble1.segs);
num_loops = length(assemble1.loops); num_parts = length(assemble1.parts);

% copy the append assemble for its information
temp = assemble2.copy();

% modify the id
temp.points.id = temp.points.id + num_points;
temp.segs.id = temp.segs.id + num_segs;
temp.segs.points = cellfun(@(x) x + num_points, temp.segs.points, 'UniformOutput', false);
temp.segs.parts(:,1) = temp.segs.parts(:,1) + (num_parts*ones(length(temp.segs.parts(:,1)),1));
temp.loops.id = temp.loops.id + num_loops;
temp.loops.segs = cellfun(@(x) x + num_segs, temp.loops.segs, 'UniformOutput', false);
temp.parts.id = temp.parts.id + num_parts;
temp.parts.loops = cellfun(@(x) x + num_loops, temp.parts.loops, 'UniformOutput', false);

% append the geometry information
assemble1.points.append(temp.points);
assemble1.segs.append(temp.segs);
assemble1.loops.append(temp.loops);
assemble1.parts.append(temp.parts);

%% make an info to show the append status
info.pointsBelong = [ones(num_points,1); 2*ones(length(assemble2.points),1)];
info.segsBelong = [ones(num_segs,1); 2*ones(length(assemble2.segs),1)];
info.loopsBelong = [ones(num_loops,1); 2*ones(length(assemble2.loops),1)];
info.partsBelong = [ones(num_parts,1); 2*ones(length(assemble2.parts),1)];

end

