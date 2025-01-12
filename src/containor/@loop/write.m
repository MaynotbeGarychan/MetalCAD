function flag = write(obj,output)
    fprintf("@loop-write: begin writing the information to the geo file.\n");
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
        error('@loop-write: provide the IO or file directory.\n');
    end
    fprintf("@loop-write: finish writing the information to the geo file.\n");
end

function write_with_io(loops, file_io)
    for i=1:length(loops.id)
        n = length(loops.segs{i});
        astring = ['Curve Loop(%d) = {', repmat('%d, ', 1, n-1), '%d};\n'];
        fprintf(file_io,astring,loops.id(i),loops.segs{i});
    end
end