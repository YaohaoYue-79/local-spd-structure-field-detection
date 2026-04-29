function methodSpecs = method_specs_without_duplicates(varargin)
methodSpecs = struct([]);
seen = containers.Map('KeyType','char','ValueType','logical');
for k = 1:nargin
    groupSpecs = varargin{k};
    for i = 1:numel(groupSpecs)
        name = groupSpecs(i).name;
        if ~isKey(seen, name)
            seen(name) = true;
            if isempty(methodSpecs)
                methodSpecs = groupSpecs(i);
            else
                methodSpecs(end+1) = groupSpecs(i); %#ok<AGROW>
            end
        end
    end
end
end
