function [itsecLoopsIds, itsecLoopsIdxs] = retLoopItsecLoops(obj, loopIdx)

% obtain the segs intersting this loop
[itsecSegsIds, ~] = obj.retLoopItsecSegs(loopIdx);

itsecLoopsIdxs = [];

for i=1:length(itsecSegsIds)
    [~, temp] = obj.retLoopsOfTheSeg(itsecSegsIds(i));
    itsecLoopsIdxs = [itsecLoopsIdxs; temp];
end
itsecLoopsIdxs = unique(itsecLoopsIdxs);
itsecLoopsIds = obj.loops(itsecLoopsIdxs).id;

end