function checkResultsScroll
% Measure the help area after scrolling a real uihtml result table far right.
root=fileparts(fileparts(mfilename('fullpath')));
html=fileread(fullfile(root,'src','results.html'));
probe="const originalSetup=setup;setup=function(component){originalSetup(component);setTimeout(()=>{"+...
    "const v=document.getElementById('view');v.scrollLeft=v.scrollWidth;"+...
    "const th=document.querySelector('th:last-child');th.dispatchEvent(new MouseEvent('mouseenter'));"+...
    "const h=document.getElementById('hint'),r=h.getBoundingClientRect();"+...
    "component.Data={scrollCheck:true,scrolled:v.scrollLeft>0,visible:r.left>=0&&r.right<=window.innerWidth+1,explained:h.textContent.includes('Metric_40')};"+...
    "},700);};";
html=strrep(html,'</script>',[char(probe) '</script>']);
path=fullfile(root,'output','scroll-check.html');fid=fopen(path,'w');fprintf(fid,'%s',html);fclose(fid);
fig=uifigure('Position',[100 100 650 350]);cleanup=onCleanup(@()delete(fig));
grid=uigridlayout(fig,[1 1]);
columns=cellstr("Metric_"+string(1:40));tips=repmat({'A long explanation of this metric, including its units and interpretation.'},1,40);
ui=uihtml(grid,'HTMLSource',path,'Data',struct('columns',{columns},'tips',{tips},'rows',{{num2cell(1:40)}}));
started=tic;
while toc(started)<20
    drawnow;pause(0.1);
    if isstruct(ui.Data)&&isfield(ui.Data,'scrollCheck'),break;end
end
assert(isfield(ui.Data,'scrollCheck'),'The HTML layout check timed out.');
assert(ui.Data.scrolled&&ui.Data.visible&&ui.Data.explained,'Help must stay visible when selecting the last column after horizontal scrolling.');
disp('HTML rightmost-column help stays visible after horizontal scrolling.');
end
