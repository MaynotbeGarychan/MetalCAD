function seedCoor = randomSeeds(xRange,yRange,numSeeds)
    seedCoor = NaN(numSeeds,2);
    seedCoor(:,1) = xRange(1) + (xRange(2)-xRange(1)) * rand(numSeeds, 1);
    seedCoor(:,2) = yRange(1) + (yRange(2)-yRange(1)) * rand(numSeeds, 1);
end