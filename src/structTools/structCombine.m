function output = structCombine(struct1,struct2)

% obtain the fields
fields = fieldnames(struct2);

% if the stuct is empty, we have to init its fields
if isempty(struct1)
    for i=1:numel(fields)
        field = fields{i};
        struct1.(field) = [];
    end
end

% combine
for i=1:numel(fields)
    field = fields{i};
    output.(field) = [struct1.(field);struct2.(field)];
end

end

