function coorRandom = randomInRegionWithFilledRegions(regionWhole, regionFilled, regionSize)

if isempty(regionFilled)
    coorRandom = randomInRegion(regionWhole,1);
else
    while true
        coorRandom = randomInRegion(regionWhole,1);
        region = initRegion(coorRandom,regionSize);
        for i=1:numel(regionFilled)
            isIntersecting = regionItsecOrInside(regionFilled{i}, region);
            if isIntersecting
                break
            end
        end
        if ~isIntersecting
            break
        end
    end
end

end
