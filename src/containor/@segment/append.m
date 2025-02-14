function obj = append(obj,varargin)
% Use it like:
% segs_id = [1;2;3];
% segs_pts = {[6;1;2;5];[5;6];[6;4;3;5]};
% segs_parts = [1,NaN; 1,2; 2, NaN];
% segs_type = [SEGMENT_TYPE.GRAIN_EDGE; SEGMENT_TYPE.GRAIN_GRAIN; SEGMENT_TYPE.GRAIN_EDGE];
% assemble_gbs.segs.append(segs_id, segs_pts, segs_parts, segs_type);
% 
% or directly append the segs obj
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
        error('@segment-append: provide the enough or suitable varargin.\n');
    end
end