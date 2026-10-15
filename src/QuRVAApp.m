classdef QuRVAApp < handle
    properties
        Figure
        Axes
        Status
        Fields = struct()
        Results = struct()
        Tables = struct()
        Views = struct()
        Navigation = struct()
        Unread = struct()
        PreferredChannel = 'Red'
        Image
        SourceImage
        Channel
        ImagePath = ''
        Boundary
        Center
        WorkFolder = ''
        PreviewImage
    end
    methods
        function app = QuRVAApp
            app.Figure = uifigure('Name','QuRVA','Position',[100 100 1250 820],'WindowState','maximized');
            root = uigridlayout(app.Figure,[3 2]);
            root.ColumnWidth = {'1x',350}; root.RowHeight = {70,'1x',30};
            bar = uigridlayout(root,[1 6]); bar.Layout.Column = [1 2];
            uibutton(bar,'Text','① Open TIFF','ButtonPushedFcn',@(~,~)app.openImage());
            uibutton(bar,'Text','② Draw boundary','ButtonPushedFcn',@(~,~)app.drawBoundary());
            uibutton(bar,'Text','③ Set optic nerve','ButtonPushedFcn',@(~,~)app.setCenter());
            uibutton(bar,'Text','⑤ Preview','ButtonPushedFcn',@(~,~)app.preview());
            uibutton(bar,'Text','⑥ Analyze','ButtonPushedFcn',@(~,~)app.analyze());
            uibutton(bar,'Text','⑦ Save results','ButtonPushedFcn',@(~,~)app.exportResults());
            actionButtons=findall(bar,'Type','uibutton');
            for k=1:numel(actionButtons),actionButtons(k).FontSize=14;actionButtons(k).FontWeight='bold';end
            content=uigridlayout(root,[2 1]);content.Layout.Row=2;content.Layout.Column=1;
            content.RowHeight={32,'1x'};content.Padding=[0 0 0 0];
            nav=uigridlayout(content,[1 5]);nav.Layout.Row=1;nav.Padding=[0 0 0 0];
            names = {'Image','Global','Radial','Coherence','Windows'};
            for k=1:numel(names)
                name=names{k};
                app.Navigation.(name)=uibutton(nav,'Text',name,'HorizontalAlignment','center',...
                    'ButtonPushedFcn',@(~,~)app.selectView(name));
                app.Unread.(name)=false;
                if ~strcmp(name,'Image'),app.Navigation.(name).Enable='off';end
                app.Views.(name)=uipanel(content,'BorderType','none','Visible','off');
                app.Views.(name).Layout.Row=2;app.Views.(name).Layout.Column=1;
                grid=uigridlayout(app.Views.(name),[1 1]);
                if strcmp(name,'Image')
                    app.Axes = uiaxes(grid); app.Axes.XTick=[]; app.Axes.YTick=[];
                else
                    app.Tables.(name)=uihtml(grid,'HTMLSource',fullfile(fileparts(mfilename('fullpath')),'results.html'),...
                        'Data',app.themedData(struct('columns',{{}},'tips',{{}},'rows',{{}})));
                end
            end
            app.selectView('Image');
            panel = uipanel(root,'Title','④ Analysis settings','TitlePosition','centertop'); panel.Layout.Row=2; panel.Layout.Column=2;
            settings = uigridlayout(panel,[15 2]);
            settings.ColumnWidth={'1x',95}; settings.RowHeight=repmat({34},1,15);settings.RowSpacing=8;
            specs = {
                'pixelSize','Pixel size (um/pixel)',2.8986,'Original TIFF pixel size in micrometers. Initial value: 2.8986 um/pixel. Verify against acquisition metadata or a scale bar for each acquisition scale.';
                'radius','Large-vessel radius (um)',50,'Skeleton points with a radius above this cutoff are excluded. Zero includes all vessels.';
                'branch','Short-branch threshold (px)',8,'Minimum component size and branch-length filter on the analysis grid. Larger values remove more small structures.';
                'gap','Gap-closing radius (px)',3,'Disk radius used to close skeleton gaps before loop detection. Larger values can alter or merge loops.';
                'loop','Minimum loop area (um^2)',100,'Enclosed skeleton regions smaller than this area are excluded.';
                'bins','Radial bins',6,'Number of equal-width distance bands around the selected optic nerve center.';
                'length','Orientation branch length (um)',20,'Minimum branch size for orientation analysis. The upstream algorithm uses a pixel-count approximation with a five-pixel floor.';
                'tile','Orientation window (um)',150,'Window side length for local alignment. Adjacent windows overlap by 50 percent.';
                'branches','Branches per window',6,'Minimum number of eligible branches needed for a coherence score.';
                'coherence','Alignment threshold',0.6,'Windows with coherence strictly above this value count as aligned. Coherence ranges from zero to one.'};
            for k=1:size(specs,1)
                uilabel(settings,'Text',specs{k,2},'Tooltip',specs{k,4},'WordWrap','on');
                limits=[0 Inf]; if k==10, limits=[0 1]; end
                app.Fields.(specs{k,1})=uieditfield(settings,'numeric','Value',specs{k,3},...
                    'Limits',limits,'ValueChangedFcn',@(~,~)app.invalidate());
            end
            label=uilabel(settings,'Text','Analysis channel','Tooltip','Choose the RGB channel containing the vascular stain. Analysis uses this channel only; display color does not identify the stain.');
            label.Layout.Row=11; label.Layout.Column=1;
            app.Channel=uidropdown(settings,'Items',{'Grayscale'},'Enable','off','ValueChangedFcn',@(~,~)app.selectChannel());
            app.Channel.Layout.Row=11; app.Channel.Layout.Column=2;
            uibutton(settings,'Text','Save settings','ButtonPushedFcn',@(~,~)app.saveSettings());
            uibutton(settings,'Text','Load settings','ButtonPushedFcn',@(~,~)app.loadSettings());
            tip=uilabel(settings,'Text','Start values: guide examples, not validated for every dataset.','WordWrap','on');
            tip.Layout.Row=13; tip.Layout.Column=[1 2];
            tip=uilabel(settings,'Text','Draw boundary: double-click to finish. Click to place the optic nerve.','WordWrap','on');
            tip.Layout.Row=14; tip.Layout.Column=[1 2];
            tip=uilabel(settings,'Text','Hover over a setting name for help. RGB: choose the channel showing vessels.','WordWrap','on');
            tip.Layout.Row=15; tip.Layout.Column=[1 2];
            app.Status=uilabel(root,'Text','Open a single-plane TIFF to begin.');
            app.Status.Layout.Row=3; app.Status.Layout.Column=[1 2];
            % Allow native controls to resolve the desktop theme before
            % passing their actual colors to the embedded HTML surfaces.
            drawnow;
            names=fieldnames(app.Tables);
            for k=1:numel(names),app.Tables.(names{k}).Data=app.themedData(app.Tables.(names{k}).Data);end
        end
        function selectView(app,name)
            app.Unread.(name)=false;app.Navigation.(name).Text=name;
            names=fieldnames(app.Views);
            for k=1:numel(names)
                active=strcmp(names{k},name);
                app.Views.(names{k}).Visible=matlab.lang.OnOffSwitchState(active);
                app.Navigation.(names{k}).FontWeight='normal';
                if active,app.Navigation.(names{k}).FontWeight='bold';end
            end
        end
        function payload=themedData(app,payload)
            background=app.Views.Image.BackgroundColor;
            if dot(background,[0.2126 0.7152 0.0722])<0.5
                foreground=[0.9 0.9 0.9];line=[0.32 0.32 0.32];header=min(background+0.06,1);
            else
                foreground=[0.12 0.15 0.18];line=[0.75 0.77 0.79];header=max(background-0.04,0);
            end
            payload.theme=struct('background',background,'foreground',foreground,'line',line,'header',header);
        end
        function settings=collectSettings(app)
            settings=struct();names=fieldnames(app.Fields);
            for k=1:numel(names),settings.(names{k})=app.Fields.(names{k}).Value;end
            settings.channel=app.Channel.Value;
        end
        function saveSettings(app,path)
            if nargin<2
                [f,p]=uiputfile('*.json','Save analysis settings','qurva_settings.json');
                if isequal(f,0),return;end
                path=fullfile(p,f);
            end
            try
                fid=fopen(path,'w');assert(fid>=0,'Cannot open the settings file for writing.');
                c=onCleanup(@()fclose(fid));
                fprintf(fid,'%s',jsonencode(struct('format','QuRVA-settings-v1','settings',app.collectSettings()),PrettyPrint=true));
                app.Status.Text='Settings saved. Verify pixel size when using a different acquisition scale.';
            catch err,app.fail(err);end
        end
        function loadSettings(app,path)
            if nargin<2
                [f,p]=uigetfile('*.json','Load analysis settings');if isequal(f,0),return;end
                path=fullfile(p,f);
            end
            try
                payload=jsondecode(fileread(path));
                assert(isfield(payload,'settings')&&isstruct(payload.settings),'This file does not contain QuRVA settings.');
                s=payload.settings;names=fieldnames(app.Fields);
                % Validate every value before changing the current configuration.
                for k=1:numel(names)
                    n=names{k};assert(isfield(s,n),'Missing setting: %s',n);
                    v=s.(n);assert(isnumeric(v)&&isscalar(v)&&isfinite(v)&&v>=0,'Invalid setting: %s',n);
                    assert(v<=app.Fields.(n).Limits(2),'Setting out of range: %s',n);
                end
                for n={'branch','gap','bins','branches'}
                    v=s.(n{1});assert(v==fix(v),'Counts must be integers.');
                end
                assert(s.branch>=1&&s.bins>=1&&s.branches>=1,'Branch and bin counts must be positive.');
                if isfield(s,'channel')
                    assert(any(strcmp(s.channel,{'Grayscale','Red','Green','Blue'})),'Invalid analysis channel.');
                end
                for k=1:numel(names),app.Fields.(names{k}).Value=s.(names{k});end
                if isfield(s,'channel')&&~strcmp(s.channel,'Grayscale'),app.PreferredChannel=s.channel;end
                if isfield(s,'channel')&&any(strcmp(s.channel,app.Channel.Items))
                    app.Channel.Value=s.channel;app.selectChannel();
                end
                app.invalidate();
                app.Status.Text='Settings loaded. Verify pixel size and channel for this image before analysis.';
            catch err,app.fail(err);end
        end
        function invalidate(app)
            app.Results=struct(); app.PreviewImage=[];
            names=fieldnames(app.Tables);
            for k=1:numel(names)
                app.Tables.(names{k}).Data=app.themedData(struct('columns',{{}},'tips',{{}},'rows',{{}}));
                app.Navigation.(names{k}).Enable='off';app.Navigation.(names{k}).Text=names{k};app.Unread.(names{k})=false;
            end
            app.selectView('Image');
            app.Status.Text='Settings or region changed. Run Preview or Analyze again.';
            if ~isempty(app.Image), app.showOriginal(); end
        end
        function showOriginal(app)
            % Preserve editable ROI objects when refreshing the image.
            h=findobj(app.Axes,'Type','image');
            if isempty(h), imshow(app.Image,[],'Parent',app.Axes);
            else, h(1).CData=app.Image; end
            h=findobj(app.Axes,'Type','image');
            h(1).XData=[1 size(app.Image,2)];h(1).YData=[1 size(app.Image,1)];
        end
        function openImage(app)
            [f,p]=uigetfile({'*.tif;*.tiff','TIFF image'},'Open TIFF',qurvaRecentFolder('Input')); if isequal(f,0), return; end
            try
                app.loadImage(fullfile(p,f));
            catch err, app.fail(err); end
        end
        function loadImage(app,path)
                info=imfinfo(path);
                assert(numel(info)==1,'Please provide a single-plane TIFF. Multi-page stacks are not supported yet.');
                [img,map]=imread(path);
                if ~isempty(map), img=im2uint8(ind2rgb(img,map)); end
                assert(ismatrix(img)||(ndims(img)==3&&size(img,3)==3),'Please provide a grayscale or RGB TIFF.');
                assert(size(img,1)>=64&&size(img,2)>=64,'Image must be at least 64 by 64 pixels.');
                assert(isinteger(img)||islogical(img),'Please export an integer TIFF.');
                app.SourceImage=img; app.ImagePath=path;
                cla(app.Axes); app.Boundary=[]; app.Center=[];
                if ismatrix(img)
                    app.Channel.Items={'Grayscale'}; app.Channel.Value='Grayscale'; app.Channel.Enable='off';
                else
                    app.Channel.Items={'Red','Green','Blue'}; app.Channel.Value=app.PreferredChannel; app.Channel.Enable='on';
                end
                app.selectChannel();
                qurvaRecentFolder('Input',fileparts(path));
        end
        function selectChannel(app)
            if isempty(app.SourceImage),return;end
            index=find(strcmp(app.Channel.Value,{'Red','Green','Blue'}));
            if isempty(index), app.Image=app.SourceImage;
            else, app.Image=app.SourceImage(:,:,index); app.PreferredChannel=app.Channel.Value;end
            app.invalidate();
            lo=double(min(app.Image(:))); hi=double(max(app.Image(:)));
            app.Axes.CLim=[lo max(hi,lo+1)];
            app.Status.Text=['Channel: ' app.Channel.Value '. Verify pixel size, retinal boundary and optic nerve center.'];
        end
        function drawBoundary(app)
            app.selectView('Image');
            if isempty(app.Image), return; end
            if ~isempty(app.Boundary)&&isvalid(app.Boundary), delete(app.Boundary); end
            app.Boundary=drawpolygon(app.Axes,'Color','cyan');
            if isempty(app.Boundary)||~isvalid(app.Boundary), return; end
            addlistener(app.Boundary,'ROIMoved',@(~,~)app.invalidate()); app.invalidate();
            addlistener(app.Boundary,'DeletingROI',@(~,~)app.invalidate());
        end
        function setCenter(app)
            app.selectView('Image');
            if isempty(app.Image), return; end
            if ~isempty(app.Center)&&isvalid(app.Center), delete(app.Center); end
            app.Center=drawpoint(app.Axes,'Color','yellow');
            if isempty(app.Center)||~isvalid(app.Center), return; end
            addlistener(app.Center,'ROIMoved',@(~,~)app.invalidate()); app.invalidate();
            addlistener(app.Center,'DeletingROI',@(~,~)app.invalidate());
        end
        function [mask,center,p]=inputs(app)
            assert(~isempty(app.Image),'Open a TIFF first.');
            assert(~isempty(app.Boundary)&&isvalid(app.Boundary),'Draw the retinal boundary first.');
            assert(~isempty(app.Center)&&isvalid(app.Center),'Set the optic nerve center first.');
            % Rasterize in ORIGINAL image coordinates. createMask without an
            % explicit size follows the displayed image's CData dimensions,
            % which change when a downsampled preview is shown.
            vertices=app.Boundary.Position;
            mask=poly2mask(vertices(:,1),vertices(:,2),size(app.Image,1),size(app.Image,2));
            center=app.Center.Position;
            assert(nnz(mask)>100,'Retinal region is too small.');
            assert(all(isfinite(center))&&center(1)>=1&&center(1)<=size(mask,2)&&center(2)>=1&&center(2)<=size(mask,1)...
                &&inpolygon(center(1),center(2),vertices(:,1),vertices(:,2)),...
                'The optic nerve center must be inside the retinal boundary.');
            p=struct(); names=fieldnames(app.Fields);
            for k=1:numel(names), p.(names{k})=app.Fields.(names{k}).Value; end
            p.channel=app.Channel.Value;
            assert(p.pixelSize>0,'Enter the original TIFF pixel size in um/pixel.');
            for name={'branch','gap','bins','branches'}
                v=p.(name{1}); assert(v==fix(v),'Pixel counts, bin counts and branch counts must be integers.');
            end
            assert(p.bins>=1&&p.branches>=1&&p.branch>=1,'Bin and branch counts must be positive.');
        end
        function preview(app)
            app.run(false);
        end
        function analyze(app)
            app.run(true);
        end
        function run(app,fullAnalysis)
            try
                [mask,center,p]=app.inputs(); app.Results=struct();
                names=fieldnames(app.Tables); for k=1:numel(names),app.Tables.(names{k}).Data=app.themedData(struct('columns',{{}},'tips',{{}},'rows',{{}}));end
                for k=1:numel(names)
                    app.Navigation.(names{k}).Enable='off';app.Navigation.(names{k}).Text=names{k};app.Unread.(names{k})=false;
                end
                app.selectView('Image');
                app.Status.Text='Processing...'; app.Figure.Pointer='watch'; drawnow;
                cleanup=onCleanup(@()set(app.Figure,'Pointer','arrow'));
                [result,overlay,folder]=qurvaAnalyze(app.Image,mask,center,p,app.ImagePath,fullAnalysis);
                app.WorkFolder=folder; app.PreviewImage=overlay;
                h=findobj(app.Axes,'Type','image'); h(1).CData=overlay;
                h(1).XData=[1 size(app.Image,2)];h(1).YData=[1 size(app.Image,1)];
                if fullAnalysis
                    payloads=struct();
                    for k=1:numel(names),payloads.(names{k})=app.themedData(qurvaTableData(result.(names{k}),names{k}));end
                    app.Results=result;
                    for k=1:numel(names)
                        app.Tables.(names{k}).Data=payloads.(names{k});
                        app.Navigation.(names{k}).Enable='on';app.Navigation.(names{k}).Text=[names{k} ' *'];app.Unread.(names{k})=true;
                    end
                    app.Status.Text='Analysis complete. Review results, then Save results.';
                else
                    app.Status.Text='Preview: green = retained skeleton; magenta = excluded large vessels. Run Analyze for metrics.';
                end
            catch err, app.fail(err); end
        end
        function out=exportResults(app,destination)
            out='';
            if isempty(fieldnames(app.Results)), uialert(app.Figure,'Run Analyze with the current settings first.','No current results'); return; end
            if nargin<2,destination=uigetdir(qurvaRecentFolder('Output'),'Choose results parent folder');end
            if isequal(destination,0),return;end
            try
                % Write the bounded preview first, so an image failure cannot leave a partial export.
                qurvaWritePreview(app.PreviewImage,fullfile(app.WorkFolder,'preview.png'));
                files={'qurva_capillary_stats.csv','radial_topology.csv',...
                    'local_coherence_bins.csv','local_coherence_windows.csv','preview.png'};
                for k=1:numel(files)
                    assert(isfile(fullfile(app.WorkFolder,files{k})),'Missing analysis output: %s. Run Analyze again.',files{k});
                end
                metadata=jsondecode(fileread(fullfile(app.WorkFolder,'settings.json')));
                if ~isempty(app.Boundary)&&isvalid(app.Boundary)&&~isempty(app.Center)&&isvalid(app.Center)
                    metadata.region=struct('retinalBoundaryXY',app.Boundary.Position,...
                        'opticNerveCenterXY',app.Center.Position,'originalImageSize',size(app.Image));
                end
                [~,base]=fileparts(app.ImagePath);
                out=fullfile(destination,[base '_' char(datetime('now','Format','yyyyMMdd_HHmmss_SSS'))]);
                mkdir(out);
                for k=1:numel(files),copyfile(fullfile(app.WorkFolder,files{k}),fullfile(out,files{k}));end
                fid=fopen(fullfile(out,'settings.json'),'w');assert(fid>=0,'Cannot write analysis settings.');
                closeMetadata=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(metadata,PrettyPrint=true));
                app.Status.Text=['Saved: ' out];
                qurvaRecentFolder('Output',destination);
            catch err, app.fail(err); end
        end
        function fail(app,err)
            message=qurvaEnglishError(err);
            app.Status.Text=message; uialert(app.Figure,message,'QuRVA');
        end
    end
end
