function display(fileStream)
%
% Display the class members
%

width = 20;
whitespace = ' ';
fieldlist = fieldnames(fileStream);
for n = 1:length(fieldlist)
    num_whitespace = width - length(fieldlist{n});
    if ~isempty(fileStream.(fieldlist{n}))
        if ~iscell(fileStream.(fieldlist{n}))
            eval(['disp([''' whitespace(ones(1,num_whitespace)) fieldlist{n} ' : '' num2str(fileStream.(fieldlist{n})(1,:))])'])
            for m = 2:size(fileStream.(fieldlist{n}),1)
                eval(['disp([''' whitespace(ones(1,width)) ' : '' num2str(fileStream.(fieldlist{n})(' num2str(m) ',:))])'])
            end % for m
        else
            val = [];
            for m = 1:length(fileStream.(fieldlist{n}))
                val = [val '''' fileStream.(fieldlist{n}){m} ''' '];
            end % for m
            eval(['disp([''' whitespace(ones(1,num_whitespace)) fieldlist{n} ' : '' val])'])
        end
    else
        eval(['disp([''' whitespace(ones(1,num_whitespace)) fieldlist{n} ' : []''])'])
    end
%     eval(['disp([''' whitespace(ones(1,num_whitespace)) fieldlist{n} ' : '' num2str(reshape(fileStream.(fieldlist{n})'',1,prod(size(fileStream.(fieldlist{n})))))])'])
end % for n

% disp(['               length : ' num2str(fileStream.length)])
% disp(['               records : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% disp(['               Length : ' num2str(fileStream.length)])
% 
% fileStream.length       = str2num(hdr(185:192));
% fileStream.records      = str2num(hdr(237:244));
% fileStream.duration     = str2num(hdr(245:252));
% fileStream.channels     = str2num(hdr(253:256));
% fileStream.channelname  = char(fread(fileStream.fid,[16,fileStream.channels],'char')');
% fileStream.transducer   = char(fread(fileStream.fid,[80,fileStream.channels],'char')');
% fileStream.physdime     = char(fread(fileStream.fid,[8,fileStream.channels],'char')');
% fileStream.physmin      = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
% fileStream.physmax      = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
% fileStream.digimin      = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
% fileStream.digimax      = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
% fileStream.prefilt      = char(fread(fileStream.fid,[80,fileStream.channels],'char')');
% fileStream.samplerate   = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
