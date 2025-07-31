function [pbs_assemble,pbs_smooth] = particlesFig2Gmshgeo(file_dir, num_dpi, mfy, thres_size, thres_smooth)

[pbs_smooth, ~] = analyzeParticleFig(file_dir, num_dpi, mfy, thres_size, thres_smooth);

[pbs_assemble,~,~,~,~] = particles2Gmshgeo(pbs_smooth);

end

% function [x_smooth, y_smooth] = smooth_loop_gaussian(x, y, sigma)
%     % Ensure the loop is closed
%     if x(1) ~= x(end) || y(1) ~= y(end)
%         x = [x; x(1)];
%         y = [y; y(1)];
%     end
% 
%     % Convert to column vectors
%     x = x(:);
%     y = y(:);
% 
%     % Use circular padding to preserve the loop continuity
%     N = length(x);
%     pad_size = round(3 * sigma); % Padding size based on sigma
%     x_padded = [x(end-pad_size+1:end); x; x(1:pad_size)];
%     y_padded = [y(end-pad_size+1:end); y; y(1:pad_size)];
% 
%     % Apply Gaussian filtering
%     x_smooth_padded = imgaussfilt(x_padded, sigma);
%     y_smooth_padded = imgaussfilt(y_padded, sigma);
% 
%     % Remove the padding
%     x_smooth = x_smooth_padded(pad_size+1:pad_size+N);
%     y_smooth = y_smooth_padded(pad_size+1:pad_size+N);
% end