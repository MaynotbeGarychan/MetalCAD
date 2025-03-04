function flag = write(obj,output,lc)
    fprintf("@point-write: begin writing the information to the geo file.\n");
    flag = false;
    if ischar(output)
        file_io = fopen(file_dir,"w");
        write_with_io(obj,file_io,lc);
        flag = true;
        fclose(file_io,lc);
    elseif isnumeric(output)
        write_with_io(obj,output,lc);
        flag = true;
    else
        error('@point-write: provide the IO or file directory.\n');
    end
    fprintf("@loop-write: finish writing the information to the geo file.\n");
end

function write_with_io(points, file_io,lc)

    if isscalar(lc)
        lc_arr = ones([length(points) 1])*lc;
    else
        lc_arr = lc;
    end
    if size(points.coordinate,2) == 2
        zcoor = zeros([length(points.id) 1]);
        for i=1:length(points.id)
            fprintf(file_io,'Point(%d) = {%f, %f, %f, %f};\n', ...
                points.id(i),points.coordinate(i,1),points.coordinate(i,2),zcoor(i),lc_arr(i));
        end
    elseif size(points.coordinate,2) == 3
        for i=1:length(points.id)
            fprintf(file_io,'Point(%d) = {%f, %f, %f, %f};\n', ...
                points.id(i),points.coordinate(i,1),points.coordinate(i,2),points.coordinate(i,3),lc_arr(i));
        end
    end
end