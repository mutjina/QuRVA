function folder=qurvaRecentFolder(kind,newFolder)
% Persist separate input/output folder preferences outside the repository.
assert(any(strcmp(kind,{'Input','Output'})),'Unknown folder preference.');
group='QuRVA';key=['Recent' kind 'Folder'];
if nargin>1
    if isfolder(newFolder)
        try,setpref(group,key,char(newFolder));catch,end
    end
    folder=newFolder;return
end
folder=pwd;
try
    saved=getpref(group,key,'');
    if (ischar(saved)||isstring(saved))&&isfolder(saved),folder=char(saved);end
catch
end
end
