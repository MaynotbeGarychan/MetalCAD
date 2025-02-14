classdef region
    %REGION 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        range
    end
    
    methods
        function obj = region(id,range)
            if nargin > 0
                obj.id = id; obj.range = range;
            else
                obj.id = zeros([0,1]);
                obj.segs = cell([0,0;0,0]);
            end
        end

%%
        varargout = subsref(obj,s);
        obj = subsasgn(obj,s,varargin);
    end
end

