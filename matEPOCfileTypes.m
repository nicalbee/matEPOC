function file_type = matEPOCfileTypes(in_type)

if ~exist('in_type','var') || isempty(in_type)
    fprintf('A file type input is needed (e.g., ''.edf''): aborting\n');
    return
end
file_type = 'empty';
switch in_type
    case {'.edf','edf'}
        file_type = 'data';
    case {'.txt','txt'}
        file_type = 'condition';
    otherwise
        fprintf('File type (%s) not recognised: returning ''%s''\n',in_type,file_type);
end
        