% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% source file of the class point
% ------------------------------------------------------------------------
classdef point < handle
    properties
        id
        coordinate
    end
    methods
% -------------------------------------------------------------------------
% constructor
% -------------------------------------------------------------------------
        function obj = point(id,coordinate)
            if nargin > 0
                obj.id = id; obj.coordinate = coordinate; 
            elseif nargin == 0
                obj.id = zeros([0,1]);
                obj.coordinate = zeros([0,2]);
            end
        end
% -------------------------------------------------------------------------
% methods in external function
% -------------------------------------------------------------------------
        flag = translate(obj,coor,dx);
        flag = scale(obj,coor,factor);
        flag = write(obj,output,lc);
        obj = append(obj,varargin);
        % a = equiv(obj,thres);
        new = copy(obj);
        [flag, existed_id] = chk_duplicated(points, onepoint, thres);
        val = distance(obj,basePIdx,otherPIdx);
% -------------------------------------------------------------------------
% overloaded method in external function
% -------------------------------------------------------------------------
        varargout = subsref(obj,s);
        obj = subsasgn(obj,s,varargin);
% -------------------------------------------------------------------------
% overloaded method
% -------------------------------------------------------------------------
        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.id,varargin{:});
        end

        function ind = end(obj,k,n)
            s = size(obj);
            if k < n; ind = s(k); else; ind = prod(s(k:end)); end
        end

        function obj = cat(~,varargin)
            obj = point.empty;
            props = properties(obj);
            for i = 1:numel(varargin)
                temp = varargin{i};
                if isempty(temp), continue; end
                for j=1:length(props)
                    prop = props{j};
                    obj.(prop) = [obj.(prop);temp.(prop)];
                end
            end
        end

        function out = length(obj); out = length(obj.id); end

        function out = num(obj);out = length(obj.id);end

        function n = numArgumentsFromSubscript(obj,s,indexingContext)
        % overloaded method to avoid Output argument "varargout{2}" not
        % assigned value error
            n = 1;
        end
    end

% -------------------------------------------------------------------------
% static method
% -------------------------------------------------------------------------
    methods (Static)
        function obj = empty(varargin); obj = point(varargin{:}); end
    end
end
