function assemble_pbs = generateParticleFromRepo(particle_repo_dir, frac_particle, pbs_region, gbs_region_area)

% init 
% init particle repo
file_list = dir(particle_repo_dir);
num_file = numel(file_list);
% init some params
thres_particle_area = frac_particle * gbs_region_area;
% init the cell to save the pbs region which has been used in the whole
% region
region_filled = {};

% init the particle assemble before the iteration
curr_particle_area = 0;
assemble_pbs = assemble();
while curr_particle_area < thres_particle_area
    % select randomly from the folder, and load the particle
    idx = randi(num_file);
    if ~endsWith(file_list(idx).name, '.mat')
        continue
    end
    particle_case_dir = [particle_repo_dir '\' file_list(idx).name];
    temp = load(particle_case_dir);
    assemble_onepb = temp.assemble_pbs;
    area = assemble_onepb.retLoopArea('all');
    curr_particle_area = curr_particle_area + area;
    [~,onepbs_center,onepbs_region_size] = assemble_onepb.retRegionRange();
    % design the position of the particle
    onepbs_center_random = randomInRegionWithFilledRegions(pbs_region, region_filled, onepbs_region_size);
    % transform the center
    dxy =  onepbs_center_random - onepbs_center;
    assemble_onepb.points.translate('x',dxy(1));
    assemble_onepb.points.translate('y',dxy(2));
    % save the filled region
    [onepbs_region,~,~] = assemble_onepb.retRegionRange();
    region_filled{end+1} = onepbs_region;
    % append the particle
    assemble_pbs.append(assemble_onepb);
    % assemble_onepb.plotLoop(1:length(assemble_onepb.loops.id),'black'); hold on; axis equal;
    fprintf('generateParticleFromRepo: Instered one set of particle, the current particle fraction is %d / %d .\n', ...
        curr_particle_area/gbs_region_area, frac_particle);
end
end
