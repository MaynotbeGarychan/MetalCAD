function assemble_pb = getAssemblePb(file_dir)

if endsWith(file_dir,'.mat')
    temp = load(file_dir);
    assemble_pb = temp.assemble_pbs;
elseif endsWith(file_dir,'.geo')
    assemble_pb = gmshTool.readGeoFile(file_dir, SEGMENT_TYPE.GRAIN_PARTICLE, PART_TYPE.PARTICLE);
end

end

