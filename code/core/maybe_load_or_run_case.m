function out = maybe_load_or_run_case(cacheFile, runFcn)
if exist(cacheFile, 'file')
    S = load(cacheFile);
    if isfield(S, 'out')
        out = S.out;
    else
        error('Cache file exists but variable ''out'' is missing: %s', cacheFile);
    end
    fprintf('Skip existing case: %s\n', cacheFile);
    return;
end

out = runFcn();

cacheDir = fileparts(cacheFile);
if ~exist(cacheDir, 'dir')
    mkdir(cacheDir);
end
save(cacheFile, 'out', '-v7.3');
fprintf('Saved case cache: %s\n', cacheFile);
end
