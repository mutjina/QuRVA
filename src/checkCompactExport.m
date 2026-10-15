function checkCompactExport
% Export only visible result tables, preview and reproducibility metadata.
root=fileparts(fileparts(mfilename('fullpath')));folder=fullfile(root,'output','export-check');
if ~isfolder(folder),mkdir(folder);end
work=tempname;mkdir(work);mkdir(fullfile(work,'Masks'));
files={'qurva_capillary_stats.csv','radial_topology.csv','local_coherence_bins.csv','local_coherence_windows.csv'};
for k=1:numel(files),writetable(table(1,'VariableNames',{'testValue'}),fullfile(work,files{k}));end
fid=fopen(fullfile(work,'settings.json'),'w');fprintf(fid,'%s',jsonencode(struct('settings',struct('pixelSize',2.8986))));fclose(fid);
unused=ones(5);save(fullfile(work,'session.mat'),'unused');
app=QuRVAApp;cleanup=onCleanup(@()delete(app.Figure));
app.Image=zeros(80,100,'uint8');app.showOriginal();app.ImagePath='test.tif';
app.Boundary=drawpolygon(app.Axes,'Position',[10 10;90 10;90 70;10 70]);
app.Center=drawpoint(app.Axes,'Position',[50 40]);
app.Results=struct('Global',table(1));app.PreviewImage=zeros(80,100,3,'uint8');app.WorkFolder=work;
out=app.exportResults(folder);listing=dir(out);
assert(sum(~[listing.isdir])==6&&sum([listing.isdir])==2);
assert(~isfile(fullfile(out,'session.mat'))&&~isfolder(fullfile(out,'Masks')));
meta=jsondecode(fileread(fullfile(out,'settings.json')));
assert(isequal(meta.region.opticNerveCenterXY(:),[50;40]));
assert(isequal(meta.region.retinalBoundaryXY,app.Boundary.Position));
for k=1:numel(files),assert(strcmp(fileread(fullfile(work,files{k})),fileread(fullfile(out,files{k}))));end
disp('Compact export passed: four unchanged CSVs, preview PNG and settings/ROI JSON.');
end
