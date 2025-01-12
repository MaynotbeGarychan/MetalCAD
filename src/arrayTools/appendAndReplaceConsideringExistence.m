function loops = appendAndReplaceConsideringExistence(loops, addLoops)
    for i=1:length(addLoops)
        idx = find(loops.id == addLoops(i).id);
        if isempty(idx)
            loops.append(addLoops(i));
        elseif isscalar(idx)
            loops(idx) = addLoops(i);
        else
            error('appendAndReplaceConsideringExistence:Multiple existence of the current id detected.');
        end
    end
end