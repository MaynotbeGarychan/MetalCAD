function loops = copy(obj, idxs)

    % init
    props = properties(obj);
    loops = loop();

    % if the nargin is 1, means no idxs input, copy the object itself
    if nargin == 1
        
        for i=1:length(obj)
            aloop = loop();
            for j=1:numel(props)
                prop = props{j};
                aloop.(prop) = obj(i).(prop);
            end
            loops.append(aloop);
        end

    elseif nargin == 2
    
        for i=1:length(idxs)
            idx = idxs(i);
            aloop = loop();
            for j=1:numel(props)
                prop = props{j};
                aloop.(prop) = obj.(prop)(idx,:);
            end
            loops.append(aloop);
        end

    else
        error('@loop-copy: please check the number of variables inputed!\n')
    end

end