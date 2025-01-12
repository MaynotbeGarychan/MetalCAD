function segs = copy(obj, idxs)

    % init
    props = properties(obj);
    segs = segment();

    % if the nargin is 1, means no idxs input, copy the object itself
    if nargin == 1
        
        for i=1:length(obj)
            aseg = segment();
            for j=1:numel(props)
                prop = props{j};
                aseg.(prop) = obj(i).(prop);
            end
            segs.append(aseg);
        end

    elseif nargin == 2
    
        for i=1:length(idxs)
            idx = idxs(i);
            aseg = segment();
            for j=1:numel(props)
                prop = props{j};
                aseg.(prop) = obj.(prop)(idx,:);
            end
            segs.append(aseg);
        end

    else
        error('@segment-copy: please check the number of variables inputed!\n')
    end

end