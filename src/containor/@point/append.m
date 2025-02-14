function obj = append(obj,varargin)
%
% Use it like:
% pts_id = [1;2;3;4;5;6];
% pts_coor = [0,100; 0,0; 100,0; 100,100; 50,0; 50,100];
% assemble.points.append(pts_id, pts_coor);
% 
% or directly append the points obj
%
    props = properties(obj);
    num_prop = numel(props);
    if nargin == 2
        for i=1:numel(props)
            prop = props{i};
            obj.(prop) = [obj.(prop);varargin{1}.(prop)];
        end
    elseif nargin == num_prop + 1
        for i=1:numel(props)
            prop = props{i};
            obj.(prop) = [obj.(prop);varargin{i}];
        end
    else
        error('@point-append: provide the enough or suitable varargin.\n');
    end
end