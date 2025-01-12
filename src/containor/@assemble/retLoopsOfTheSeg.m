function [loopsId, loopsIdx] = retLoopsOfTheSeg(obj,segId)
 
    boolCell1 = cellfun(@(x) (x == segId)|(x == -segId), obj.loops.segs, 'UniformOutput', false);
    
    boolArr = false(numel(boolCell1),1);
    for i=1:length(boolArr)
        boolArr(i) = any(boolCell1{i});
    end
    
    loopsIdx = find(boolArr);
    loopsId = obj.loops(loopsIdx).id;

end

