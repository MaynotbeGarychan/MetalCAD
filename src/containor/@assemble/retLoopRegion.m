function regions_loops = retLoopRegion(obj, input)

if ischar(input)
    if strcmp(input, 'all')
        regions_loops = NaN([2 2 obj.loops.num]);
        for i=1:obj.loops.num
            segs = abs(obj.loops(i).segs);
            pts_cell = obj.segs(segs).points;
            if iscell(pts_cell)
                pts = cat(1, pts_cell{:});
            else
                pts = pts_cell;
            end
            coors = obj.points(pts).coordinate;
            regions_loops(:,:,i) = [min(coors(:,1)), max(coors(:,1)); min(coors(:,2)), max(coors(:,2))];
        end
    end
elseif isscalar(input)
    segs = abs(obj.loops(input).segs);
    pts_cell = obj.segs(segs).points;
    if iscell(pts_cell)
        pts = cat(1, pts_cell{:});
    else
        pts = pts_cell;
    end
    coors = obj.points(pts).coordinate;
    regions_loops = [min(coors(:,1)), max(coors(:,1)); min(coors(:,2)), max(coors(:,2))];
end

end