function idx = retExtPointOnPolygonLoopPosition(point_coor, loop_coor)
    % 1-tpp-2 return 1
    % init
    vertices_begin = loop_coor;
    vertices_end = loop_coor([2:end,1],1:2);
    % fliter by position
    a1 = (vertices_begin(:,1) < point_coor(1)) & (vertices_end(:,1) > point_coor(1));
    a2 = (vertices_begin(:,1) > point_coor(1)) & (vertices_end(:,1) < point_coor(1));
    a = a1 | a2;
    b1 = (vertices_begin(:,2) < point_coor(2)) & (vertices_end(:,2) > point_coor(2));
    b2 = (vertices_begin(:,2) > point_coor(2)) & (vertices_end(:,2) < point_coor(2));
    b = b1 | b2;
    c = a & b;
    % summarize
    idx = find(c);
    % return if there is only one suitable
    if isscalar(idx); return; end
    % if tpp in other rectangle, use direction to identify
    temp = [];
    for i=1:length(idx)
        if chkCollinearThreePoints(vertices_begin(idx(i),1:2), [point_coor(1), point_coor(2)] , ...
                vertices_end(idx(i),1:2))
            temp = [temp; idx(i)];
        end
    end
    idx = temp;
    if isscalar(idx); return; else; error('retExtPointOnPolygonLoopPosition: failed to find the external point position in the loop.\n'); end
end