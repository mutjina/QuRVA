function app = runQuRVA
% Start the single-image QuRVA interface.
try
    startupNote('Creating application window.');
    app = QuRVAApp;
    app.Figure.Visible='on';drawnow;
    startupNote('Application window ready.');
    if isdeployed
        % A compiled GUI must keep the entry point alive for UI callbacks.
        uiwait(app.Figure);
    end
catch err
    path=fullfile(tempdir,'QuRVA-startup.log');
    fid=fopen(path,'a');
    if fid>=0
        fprintf(fid,'%s\n%s\n',char(datetime('now')),getReport(err,'extended','hyperlinks','off'));fclose(fid);
    end
    if isdeployed
        dialog=errordlg(sprintf('QuRVA could not start. Diagnostic log:\n%s\n\nError ID: %s',path,err.identifier),'QuRVA startup error','modal');
        waitfor(dialog);
    else
        rethrow(err);
    end
end
end

function startupNote(message)
try
    fid=fopen(fullfile(tempdir,'QuRVA-startup.log'),'a');
    if fid>=0,fprintf(fid,'%s %s\n',char(datetime('now')),message);fclose(fid);end
catch
end
end
