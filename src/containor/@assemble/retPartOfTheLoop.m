function [partsId,partsIdx] = retPartOfTheLoop(obj, loopId)

    parts_loops = obj.parts.loops;
    
    bool_cell = cellfun(@(x) x == loopId, parts_loops, 'UniformOutput', false);
    
    bool_arr = false(numel(bool_cell),1);
    for i=1:length(bool_arr)
        bool_arr(i) = any(bool_cell{i});
    end
    
    partsIdx = find(bool_arr);
    partsId = obj.parts(partsIdx).id;

end