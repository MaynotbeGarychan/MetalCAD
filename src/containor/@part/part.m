classdef part < handle
    properties
        id
        loops
        type
    end

    methods
% -------------------------------------------------------------------------
% constructor
% -------------------------------------------------------------------------
        function obj = part(id,loops,type)
            if nargin > 0
                obj.id = id;
                obj.loops = loops;
                obj.type = type;
            elseif nargin == 0
                obj.id = zeros([0,1]);
                obj.loops = cell([0,1]);
                obj.type = zeros([0,1]);
            end
        end
% -------------------------------------------------------------------------
% methods in external function
% -------------------------------------------------------------------------
        flag = write(obj,output);
        obj = append(obj,varargin);
        parts = copy(obj, idxs);
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
            obj = part.empty;
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
        function obj = empty(varargin); obj = part(varargin{:}); end
    end

end

