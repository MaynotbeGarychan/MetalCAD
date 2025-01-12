function varargout = subsref(obj,s)
   switch s(1).type
      case '.'
         if isscalar(s)
             % Implement obj.PropertyName
             prop = s.subs;
             [varargout{1:nargout}] = obj.(prop);
         elseif length(s) == 2 && strcmp(s(2).type,'()')
             % Implement obj.PropertyName(indices)
             prop = s(1).subs;
             [varargout{1:nargout}] = obj.(prop)(s(2).subs{:});
         else
            % Use built-in for any other expression
            [varargout{1:nargout}] = builtin('subsref',obj,s);
         end
      case '()'
         if isscalar(s)
            % Implement obj(indices)
            varargout{1} = point.empty;
            props = properties(obj);
            for i=1:length(props)
                varargout{1}.(props{i}) = obj.(props{i})(s.subs{1},:);
            end
         elseif length(s) == 2 && strcmp(s(2).type,'.')
            % Implement obj(ind).PropertyName
            prop = s(2).subs; idx = s(1).subs{1}; temp = obj.(prop)(idx,:);
            if iscell(temp) && isscalar(temp)
                varargout{1} = temp{1};
            else
                varargout{1} = temp;
            end
         elseif length(s) == 3 && strcmp(s(2).type,'.') && strcmp(s(3).type,'()')
            % Implement obj(indices).PropertyName(indices)
            prop = s(2).subs; idx1 = s(1).subs{1}; 
            % idx2 = s(3).subs{:}; 
            temp = obj.(prop)(idx1,:);
            if iscell(temp); temp = temp{1}; end
            varargout{1} = temp(s(3).subs{:});
         else
            % Use built-in for any other expression
            [varargout{1:nargout}] = builtin('subsref',obj,s);
         end
      otherwise
         error('Not a valid indexing expression')
   end
end