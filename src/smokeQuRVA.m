function smokeQuRVA
% Exercise UI construction and complete synthetic-image export pipeline.
app=QuRVAApp; closeUI=onCleanup(@()delete(app.Figure));
assert(isvalid(app.Figure));
[x,y]=meshgrid(1:512);
mask=(x-256).^2+(y-256).^2<235^2;
image=uint8(15+210*double((mod(x,24)<3|mod(y,24)<3)&mask));
p=struct('pixelSize',2,'radius',0,'branch',8,'gap',3,'loop',100,...
    'bins',6,'length',20,'tile',150,'branches',6,'coherence',0.6);
[result,overlay,folder]=qurvaAnalyze(image,mask,[256 256],p,'synthetic.tif',true);
assert(width(result.Global)==51);
assert(width(result.Radial)==24&&height(result.Radial)==6);
assert(width(result.Coherence)==10&&height(result.Coherence)==6);
assert(width(result.Windows)==5&&height(result.Windows)>0);
assert(result.Global.capSkelPixels>0,'All-vessel mode must retain skeleton.');
assert(isa(overlay,'uint8')&&max(size(overlay,1),size(overlay,2))<=4096);
assert(size(overlay,3)==3);
for name={'Global','Radial','Coherence','Windows'}
    payload=qurvaTableData(result.(name{1}),name{1});
    assert(numel(payload.tips)==width(result.(name{1}))&&all(~cellfun(@isempty,payload.tips)));
    app.Tables.(name{1}).Data=payload;
    app.Navigation.(name{1}).Enable='on';app.Navigation.(name{1}).Text=[name{1} ' *'];app.Unread.(name{1})=true;
end
app.selectView('Global');assert(~app.Unread.Global&&app.Unread.Radial);
app.Results=result;app.PreviewImage=overlay;app.WorkFolder=folder;app.ImagePath='synthetic.tif';
destination=fullfile(fileparts(fileparts(mfilename('fullpath'))),'output','smoke-export');
if ~isfolder(destination),mkdir(destination);end
out=app.exportResults(destination);assert(isfile(fullfile(out,'preview.png')));
listing=dir(out);assert(sum(~[listing.isdir])==6&&~isfolder(fullfile(out,'Masks')));
png=imfinfo(fullfile(out,'preview.png'));assert(png.BitDepth==24);
app.invalidate();assert(strcmp(app.Navigation.Global.Enable,'off')&&~app.Unread.Global);
assert(isfile(fullfile(folder,'settings.json')));
disp('QuRVA smoke checks passed.');
disp(folder);
end
