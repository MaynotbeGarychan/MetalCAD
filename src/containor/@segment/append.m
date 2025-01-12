function obj = append(obj,varargin)
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
        error('@segment-append: provide the enough or suitable varargin.\n');
    end
end