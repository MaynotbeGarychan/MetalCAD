function initSegType(obj)
    segment_type_arr = NaN([length(obj.segs.id) 1]);
    for i=1:length(segment_type_arr)
        if obj.segs.parts(i,1) == 0; type1 = PART_TYPE.EDGE; else; type1 = obj.parts.type(obj.segs.parts(i,1)); end
        if obj.segs.parts(i,2) == 0; type2 = PART_TYPE.EDGE; else; type2 = obj.parts.type(obj.segs.parts(i,2)); end
        if type1 == PART_TYPE.GRAIN && type2 == PART_TYPE.GRAIN
            segment_type_arr(i) = SEGMENT_TYPE.GRAIN_GRAIN;
        elseif (type1 == PART_TYPE.GRAIN && type2 == PART_TYPE.EDGE) || (type1 == PART_TYPE.EDGE && type2 == PART_TYPE.GRAIN)
            segment_type_arr(i) = SEGMENT_TYPE.GRAIN_EDGE;
        elseif (type1 == PART_TYPE.GRAIN && type2 == PART_TYPE.PARTICLE) || (type1 == PART_TYPE.PARTICLE && type2 == PART_TYPE.GRAIN)
            segment_type_arr(i) = SEGMENT_TYPE.GRAIN_PARTICLE;
        elseif (type1 == PART_TYPE.PARTICLE && type2 == PART_TYPE.EDGE) || (type1 == PART_TYPE.EDGE && type2 == PART_TYPE.PARTICLE)
            segment_type_arr(i) = SEGMENT_TYPE.PARTICLE_EDGE;
        elseif type1 == PART_TYPE.PARTICLE && type2 == PART_TYPE.PARTICLE
            segment_type_arr(i) = SEGMENT_TYPE.PARTICLE_PARTICLE;
        else
            error('init_segment_type: current segment type is not supported.\n');
        end
    end
    obj.segs.type = segment_type_arr;
end