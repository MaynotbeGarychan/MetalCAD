function obj = subsasgn(obj,s,varargin)
   % Allow subscripted assignment to uninitialized variable
   if isequal(obj,[])
      obj = segment.empty; % untested
   end

   switch s(1).type
       case '.'
           if isscalar(s)
                % Implement obj.PropertyName = varargin{:};
                prop = s.subs;
                if isempty(varargin{:})
                    obj.(prop)(:,:) = [];
                else
                    obj.(prop)(:,:) = varargin{:};
                end
           elseif length(s) == 2 && strcmp(s(2).type,'()')
               % Implement obj.PropertyName(indices) = varargin{:};
               prop = s(1).subs;
               obj.(prop)(s(2).subs{:}) = varargin{:};
           else
               obj = builtin('subsasgn',obj,s,varargin{:});
           end
       case '()'
            if isscalar(s)
                % Implement obj(indices) = varargin{:};
                props = properties(obj); indices = s(1).subs{:};
                if isempty(varargin{:})
                    for i=1:length(props)
                        obj.(props{i})(indices,:) = [];
                    end
                else
                    for i=1:length(props)
                        obj.(props{i})(indices,:) = varargin{:}.(props{i});
                    end
                end
           elseif length(s) == 2 && strcmp(s(2).type,'.')
                % Implement obj(indices).PropertyName = varargin{:};
                prop = s(2).subs; indices = s(1).subs{1};
                if ~ismember(prop, properties(obj)); error('Property %s does not exist in the %s class.', prop, class(obj)); end
                if iscell(obj.(prop)(indices, :)); obj.(prop)(indices, :) = {varargin{:}};
                    else; obj.(prop)(indices, :) = varargin{:};
                end
           elseif length(s) == 3 && strcmp(s(2).type,'.') && strcmp(s(3).type,'()')
                % Implement obj(indices).PropertyName(indices) = varargin{:};
                obj = builtin('subsasgn',obj,s,varargin{:});
           else
                % Use built-in for any other expression
                obj = builtin('subsasgn',obj,s,varargin{:});
           end  
       otherwise
            error('Not a valid indexing expression')
   end     
end