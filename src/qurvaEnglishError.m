function message=qurvaEnglishError(err)
% Never pass localized toolbox diagnostics straight into the English UI.
if all(double(err.message)<128)
    message=err.message;
else
    id=err.identifier;
    if contains(lower(id),{'png','imwrite','imagewrite'})
        message='The preview image could not be saved. Try a writable output folder with enough free disk space.';
    elseif contains(lower(id),{'json','decode'})
        message='The settings file could not be read. Select a valid QuRVA settings JSON file.';
    elseif contains(lower(id),{'imread','tiff','fileopen'})
        message='The image could not be opened. Check the TIFF format and file permissions.';
    else
        message='The operation could not be completed. Check the input image, settings, and output folder.';
    end
    if ~isempty(id),message=[message newline 'Error ID: ' id];end
end
% Keep diagnostic details outside the user-facing dialog.
try
    fid=fopen(fullfile(tempdir,'QuRVA-errors.log'),'a');
    if fid>=0,c=onCleanup(@()fclose(fid));fprintf(fid,'%s\n%s\n',char(datetime('now')),getReport(err,'extended','hyperlinks','off'));end
catch
end
end
