function nWorkersUsed = ensure_local_pool_fast(nWorkers)
if nargin < 1 || isempty(nWorkers)
    nWorkers = 4;
end

c = parcluster('local');

jobDir = '/tmp/matlab_job_storage';
if ~exist(jobDir, 'dir')
    mkdir(jobDir);
end
try
    c.JobStorageLocation = jobDir;
    saveProfile(c);
catch
end

maxWorkers = c.NumWorkers;
if isempty(maxWorkers) || ~isscalar(maxWorkers) || isnan(maxWorkers)
    maxWorkers = nWorkers;
end
nWorkersUsed = min(nWorkers, maxWorkers);

p = gcp('nocreate');
if isempty(p) || p.NumWorkers ~= nWorkersUsed
    delete(gcp('nocreate'));
    p = parpool('local', nWorkersUsed);
else
    p = gcp;
end

try
    p.IdleTimeout = 240;
catch
end
end
