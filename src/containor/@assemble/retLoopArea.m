function area = retLoopArea(obj,input)

if isscalar(input)
    loopidx = input;
    [coor, ~, ~, ~] = obj.retLoopPoints(loopidx);
    area = polyarea(coor(:,1), coor(:,2));

elseif ischar(input)
    if strcmp(input,'all')
        area = 0;
        for i=1:length(obj.loops)
            [coor, ~, ~, ~] = obj.retLoopPoints(i);
            area = area + polyarea(coor(:,1), coor(:,2));
        end
    end

elseif isarray(input)
    area = 0;
    for i=1:length(input)
        loopidx = input(i);
        [coor, ~, ~, ~] = obj.retLoopPoints(loopidx);
        area = area + polyarea(coor(:,1), coor(:,2));
    end
end

end

