function dist = periodicDistance(totalLen, idx1, idx2)
    % Calculate the direct distance
    directDist = abs(idx1 - idx2);
    
    % Calculate the periodic distance
    periodicDist = min(directDist, totalLen - directDist);
    
    % Return the periodic distance
    dist = periodicDist;
end