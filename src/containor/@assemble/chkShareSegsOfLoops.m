function [bool, shared_segs] = chkShareSegsOfLoops(obj, loop1_idx, loop2_idx)

    loop1_segs = abs(obj.loops(loop1_idx).segs); 
    loop2_segs = abs(obj.loops(loop2_idx).segs); 
    
    shared = ismember(loop1_segs, loop2_segs);
    
    bool = any(shared);
    
    shared_segs = loop1_segs(shared);

end