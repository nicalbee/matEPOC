function file_list = matEPOCfileList(in_dir,varargin)
file_list = [];
matEPOCindent;
try
    inputs.turnOn = {'display'};
    inputs.varargin = varargin;
    inputs.defaults = struct(...
        'dir',[],...
        'type','empty' ...
        );
    
    mep = setGetInputsStruct(inputs);
    
    if isempty(mep.dir) && ~isnumeric(in_dir) && exist(in_dir,'dir')
        mep.dir = in_dir;
    else
        fprintf('Data directory not found: aborting\n');
        return
    end
    mep.contents = [];
    if ~isempty(mep.type) && ~strcmp(mep.type(1),'.')
        mep.type = sprintf('.%s',mep.type);
    end
    switch matEPOCfileTypes(mep.type)
        case {'data','condition'}
            mep.contents = dir(fullfile(mep.dir,sprintf('*%s',mep.type)));
        otherwise
            mep.contents = dir(mep.dir);
    end
    file_count = 0;
    if mep.display && numel(mep.contents) > 2
        fprintf('\tFile list:\n');
    end
    for i = 1 : numel(mep.contents)
        mep.tmp_name = fullfile(mep.dir,mep.contents(i).name);
        if ~exist(mep.tmp_name,'dir') && exist(mep.tmp_name,'file')
            file_count = file_count + 1;
            file_list{file_count} = mep.tmp_name;
            if mep.display
                fprintf('\t%i: %s\n',file_count,mep.contents(i).name);
            end
        end
    end
    
    fprintf('\n\tReturning list of %i files\n\n',numel(file_list));
    matEPOCindent('done');
catch err
    save(matEPOCdebug);rethrow(err);
end
