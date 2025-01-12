function [bool,itsecInfo] = chkItsecLoopSeg(obj,loopIdx,segIdx)

% init
itsecInfo = []; bool = false;

% obtain information
loopSegs = obj.loops(loopIdx).segs;

% check intersection
for i = 1:length(loopSegs)

    seg = abs(loopSegs(i));

    [hasItsec, info] = obj.chkItsecTwoSegs(seg, segIdx);

    if hasItsec
        bool = true;

        for j = 1:length(info.itsecVecIdxSeg1)
            info.itsecSeg1Id(j,1) = seg; 
            info.itsecSeg2Id(j,1) = segIdx;
        end
        itsecInfo = structCombine(itsecInfo, info);

    end

end

end

