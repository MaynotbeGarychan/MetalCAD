% ------------------------------------------------------------------------
% Author: Chen,Jiawei
%
% Description: 
% source file of the class segment
% ------------------------------------------------------------------------
classdef segment < handle
    %GBSEG Summary of this class goes here
    %   Detailed explanation goes here
    properties
        id
        points
        parts
        type
    end
    
    methods
% -------------------------------------------------------------------------
% constructor
% -------------------------------------------------------------------------
    function obj = segment(id,points,parts,type)
        if nargin > 0
            obj.id = id; obj.points = points; obj.parts = parts;
            obj.type = type;
        elseif nargin == 0
            obj.id = zeros([0,1]);
            obj.points = cell([0,1]);
            obj.parts = zeros([0,2]);
            obj.type = zeros([0,1]);
        end
    end
% -------------------------------------------------------------------------
% methods in external function
% -------------------------------------------------------------------------
    flag = write(obj,output);
    obj = append(obj,varargin);
    segs = copy(obj, idxs);
    [seg1, seg2] = split(obj, seg_idx, pos_idx, insert_point_id);
    obj = subsasgn(obj,s,varargin);
% -------------------------------------------------------------------------
% overloaded method
% -------------------------------------------------------------------------
    varargout = subsref(obj,s);
% -------------------------------------------------------------------------
%  method
% -------------------------------------------------------------------------
    function arr = ret_points_oriented(obj, idx)
        idx_abs = abs(idx);
        arr = obj.points(idx_abs);
        arr = arr{1};
        if idx < 0
            arr = flip(arr);
        end
    end

    function arr = ret_points(obj, idx_arr)
        arr = [];
        if nargin > 1
            for i=1:length(idx_arr)
                seg_idx = idx_arr(i);
                points_arr = obj.ret_points_oriented(seg_idx);
                arr = [arr; points_arr];
            end
        else
            for i=1:length(obj.id)
                points_arr = obj.ret_points_oriented(i);
                arr = [arr; points_arr];
            end
        end
    end

    function arr = ret_inner_points(obj, idx_arr)
        arr = [];
        if nargin > 1
            for i=1:length(idx_arr)
                seg_idx = idx_arr(i);
                points_arr = obj.ret_points_oriented(seg_idx);
                arr = [arr; points_arr(2:end-1)];
            end
        else
            for i=1:length(obj.id)
                points_arr = obj.ret_points_oriented(i);
                arr = [arr; points_arr(2:end-1)];
            end
        end
    end

    function arr = ret_tripple_points(obj, idx_arr)
        arr = [];
        if nargin > 1
            for i=1:length(idx_arr)
                seg_idx = idx_arr(i);
                points_arr = obj.ret_points_oriented(seg_idx);
                arr = [arr; points_arr(1); points_arr(end)];
            end
        else
            for i=1:length(obj.id)
                points_arr = obj.ret_points_oriented(i);
                arr = [arr; points_arr(1); points_arr(end)];
            end
        end
    end
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
            obj = segment.empty;
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
        function obj = empty(varargin); obj = segment(varargin{:}); end
    end
end