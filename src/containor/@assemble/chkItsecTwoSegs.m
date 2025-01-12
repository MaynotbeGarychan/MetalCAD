function [bool, intersectionInfo] = chkItsecTwoSegs(obj, segIdx1, segIdx2)
    
    % 初始化交点信息
    intersectionInfo = []; bool = false;

    % obtain the coordinates of the segments 
    segCoordinate1 = obj.retSegCoordinate(segIdx1);
    segCoordinate2 = obj.retSegCoordinate(segIdx2);

    for i=1:size(segCoordinate1,1)-1
        p1 = segCoordinate1(i,1:2); p2 = segCoordinate1(i+1,1:2); 

        for j=1:size(segCoordinate2,1)-1
            q1 = segCoordinate2(j,1:2); q2 = segCoordinate2(j+1,1:2); 
            
            % check
            [hasIntersection, intersectionPoint] = checkIntersection(p1, p2, q1, q2);
            
            % if has intersection
            if hasIntersection
                bool = true;
                % 记录交点和相交的段号
                info.itsecPointCoor = intersectionPoint;
                info.itsecVecIdxSeg1 = i; % 第i段
                info.itsecVecIdxSeg2 = j; % 第j段
                intersectionInfo = structCombine(intersectionInfo, info);
            end
        end

    end

end

function [hasIntersection, intersectionPoint] = checkIntersection(p1, p2, q1, q2)
    % 输入:
    % p1, p2: 第一个线段的两个端点，格式为 [x, y]
    % q1, q2: 第二个线段的两个端点，格式为 [x, y]
    % 输出:
    % hasIntersection: 布尔值，是否有交点
    % intersectionPoint: 若有交点，则为交点坐标 [x, y]，否则为 [NaN, NaN]

    % 初始化输出
    hasIntersection = false;
    intersectionPoint = [NaN, NaN];

    % 计算线段的方向向量
    r = p2 - p1;
    s = q2 - q1;

    % 计算向量叉积
    rxs = r(1) * s(2) - r(2) * s(1);
    qmp = q1 - p1;
    qmpxr = qmp(1) * r(2) - qmp(2) * r(1);

    if rxs == 0 && qmpxr == 0
        % 线段共线
        t0 = dot(qmp, r) / dot(r, r);
        t1 = t0 + dot(s, r) / dot(r, r);
        if (t0 >= 0 && t0 <= 1) || (t1 >= 0 && t1 <= 1)
            hasIntersection = true;
            intersectionPoint = p1 + t0 * r;
        end
    elseif rxs ~= 0
        % 线段相交
        t = (qmp(1) * s(2) - qmp(2) * s(1)) / rxs;
        u = (qmp(1) * r(2) - qmp(2) * r(1)) / rxs;
        if t >= 0 && t <= 1 && u >= 0 && u <= 1
            hasIntersection = true;
            intersectionPoint = p1 + t * r;
        end
    end
end