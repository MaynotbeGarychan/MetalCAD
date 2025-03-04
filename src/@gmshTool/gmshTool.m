classdef gmshTool

    methods(Static)

        density = calGmshDensity(assemble, density0, density_ctrl, obj_ctrl, idxs);

        [assemble1,particle_id] = fixGmshPartLoopsOrder(assemble0,csv_dir,num_grains);
        
        assemble0 = readGeoFile(fileDir, segType, partType);

    end
end

