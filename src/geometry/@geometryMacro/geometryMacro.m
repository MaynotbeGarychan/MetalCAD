classdef geometryMacro
    methods(Static)
        assemble_temp = makeRectangle(x1,y1,x2,y2,seg_type,part_type);

        assembleCopy = cropPartByInsideLoop(assembleAll, partIdx, loopIdx);

        assemble_temp =  makeRectangleWithGb(x1,y1,x2,y2);

    end
end

