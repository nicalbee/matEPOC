function fileStream = open(fileStream, varargin)
%
% Open the EDF file and read the header
%

%% Open file
fileStream.fid = fopen(fileStream.filename,'r','ieee-le');
if fileStream.fid == -1,
  error(['File not found: ' fileStream.filename]);
end

%% Read header and assign the information to the fileStream object
hdr = char(fread(fileStream.fid, 256, 'uchar')');
fileStream.version      = str2num(hdr(1:8));
fileStream.subject      = hdr(9:88);
fi = find(fileStream.subject ~= ' ');
fileStream.subject      = fileStream.subject(1:fi(end));
fileStream.recording    = hdr(89:168);
fi = find(fileStream.recording ~= ' ');
fileStream.recording    = fileStream.recording(1:fi(end));
fileStream.date         = hdr(169:176);
fileStream.time         = hdr(177:184);
fileStream.length       = str2num(hdr(185:192));
fileStream.records      = str2num(hdr(237:244));
fileStream.duration     = str2num(hdr(245:252));
fileStream.channels     = str2num(hdr(253:256));
tvec                    = datevec(datenum([fileStream.date '.' fileStream.time], 'dd.mm.yy.HH.MM.SS'));
fileStream.timestamp    = floor(datenum([tvec(1)-1900 tvec(2:end)])*24*3600*1000);
fileStream.channelname  = cellstr(char(fread(fileStream.fid,[16,fileStream.channels],'char')'))';
fileStream.transducer   = cellstr(char(fread(fileStream.fid,[80,fileStream.channels],'char')'))';
fileStream.physdime     = cellstr(char(fread(fileStream.fid,[8,fileStream.channels],'char')'))';
fileStream.physmin      = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
fileStream.physmax      = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
fileStream.digimin      = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
fileStream.digimax      = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));
fileStream.prefilt      = cellstr(char(fread(fileStream.fid,[80,fileStream.channels],'char')'))';
fileStream.samplerate   = str2num(char(fread(fileStream.fid,[8,fileStream.channels],'char')'));

fseek(fileStream.fid, fileStream.length, 'bof'); % 'bof' == -1

% Fill the buffer with the first record
% fileStream.buffer       = fread(fileStream.fid, [fileStream.duration*fileStream.samplerate(1) fileStream.channels], 'int16');


end