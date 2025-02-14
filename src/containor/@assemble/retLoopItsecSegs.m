function [itsecSegsIds,itsecSegsIdxs] = retLoopItsecSegs(obj, loopIdx, additionalInput)

% init containor
itsecSegsIdxs = [];
segsOfTheLoop = obj.loops(loopIdx).segs;

if nargin == 2
    segsOfAllLoop = obj.segs.id;
elseif nargin == 3
    segsOfAllLoop = additionalInput;
else
    error('@assemble - retLoopItsecSegs: check the input. \n');
end

% remove its own segs
segsOfOtherLoop = setdiff(segsOfAllLoop, segsOfTheLoop);

% begin to check
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

