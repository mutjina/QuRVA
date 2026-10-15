function checkReviewFixes
% Regressions: original-coordinate ROIs after preview and missing table text.
app=QuRVAApp;cleanup=onCleanup(@()delete(app.Figure));
app.Image=zeros(1200,1800,'uint8');app.showOriginal();
app.Boundary=drawpolygon(app.Axes,'Position',[1100 300;1700 300;1700 1000;1100 1000]);
app.Center=drawpoint(app.Axes,'Position',[1500 600]);
[mask,center]=app.inputs();assert(isequal(size(mask),[1200 1800])&&mask(600,1500));
h=findobj(app.Axes,'Type','image');h.CData=zeros(300,450,3,'uint8');
h.XData=[1 1800];h.YData=[1 1200];
% The previously implicit createMask now follows the small displayed raster.
oldMask=createMask(app.Boundary);assert(~isequal(size(oldMask),size(app.Image)));
[mask,after]=app.inputs();assert(isequal(size(mask),[1200 1800])&&isequal(center,after)&&mask(600,1500));
app.Center.Position=[500 600];rejected=false;
try,app.inputs();catch err,rejected=contains(err.message,'inside the retinal boundary');end
assert(rejected,'A genuinely outside point must still be rejected.');
app.Center.Position=[1500 600];
T=table([string(missing);"sample.tif"],[string(missing);"test"],[NaN;0.75],["";"ok"],...
    'VariableNames',{'fileName','strain','meanCoh','msg'});
payload=qurvaTableData(T,'Coherence');
assert(strcmp(payload.rows{1}{1},'')&&strcmp(payload.rows{1}{2},'')&&strcmp(payload.rows{1}{3},'NaN'));
assert(strcmp(payload.rows{2}{3},'0.75')&&ismissing(T.strain(1))&&isnan(T.meanCoh(1)));
app.Tables.Coherence.Data=payload;app.Navigation.Coherence.Enable='on';app.selectView('Coherence');
disp('Original-coordinate ROI checks and missing-string/NaN rendering passed.');
end
