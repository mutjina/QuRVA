function checkCoherenceEmpty
% Compare no eligible windows, aligned vessels, and no retained branches.
root=fileparts(fileparts(mfilename('fullpath')));addpath(fullfile(root,'src','vendor','qurva'));
folder=tempname;mkdir(folder);
for name={'Masks','ONCenter','VasculatureNumbers'},mkdir(fullfile(folder,name{1}));end
file='test_retina.tif.mat';thisMask=true(128);thisONCenter=[64 64];
save(fullfile(folder,'Masks',file),'thisMask');save(fullfile(folder,'ONCenter',file),'thisONCenter');
vesselSkelMask=false(128);vesselSkelMask([30 50 70 90],20:100)=true;smoothVessels=vesselSkelMask;
save(fullfile(folder,'VasculatureNumbers',file),'smoothVessels','vesselSkelMask');
p=struct('basePxUM',1,'radiusThreshUM',Inf,'minBranchPix',1,'minLenUM',5,...
    'tileUM',100,'minBranches',999,'nBins',6,'showQC',false);
[T,W]=batchLocalCoherence(folder,p);
assert(height(T)==6&&width(T)==10&&height(W)==0&&width(W)==5);
assert(all(T.nTiles==0)&&all(isnan(T.meanCoh))&&all(isnan(T.p90Coh))&&all(isnan(T.fracAligned))&&all(isnan(T.medianBranchesPerTile)));
assert(~isempty(qurvaTableData(T,'Coherence').message));
assert(~isempty(qurvaTableData(W,'Windows').message));
p.minBranches=1;[T,W]=batchLocalCoherence(folder,p);
assert(height(W)>0&&all(abs(W.coh-1)<1e-10));
valid=T.nTiles>0;assert(any(valid)&&all(abs(T.meanCoh(valid)-1)<1e-10));
vesselSkelMask=false(128);smoothVessels=vesselSkelMask;
save(fullfile(folder,'VasculatureNumbers',file),'smoothVessels','vesselSkelMask');
[T,W]=batchLocalCoherence(folder,p);assert(all(T.nTiles==0)&&height(W)==0);
app=QuRVAApp;cleanup=onCleanup(@()delete(app.Figure));
payload=app.themedData(qurvaTableData(T,'Coherence'));
assert(all(payload.theme.background>=0&payload.theme.background<=1));
app.Tables.Coherence.Data=payload;app.Navigation.Coherence.Enable='on';app.selectView('Coherence');
drawnow;pause(1);exportapp(app.Figure,fullfile(root,'output','coherence-theme.png'));
disp('Empty windows, aligned windows, empty skeleton and result theme checks passed.');
end
