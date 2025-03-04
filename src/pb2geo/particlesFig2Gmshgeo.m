function [pbs_assemble,pbs_smooth] = particlesFig2Gmshgeo(file_dir, num_dpi, mfy, thres_size, thres_smooth)

[pbs_smooth, ~] = analyzeParticleFig(file_dir, num_dpi, mfy, thres_size, thres_smooth);

[pbs_assemble,~,~,~,~] = particles2Gmshgeo(pbs_smooth);

end

