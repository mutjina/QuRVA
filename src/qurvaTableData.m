function data=qurvaTableData(T,kind)
% Explicit scientific descriptions, with generic statistic/unit expansion.
columns=T.Properties.VariableNames;tips=cell(size(columns));
definitions={
'fileName','Source image filename.';
'ok','True if this image was processed successfully.';
'msg','Diagnostic text for a failed image; empty on success.';
'pixSzeUM_used','Effective analysis pixel size in um/pixel, including image resampling.';
'radiusThreshUM_used','Applied large-vessel radius cutoff in um. Inf includes all vessels.';
'scaleFactor','Original retinal-mask height divided by analysis-image height.';
'maskPixels','Number of pixels in the full vessel mask on the analysis grid.';
'skelPixels','Number of pixels in the full vessel skeleton on the analysis grid.';
'allSkelLen_mm','Full skeleton adjacency-based path length in mm, before large-vessel exclusion.';
'maskFrac','Full vessel-mask area divided by retinal-mask area; fraction, not percent.';
'qurvaBranchPts','Branchpoint pixel count returned by the original QuRVA algorithm.';
'qurvaEndPts','Endpoint pixel count returned by the original QuRVA algorithm.';
'qurvaAvascArea','Original QuRVA avascular prediction area in analysis-grid pixels, not mm^2.';
'nJunctions','Number of connected junction-pixel clusters on the retained skeleton.';
'nEndpoints','Number of retained skeleton pixels with exactly one neighbor.';
'nBranches','Number of retained branch segments after the applicable branch filters.';
'nComponents','Number of disconnected components in the retained skeleton.';
'leafletArea_mm2','Area of the retinal region in mm^2.';
'capSkelLen_mm','Sum of retained branch path lengths in mm, excluding junction pixels.';
'junctionsPerArea_mm2','Junction count divided by retinal area; junctions/mm^2.';
'junctionsPerLength_mm','Junction count divided by retained branch length; junctions/mm.';
'endpointJunctionRatio','Endpoint count divided by junction count, with denominator at least one.';
'avascularFrac','Enclosed spaces in the FULL vessel mask divided by retinal area. Not the original OIR avascular-zone fraction.';
'largeSkelPixels','Skeleton pixels above the large-vessel radius cutoff.';
'capSkelPixels','Retained skeleton pixel count after radius and component-size filtering.';
'nLoops','Number of enclosed skeleton regions retained after gap closing and minimum-area filtering.';
'nRejectedLoops','Number of enclosed skeleton regions rejected by minimum-area filtering.';
'fracLoopsKept','Retained loop count divided by all detected enclosed regions; fraction, not percent.';
'loopDensity_mm2','Retained loop count divided by retinal or radial-bin tissue area; loops/mm^2.';
'totalLoopArea_mm2','Sum of retained loop areas in mm^2, measured to skeleton centerlines.';
'loopAreaFrac','Sum of retained loop areas divided by tissue area; fraction, not percent. Radial loops are assigned by centroid.';
'bin','Radial bin number; 1 is closest to the optic nerve center.';
'pxUM','Effective analysis pixel size in um/pixel.';
'tissueArea_mm2','Area of retinal tissue within this radial bin in mm^2.';
'coverage','Fraction of the complete annular pixel region covered by the retinal mask; not vessel density.';
'icdMean_um','Mean distance from non-vessel tissue pixels to the nearest FULL-mask vessel, in um; not full vessel-to-vessel spacing.';
'icdP95_um','95th percentile of distance from non-vessel tissue pixels to the nearest FULL-mask vessel, in um.';
'capLen_mm','Sum of entire branch lengths assigned to this radial bin by branch centroid, in mm; branches are not clipped at bin edges.';
'inner_um','Inner radial-bin boundary distance from the optic nerve center, in um.';
'outer_um','Outer radial-bin boundary distance from the optic nerve center, in um.';
'nTiles','Number of valid overlapping windows whose centers fall in this radial bin.';
'meanCoh','Mean local orientation coherence across valid windows in this bin; 0 to 1.';
'p90Coh','90th percentile of local orientation coherence in this bin; 0 to 1.';
'fracAligned','Fraction of valid windows with coherence strictly above the alignment threshold.';
'strain','Text before the first underscore in the source filename, as assigned by the upstream script.';
'medianBranchesPerTile','Median number of eligible branches per valid analysis window in this bin.';
'coh','Local orientation coherence for this window; 0 means no common direction and 1 means parallel. Weighted by branch pixel count.'};
for k=1:numel(columns)
    name=columns{k};idx=find(strcmp(name,definitions(:,1)),1);
    if ~isempty(idx)
        tips{k}=definitions{idx,2};
    else
        token=regexp(name,'^(mean|median|sd|iqr|cv|p95|max)(BranchLen|Tortuosity|IntercapDist|CapRadius|LoopArea)(?:_um2|_um)?$','tokens','once');
        assert(~isempty(token),'No metric explanation defined for %s.',name);
        stats=struct('mean','Mean','median','Median','sd','Standard deviation','iqr','Interquartile range',...
            'cv','Coefficient of variation (standard deviation / mean)','p95','95th percentile','max','Maximum');
        subjects=struct('BranchLen','retained branch path lengths','Tortuosity','branch path length divided by straight-line endpoint distance',...
            'IntercapDist','non-vessel tissue distance to the nearest FULL-mask vessel','CapRadius','distance-transform radius at retained skeleton pixels',...
            'LoopArea','retained loop areas measured to skeleton centerlines');
        unit='dimensionless';if endsWith(name,'_um2'),unit='um^2';elseif endsWith(name,'_um'),unit='um';end
        tips{k}=sprintf('%s of %s (%s).',stats.(token{1}),subjects.(token{2}),unit);
    end
    if strcmp(kind,'Radial')&&strcmp(name,'nJunctions')
        tips{k}='Junction PIXEL count within this bin (3 or more neighbors). Unlike Global, adjacent junction pixels are not grouped.';
    elseif strcmp(kind,'Windows')&&strcmp(name,'nBranches')
        tips{k}='Number of eligible branches whose centroids fall inside this overlapping analysis window.';
    end
end
cells=table2cell(T);rows=cell(height(T),1);
for r=1:height(T)
    row=cell(1,width(T));
    for c=1:width(T)
        value=cells{r,c};
        if ischar(value)&&isempty(value)
            row{c}='';
        elseif isscalar(value)&&ismissing(value)
            if isnumeric(value),row{c}='NaN';else,row{c}='';end
        else
            row{c}=char(string(value));
        end
    end
    rows{r}=row;
end
data=struct('columns',{columns},'tips',{tips},'rows',{rows});
data.message='';
if strcmp(kind,'Windows')&&height(T)==0
    data.message='No valid analysis windows were found. Check pixel size, orientation window size, minimum branch length, branches per window, and vessel segmentation. No window-level results are available.';
elseif strcmp(kind,'Coherence')&&any(T.nTiles==0)
    data.message='Bins with nTiles = 0 have no valid analysis windows: meanCoh, p90Coh, fracAligned and medianBranchesPerTile are undefined (NaN), not zero. Check pixel size, orientation window size, minimum branch length, branches per window, and vessel segmentation.';
end
end
