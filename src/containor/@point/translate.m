function flag = translate(obj,coor,dx)
    flag = true;
    if strcmp(coor,'x')
        obj.coordinate(:,1) =  obj.coordinate(:,1) + dx;
    elseif strcmp(coor,'y')
        obj.coordinate(:,2) =  obj.coordinate(:,2) + dx;
    else
        error('@point-translate: plesese choose x,y coordinate.\n');
    end
end

