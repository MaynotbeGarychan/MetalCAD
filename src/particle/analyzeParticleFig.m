function [pbs_smooth, pbs] = analyzeParticleFig(file_dir, num_dpi, mfy, thres_size, thres_smooth)
    
    % analyze the figure
    RGB = imread(file_dir);
    I = im2gray(RGB);
    I = imgaussfilt(I,2);
    bw = imbinarize(I);

    % imshow(bw)
    [pbs,~] = bwboundaries(bw,"noholes");

    % analyze the particle boundary
    num_pixel_y = size(RGB,1);
    num_pixel_x = size(RGB,2);
    center_bypixel = [num_pixel_x/2, num_pixel_y/2];
    fig_size = [num_pixel_x/num_dpi*2.54, num_pixel_y/num_dpi*2.54]./mfy*10000;
    ruler = [fig_size(1)/num_pixel_x , fig_size(2)/num_pixel_y];
    pbs = cellfun(@(x) [x(:, 1) - center_bypixel(1), x(:, 2) - center_bypixel(2)], ...
        pbs, 'UniformOutput', false);  % move it to the center
    pbs = cellfun(@(x) x .* ruler, pbs, 'UniformOutput', false); % scale to real size

    % delete the pbs with very few pts
    pbs_length = cellfun(@length, pbs);
    condition = (pbs_length > 5);
    pbs = pbs(condition);

    % fliter out the small particle
    pbs_area = calPbsArea(pbs);
    thres_area = max(pbs_area) * thres_size;
    condition = (pbs_area > thres_area);
    pbs = pbs(condition);

    % do the smoothing
    pbs_smooth = cell(size(pbs));
    for i=1:numel(pbs)
        pbs_smooth{i} = smoothPolygon(pbs{i},thres_smooth);
    end
end

