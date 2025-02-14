function obj = append(obj,varargin)
% use it like
% loops_id = [1;2];
% loops_segs = {[1;2];[2;3]};
% assemble_gbs.loops.append(loops_id, loops_segs);
% 
% or directly append the loops obj
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
        error('@loop-append: provide the enough or suitable varargin.\n');
    end
end