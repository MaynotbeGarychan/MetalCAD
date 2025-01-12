function parts = copy(obj, idxs)

    % init
    props = properties(obj);
    parts = part();

    % if the nargin is 1, means no idxs input, copy the object itself
    if nargin == 1
        
        for i=1:length(obj)
            aloop = part();
            for j=1:numel(props)
                prop = props{j};
                aloop.(prop) = obj(i).(prop);
            end
            parts.append(aloop);
        end

    elseif nargin == 2
    
        for i=1:length(idxs)
            idx = idxs(i);
            aloop = part();
            for j=1:numel(props)
                prop = props{j};
                aloop.(prop) = obj.(prop)(idx,:);
            end
            parts.append(aloop);
        end

    else
        error('@part-copy: please check the number of variables inputed!\n')
    end

end