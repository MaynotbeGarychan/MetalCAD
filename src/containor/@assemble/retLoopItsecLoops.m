function [itsecLoopsIds, itsecLoopsIdxs] = retLoopItsecLoops(obj, loopIdx, additionalInput)
% obtain the segs intersting this loop
if nargin == 2
    [itsecSegsIds, ~] = obj.retLoopItsecSegs(loopIdx);
elseif nargin == 3
    % additionalInput: possible itsec segs of the loops identified by the
    % region method.
    [itsecSegsIds, ~] = obj.retLoopItsecSegs(loopIdx,additionalInput);
else
    error('@assemble - retLoopItsecLoops: check the input. \n');
end

itsecLoopsIdxs = [];

for i=1:length(itsecSegsIds)
    [~, temp] = obj.retLoopsOfTheSeg(itsecSegsIds(i));
    itsecLoopsIdxs = [itsecLoopsIdxs; temp];
end
itsecLoopsIdxs = unique(itsecLoopsIdxs);
itsecLoopsIds = obj.loops(itsecLoopsIdxs).id;

end