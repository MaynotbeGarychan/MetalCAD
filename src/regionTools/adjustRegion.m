function [assemble_gbs,assemble_pbs] = adjustRegion(assemble_gbs,assemble_pbs, fig_matrix_size)
% obtain the size
region_gbs = [min(assemble_gbs.points.coordinate(:,1)), min(assemble_gbs.points.coordinate(:,2));
    max(assemble_gbs.points.coordinate(:,1)), max(assemble_gbs.points.coordinate(:,2))];
region_pbs = [0,0; fig_matrix_size];
% do position adjust
dx = 0 - region_gbs(1,1); dy = 0 - region_gbs(1,2);
assemble_gbs.points.translate('x',dx); 
assemble_gbs.points.translate('y',dy);
% do size adjust
lx_gbs = region_gbs(2,1) - region_gbs(1,1); gbs_ly = region_gbs(2,2) - region_gbs(1,2);
lx_pbs = region_pbs(2,1) - region_pbs(1,1); pbs_ly = region_pbs(2,2) - region_pbs(1,2);
fx = lx_gbs/lx_pbs; fy = gbs_ly/pbs_ly; 
assemble_pbs.points.scale('x',fx); assemble_pbs.points.scale('y',fy); 
end