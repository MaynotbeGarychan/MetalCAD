function [bool, itsecLoopInfo] = chkItsecTwoLoops(obj, loopIdx1, loopIdx2)

% init
itsecLoopInfo = []; bool = false;

% obtain the segs
loop1Segs = obj.loops(loopIdx1).segs;
loop2Segs = obj.loops(loopIdx2).segs;

% loop over all the segments
for i = 1:length(loop1Segs)

    seg1 = abs(loop1Segs(i));

    for j = 1:length(loop2Segs)

        seg2 = abs(loop2Segs(j));

        [hasItsec, itsecSegInfo] = obj.chkItsecTwoSegs(seg1, seg2);

        if hasItsec
            bool = true;
            info = [];
            for k = 1:length(itsecSegInfo)
                % save result
                info.itsecPointCoor = itsecSegInfo(k).itsecPointCoor;
                info.itsecVecIdxSeg1 = itsecSegInfo(k).itsecVecIdxSeg1; % 第i段
                info.itsecVecIdxSeg2 = itsecSegInfo(k).itsecVecIdxSeg2; % 第j段
                info.itsecSeg1Id = seg1; 
                info.itsecSeg2Id = seg2;
                itsecLoopInfo = structCombine(itsecLoopInfo, info);
            end
        end

    end

end

end