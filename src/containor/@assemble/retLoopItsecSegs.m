function [itsecSegsIds,itsecSegsIdxs] = retLoopItsecSegs(obj, loopIdx)

% init containor
itsecSegsIdxs = [];

% 
segsOfAllLoop = obj.segs.id;
segsOfTheLoop = obj.loops(loopIdx).segs;
segsOfOtherLoop = setdiff(segsOfAllLoop, segsOfTheLoop);

for i=1:length(segsOfOtherLoop)

    currSegIdx = segsOfOtherLoop(i);

    for j=1:length(segsOfTheLoop)

        currSegsOfTheLoopIdx = segsOfTheLoop(j);
        
        if obj.chkItsecTwoSegs(currSegsOfTheLoopIdx, currSegIdx)
            itsecSegsIdxs = [itsecSegsIdxs; currSegIdx];
            break
        end

    end

end

itsecSegsIds = obj.segs(itsecSegsIdxs).id;

end

