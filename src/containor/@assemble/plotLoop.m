function plotLoop(assemble, loop_idx, color)

for i=1:length(loop_idx)
    segs = assemble.loops(loop_idx(i)).segs;

    for j=1:length(segs)
        assemble.plotSeg(abs(segs(j)), color);
    end

end

end