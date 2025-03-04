classdef particleMacro

    methods(Static)
        assemble_pbs = getAssemblePbsFromRepo(particle_repo_dir, frac_particle, pbs_region, gbs_region_area);
        assemble_pb = getAssemblePb(file_dir);
    end

end

