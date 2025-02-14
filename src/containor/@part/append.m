function obj = append(obj,varargin)
% use it like:
% parts_id = [1;2];
% parts_loops = {[1];[2]};
% parts_type = [PART_TYPE.GRAIN; PART_TYPE.GRAIN];
% assemble_gbs.parts.append(parts_id, parts_loops, parts_type);
% 
% or append the part obj
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
        error('@part-append: provide the enough or suitable varargin.\n');
    end
end