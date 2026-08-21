function root = fmmDataRoot()
%FMMDATAROOT  Root of the lab data share that holds <Monkey>/FMM/Data/...
%   root = fmmDataRoot() returns the mount point of the 'Monkeys' share with a
%   trailing separator. Override it with the environment variable
%   FMM_DATA_ROOT (e.g. setenv('FMM_DATA_ROOT','D:\localcopy\Monkeys\')).
%   Defaults match the lab mounts: Y:\Monkeys\ on Windows,
%   /Volumes/server2/Monkeys/ on macOS.
%
%   See also expParams, getSessionPathAndID.

root = getenv('FMM_DATA_ROOT');
if isempty(root)
    if ispc
        root = 'Y:\Monkeys\';
    else
        root = '/Volumes/server2/Monkeys/';
    end
end
if ~any(root(end) == '\/')
    root(end+1) = filesep;
end
end
