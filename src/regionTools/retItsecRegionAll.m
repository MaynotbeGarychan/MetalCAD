function possible_loops_idxs = retItsecRegionAll(regions_all,region_selected)

possible_loops_idxs = subFunc(regions_all,region_selected);

end

function possible_loops_idxs = subFunc(regions_all,region_selected)
    possible_loops_idxs = [];
    for i=1:size(regions_all,3)
        if regionItsecOrInside(region_selected, regions_all(:,:,i))
            possible_loops_idxs = [possible_loops_idxs; i];
        end
    end
end
