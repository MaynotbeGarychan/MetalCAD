function assemble0 = readGeoFile(fileDir, segType, partType)

% check the existed file
fid = fopen(fileDir, 'r');
if fid == -1
    error('cannot open the file!\n');
end

% init the data structure
pts_id = []; pts_coor = [];
segs_id = []; segs_pts = {};
loops_id = []; loops_segs = {};
parts_id = []; parts_loops = {};

% read
while ~feof(fid)
    line = strtrim(fgets(fid)); % 读取一行并去除首尾空格
    
    % obtain pts info
    pt_match = regexp(line, 'Point\((\d+)\) = \{([^}]+)\}', 'tokens');
    if ~isempty(pt_match)
        id = str2double(pt_match{1}{1}); % obtain id
        coords = str2num(pt_match{1}{2}); % obtain coor
        pts_id = [pts_id; id]; % save id
        pts_coor = [pts_coor; coords(1:2)]; % save coor
        continue;
    end

    % obtain seg info
    seg_match = regexp(line, 'Line\((\d+)\) = \{([^}]+)\}', 'tokens');
    if ~isempty(seg_match)
        id = str2double(seg_match{1}{1});
        pts = str2num(seg_match{1}{2});
        segs_id = [segs_id; id];
        segs_pts(end+1,1) = {[pts']};
        continue
    end

    % obtain loop info
    loop_match = regexp(line, 'Curve Loop\((\d+)\) = \{([^}]+)\}', 'tokens');
    if ~isempty(loop_match)
        id = str2double(loop_match{1}{1});
        segs = str2num(loop_match{1}{2});
        loops_id = [loops_id; id];
        loops_segs(end+1,1) = {[segs']};
        continue
    end
    
    % obtain part info
    part_match = regexp(line, 'Plane Surface\((\d+)\) = \{([^}]+)\}', 'tokens');
    if ~isempty(part_match)
        id = str2double(part_match{1}{1});
        loops = str2num(part_match{1}{2});
        parts_id = [parts_id; id];
        parts_loops(end+1,1) = {[loops']};
        continue
    end
end

fclose(fid);

% make the assemble
num = length(pts_id);
pts = point(pts_id,pts_coor);
num = length(segs_id);
segs = segment(segs_id,segs_pts,repmat([NaN, 1], num, 1),ones([num 1]).*segType);
num = length(loops_id);
loops = loop(loops_id, loops_segs);
num = length(parts_id);
parts = part(parts_id, parts_loops, ones([num 1]).*partType);
assemble0 = assemble(pts, segs, loops, parts);

end

