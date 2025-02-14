function plotLoop(assemble, loop_idx, color)

if ischar(loop_idx)
    if ~strcmp(loop_idx, 'all')
        error('@assemble - plotLoop: check the input string.\n');
    end
    for i=1:assemble.loops.num
        segs = assemble.loops(i).segs;
        for j=1:length(segs)
            assemble.plotSeg(abs(segs(j)), color);
        end
    
    end
else
    for i=1:length(loop_idx)
        segs = assemble.loops(loop_idx(i)).segs;
    
        for j=1:length(segs)
            assemble.plotSeg(abs(segs(j)), color);
        end
    
    end
end
end