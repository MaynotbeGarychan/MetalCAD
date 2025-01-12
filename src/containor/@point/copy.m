function new = copy(obj)
    new = point();
    props = properties(obj);
    for i=1:numel(props)
        prop = props{i};
        new.(prop) = obj.(prop);
    end
end