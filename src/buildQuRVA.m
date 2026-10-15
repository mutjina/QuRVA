function buildQuRVA
% Build standalone application; matching MATLAB Runtime required on target.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'src'));
compiler.build.standaloneWindowsApplication(fullfile(root,'src','runQuRVA.m'),...
    'AdditionalFiles',{fullfile(root,'src','vendor','qurva'),fullfile(root,'src','results.html')},...
    'OutputDir',fullfile(root,'output','build'),'ExecutableName','QuRVA');
end
