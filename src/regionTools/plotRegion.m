function plotRegion(region,color)
    x = [region(1,1); region(1,2); region(1,2); region(1,1); region(1,1)];
    y = [region(2,1); region(2,1); region(2,2); region(2,2); region(2,1)];
    plot(x,y,color); hold on
end