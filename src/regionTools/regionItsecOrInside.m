function flag = regionItsecOrInside(rectA, rectB)
    flag = false;
    % % boundary of rectA and rectB
    % x1A = rectA(1, 1); x2A = rectA(1, 2);
    % y1A = rectA(2, 1); y2A = rectA(2, 2);
    % x1B = rectB(1, 1); x2B = rectB(1, 2);
    % y1B = rectB(2, 1); y2B = rectB(2, 2);
    % 
    % % pts of rectA and rectB
    % xA = [x1A;x2A;x2A;x1A];
    % yA = [y1A;y1A;y2A;y2A];
    % xB = [x1B;x2B;x2B;x1B];
    % yB = [y1B;y1B;y2B;y2B];
    % 
    % % judge pts in rectB
    % for i=1:4
    %     if chkPtInRect(xA(i),yA(i),rectB)
    %         flag = true;
    %         return
    %     end
    %     if chkPtInRect(xB(i),yB(i),rectA)
    %         flag = true;
    %         return
    %     end
    % end

    % chk cross
    flag1 = chkRegionCross(rectA, rectB);
    % chk inside
    flag2 = chkRegionInside(rectA, rectB);
    flag3 = chkRegionInside(rectA, rectB);
    
    flag = flag1 || flag2|| flag3;
end


function flag = chkPtInRect(x,y,rect)
    flag = false;
    if (x>rect(1,1)) && (x<rect(1,2)) && (y>rect(2,1)) && (y<rect(2,2))
        flag = true;
    end
end

function flag = chkRegionCross(rectA, rectB)
    flag = false;
    x1A = rectA(1,1); y1A = rectA(2,1);
    x2A = rectA(1,2); y2A = rectA(2,2);
    x1B = rectB(1,1); y1B = rectB(2,1);
    x2B = rectB(1,2); y2B = rectB(2,2);
    if max(x1A, x1B) <= min(x2A, x2B) && max(y1A, y1B) <= min(y2A, y2B)
        flag = true;
    end
end

function flag = chkRegionInside(rectA, rectB)
    % rectA and rectB are defined by [x1, x2; y1, y2]
    
    % Extract coordinates
    x1A = rectA(1, 1); x2A = rectA(1, 2);
    y1A = rectA(2, 1); y2A = rectA(2, 2);
    
    x1B = rectB(1, 1); x2B = rectB(1, 2);
    y1B = rectB(2, 1); y2B = rectB(2, 2);
    
    % Check if rectA is inside rectB
    if x1A >= x1B && x2A <= x2B && y1A >= y1B && y2A <= y2B
        flag = true;  % rectA is inside rectB
    else
        flag = false; % rectA is not inside rectB
    end
end