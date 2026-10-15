function [result,overlay,folder] = qurvaAnalyze(image,mask,center,p,imagePath,fullAnalysis)
% Adapt one image and explicit ROIs to the unchanged modified-QuRVA metrics.
vendor=fullfile(fileparts(mfilename('fullpath')),'vendor','qurva');
addpath(vendor);
old=pwd; cleanup=onCleanup(@()cd(old)); cd(vendor);
folder=tempname; mkdir(folder);
for name={'Masks','ONCenter','VasculatureNumbers'}, mkdir(fullfile(folder,name{1})); end
[~,n,e]=fileparts(imagePath); file=[n e '.mat'];
thisMask=mask; thisONCenter=center;
save(fullfile(folder,'Masks',file),'thisMask');
save(fullfile(folder,'ONCenter',file),'thisONCenter');
[gray,sf]=resetScale(im2uint8(image)); resizedMask=resetScale(mask);
[vesselSkelMask,brchPts,smoothVessels,endPts]=getVacularNetwork(resizedMask,gray);
aVascZone=getAvacularZone(resizedMask,vesselSkelMask,computeRetinaSize(resizedMask,center/sf),center/sf);
save(fullfile(folder,'VasculatureNumbers',file),'vesselSkelMask','brchPts','smoothVessels','endPts','aVascZone');
radius=p.radius; if radius==0, radius=Inf; end
cap=struct('pixSzeUM',p.pixelSize,'basePxUM',p.pixelSize,'radiusThreshUM',radius,...
    'minBranchPix',p.branch,'gapPix',p.gap,'minLoopUM2',p.loop,'nBins',p.bins,...
    'minLenUM',p.length,'tileUM',p.tile,'minBranches',p.branches,'cohThresh',p.coherence);
D=bwdist(~smoothVessels);
small=bwareaopen(logical(vesselSkelMask)&D>0&D<=radius/(p.pixelSize*sf),p.branch,8);
large=logical(vesselSkelMask)&D>radius/(p.pixelSize*sf);
% Bound display/export memory: RGB uint8 on the analysis grid, not full-size doubles.
% The UI image XData/YData retain original-image coordinates for editable ROIs.
overlay=repmat(im2uint8(gray),[1 1 3]);
small=uint8(imdilate(small,strel('disk',1)))*255;
large=uint8(imdilate(large,strel('disk',1)))*255;
overlay(:,:,2)=max(overlay(:,:,2),small);
overlay(:,:,1)=max(overlay(:,:,1),large); overlay(:,:,3)=max(overlay(:,:,3),large);
result=struct();
if fullAnalysis
    result.Global=statsFromQuRVA_v2(folder,cap);
    assert(all(result.Global.ok),'Global analysis failed: %s',strjoin(string(result.Global.msg),'; '));
    result.Radial=radialTopology(folder,cap);
    assert(height(result.Radial)==p.bins,'Radial analysis did not return every bin.');
    [result.Coherence,result.Windows]=batchLocalCoherence(folder,cap);
    assert(height(result.Coherence)==p.bins,'Coherence analysis did not return every bin.');
end
settings=p; sourceImage=imagePath; boundaryMask=mask; opticNerveCenter=center;
save(fullfile(folder,'session.mat'),'settings','sourceImage','boundaryMask','opticNerveCenter','sf');
fid=fopen(fullfile(folder,'settings.json'),'w'); closeFile=onCleanup(@()fclose(fid));
fprintf(fid,'%s',jsonencode(struct('settings',p,'sourceImage',imagePath,...
    'matlabVersion',version,'appVersion','0.1.0','scaleFactor',sf,'analysisComplete',fullAnalysis),PrettyPrint=true));
end
