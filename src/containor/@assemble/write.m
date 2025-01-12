function write(assemble,file_dir, lc)
    fprintf("@assemble-write: begin writing the information to the geo file.\n");
    file_io = fopen(file_dir,"w");
    % fprintf(file_io,'lc= %f ;\n', lc);
    assemble.points.write(file_io,lc);
    assemble.segs.write(file_io);
    assemble.loops.write(file_io);
    assemble.parts.write(file_io);
    fclose(file_io);
    fprintf("@assemble-write: finish writing the information to the geo file.\n");
end