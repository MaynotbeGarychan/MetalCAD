function flag = write(obj,output)
    fprintf("@segment-write: begin writing the information to the geo file.\n");
    flag = false;
    if ischar(output)
        file_io = fopen(file_dir,"w");
        write_with_io(obj,file_io);
        flag = true;
        fclose(file_io);
    elseif isnumeric(output)
        write_with_io(obj,output);
        flag = true;
    else
        error('@segment-write: provide the IO or file directory.\n');
    end
    fprintf("@segmetn-write: finish writing the information to the geo file.\n");
end

function write_with_io(segs, file_io)
    for i=1:length(segs.points)
        n = length(segs.points{i});
        astring = ['Line(%d) = {', repmat('%d, ', 1, n-1), '%d};\n'];
        % astring = ['BSpline(%d) = {', repmat('%d, ', 1, n-1), '%d};\n'];
        fprintf(file_io,astring,segs.id(i),segs.points{i});
    end
end