function qurvaWritePreview(image,path)
% PNG is a display artifact, not a quantitative mask. Bound both size and depth.
if ~isa(image,'uint8'),image=im2uint8(image);end
if max(size(image,1),size(image,2))>4096
    image=imresize(image,4096/max(size(image,1),size(image,2)));
end
imwrite(image,path);
end
