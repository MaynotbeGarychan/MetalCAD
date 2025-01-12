function flag = scale(obj,coor,factor)
    flag = true;
    if strcmp(coor,'x')
        obj.coordinate(:,1) =  obj.coordinate(:,1) .* factor;
    elseif strcmp(coor,'y')
        obj.coordinate(:,2) =  obj.coordinate(:,2) .* factor;
    else
        error('@point-scale: plesese choose x,y coordinate.\n');
    end
end

