function flag = write(obj,output)
    fprintf("@part-write: begin writing the information to the geo file.\n");
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
        error('@part-write: provide the IO or file directory.\n');
    end
    fprintf("@part-write: finish writing the information to the geo file.\n");
end

function write_with_io(parts, file_io)
    for i=1:length(parts.id)
        n = length(parts.loops{i});
        astring = ['Plane Surface(%d) = {', repmat('%d, ', 1, n-1), '%d};\n'];
        fprintf(file_io,astring,parts.id(i),parts.loops{i});
    end
end