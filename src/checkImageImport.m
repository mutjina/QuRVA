function checkImageImport
% Regression check for RGB imports, channel changes and setting tooltips.
app=QuRVAApp; cleanup=onCleanup(@()delete(app.Figure));
folder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'output','import-check');
if ~isfolder(folder),mkdir(folder);end
rgb=zeros(80,100,3,'uint8');rgb(:,:,1)=20;rgb(:,:,2)=150;rgb(:,:,3)=70;
path=fullfile(folder,'rgb.tif');imwrite(rgb,path);app.loadImage(path);
assert(isequal(app.Image,rgb(:,:,1)));
app.Results=struct('previous',true);app.Channel.Value='Green';app.selectChannel();
assert(isequal(app.Image,rgb(:,:,2))&&isempty(fieldnames(app.Results)));
app.Channel.Value='Blue';app.selectChannel();assert(isequal(app.Image,rgb(:,:,3)));
imwrite(uint16(ones(80,100)*2048),fullfile(folder,'gray.tif'));
app.loadImage(fullfile(folder,'gray.tif'));
assert(isa(app.Image,'uint16')&&strcmp(app.Channel.Enable,'off'));
labels=findall(app.Figure,'Type','uilabel');
assert(~any(arrayfun(@(h)strcmp(h.Text,'?'),labels)));
assert(any(arrayfun(@(h)strcmp(h.Text,'Pixel size (um/pixel)')&&~isempty(h.Tooltip),labels)));
panels=findall(app.Figure,'Type','uipanel');assert(any(arrayfun(@(h)strcmp(h.TitlePosition,'centertop'),panels)));
app.Fields.pixelSize.Value=1.7;app.Fields.radius.Value=12;
path=fullfile(folder,'settings.json');app.saveSettings(path);
app.Fields.radius.Value=22;app.loadSettings(path);assert(app.Fields.radius.Value==12);
app.loadImage(fullfile(folder,'rgb.tif'));assert(app.Fields.pixelSize.Value==1.7);
assert(~any(arrayfun(@(h)strcmp(h.Text,'Reset defaults'),findall(app.Figure,'Type','uibutton'))));
assert(strcmp(app.Navigation.Global.Enable,'off'));
assert(contains(qurvaEnglishError(MException('QuRVA:test','Localized %s',char(54620))),'Error ID: QuRVA:test'));
qurvaWritePreview(zeros(4200,10,3,'single'),fullfile(folder,'bounded.png'));
png=imfinfo(fullfile(folder,'bounded.png'));assert(png.Height==4096&&png.BitDepth==24);
drawnow;exportapp(app.Figure,fullfile(folder,'ui.png'));
disp('RGB/grayscale import, channel invalidation, tooltips and centered title passed.');
end
