function organizePartsLoopForGmsh(obj)

for i=1:length(obj.parts)
    partLoops = obj.parts(i).loops;
    % check with the part with multiple loops
    if length(partLoops) > 1
        % classify the loops
        baseLoop = partLoops(1);
        otherLoop = partLoops(2:end);
        innerLoop = otherLoop(otherLoop < 0);
        outsideLoop = otherLoop(otherLoop > 0);
        if isempty(outsideLoop) % only have inner loop
            continue
        else
            %
            obj.parts(i).loops = baseLoop;
            % organize for the outside loop
            partIdsOfOutsideLoop = NaN(length(outsideLoop),1);
            for j=1:length(outsideLoop)
                newPartId = length(obj.parts)+1;
                obj.parts.append(newPartId,{[outsideLoop(j)]},PART_TYPE.GRAIN);
                partIdsOfOutsideLoop(j) = newPartId;
            end
            if isempty(innerLoop)
                continue
            else
                % know the inner loop is in which loop?
                for j=1:length(otherLoop)
                    if obj.chkLoopInsideLoop(abs(otherLoop(j)), baseLoop)
                        obj.parts(i).loops = [obj.parts(i).loops; otherLoop(j)];
                    else
                        for k=1:length(outsideLoop)
                            if obj.chkLoopInsideLoop(abs(otherLoop(j)), outsideLoop(k))
                                obj.parts(partIdsOfOutsideLoop(k)).loops = [obj.parts(partIdsOfOutsideLoop(k)).loops; otherLoop(j)];
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end



end

