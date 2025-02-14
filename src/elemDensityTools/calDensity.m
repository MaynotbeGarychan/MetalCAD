function density = calDensity(assemble, density0, density_ctrl, obj_ctrl, idxs)

    density = ones([length(assemble.points) 1]).*density0;

    if strcmp(obj_ctrl,'part')
        [~, ~, ~, pts_idxs, ~, ~] = assemble.retPartsBaseGeo(idxs);
        density(pts_idxs) = density_ctrl;
    end

end

