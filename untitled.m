clc
clear
close all
%% directory
work_dir = 'C:\Users\garyc\Desktop\test_czm\result\';
log_dir = [work_dir 'log.txt'];

%% obtain the data
% Read the file as a table
opts = detectImportOptions(log_dir, 'Delimiter', ',');
opts.VariableNames = {'specimen', 'ori', 'particle', 'position', 'time_f'};
opts.VariableTypes = {'char', 'char', 'char', 'char', 'double'};
data = readtable(log_dir, opts);
num_case = size(data,1);

%%

for i=1:num_case
    if data.time_f(i) < 0
        continue
    end
    distance = analyze_one_case(data.specimen{i}, data.ori{i}, data.particle{i}, data.position{i}, data.time_f(i), work_dir);
    plot(distance(3,:), distance(2,:),'Marker','o','LineWidth',1.5); hold on
end
hold off
%%

function distance = analyze_one_case(specimen,ori,particle,position,time_f,work_dir)
    % read data
    csv_dir = [work_dir position '_' particle '_' specimen '_' ori '.csv'];
    data = readmatrix(csv_dir,"NumHeaderLines",2);
    time_list = data(:,1);
    x = data(:,2:9); y = data(:,10:17); z = data(:,18:25);
    nodes_coor = cell(1, 8);
    for i=1:8
        nodes_coor{i} = [x(:,i), y(:,i), z(:,i)]';
    end
    
    % obtain the failed step
    falied_step = find(time_list > time_f, 1 );

    % calculate the distance
    distance = zeros([3 falied_step]);
    for i=1:falied_step
        % obtain all point
        pts = zeros([3 8]);
        for j=1:8
            pts(:,j) = nodes_coor{j}(:,i);
        end
    
        % tranform to local center
        center = mean(pts,2);
        for j=1:8
            pts(:,j) = pts(:,j) - center;
        end
    
        % generate the coordinate
        n = normal_vector(pts(:,1), pts(:,2), pts(:,3));
        [t1,t2] = tangent_vector(n, pts(:,1), pts(:,2));
        rot = tranformation_matrix(t1,t2,n);
    
        % tranform to local coordinate
        pts_local = zeros([3 8]);
        for j=1:8
            pts_local(:,j) = rot' * pts(:,j);
        end
    
        % calculate the distance
        face1_center_local = mean(pts_local(:,1:4),2);
        face2_center_local = mean(pts_local(:,5:8),2);
        distance(:,i) = abs(face2_center_local - face1_center_local);
    end

end


%% function for coordinate system
function N = normal_vector(P1, P2, P3)
    v1 = P2 - P1; 
    v2 = P3 - P1; 
    N = cross(v1, v2); 
    N = N / norm(N); 
end

function [T1,T2] = tangent_vector(N, P1, P2)
    T1 = P2 - P1;
    T1 = T1 / norm(T1);
    T2 = cross(N,T1);
    T2 = T2 / norm(T1);
end

function T = tranformation_matrix(T1,T2,N)
    T = [T1,T2,N];
end