function fileStream = EDFFileStream(filename, nDataRead)
% 
% EDFFileStream constructor
%

% Check input arguments
if ~exist(filename, 'file')
    error(['File does not exist: ' filename]);
end
if ~exist('nDataRead', 'var'), nDataRead = 1; end

% Initialise class members
fileStream.filename     = filename;     % Filename with complete path
fileStream.nDataRead    = nDataRead;    % Number of samples to read per call
fileStream.fid          = 0;            % File identifier
fileStream.version      = 0;            % Version number
fileStream.subject      = '';           % Subject information
fileStream.recording    = '';           % Recording information
fileStream.length       = 0;            % Number of bytes in header
fileStream.records      = 0;            % Number of records in data
fileStream.duration     = 0;            % Length of a record in second
fileStream.channels     = 0;            % Number of channels
fileStream.date         = '';           % Starting date (dd.mm.yy)
fileStream.time         = '';           % Starting time (hh.mm.ss)
fileStream.timestamp    = 0;            % Labview-based timestamp evaluated from date and time
fileStream.channelname 	= '';           % Cell array of channel labels
fileStream.transducer   = '';           % Cell array of sensor types
fileStream.physdime     = '';           % Cell array of physical dimensions or units
fileStream.physmin      = 0;            % Array of minimum physical values
fileStream.physmax      = 0;            % Array of maximum physical values
fileStream.digimin      = 0;            % Array of minimum digital values
fileStream.digimax      = 0;            % Array of maximum digital values
fileStream.prefilt      = '';           % Cell array of prefiltering information
fileStream.samplerate   = 0;            % Array of sampling rate
fileStream.sample_index = 0;            % Sample index/offset
fileStream.buffer       = zeros(fileStream.duration*fileStream.samplerate(1),fileStream.channels); 
% Buffer of one record at a time. It is updated when the record has been
% completely read.

% Set the structure to class
fileStream = class(fileStream, 'EDFFileStream');

%     fileStream.filename     = filename;
%     fileStream.nDataRead    = nDataRead;
%     
%     fileStream.timestamp     = 0;
%     fileStream.fid           = [];
%     fileStream.rowFormat     = [];
%     fileStream.isInit        = 0;
%     fileStream.nCol          = 0;
%     fileStream.eegChanIdx    = [];
%     fileStream.labels        = {};
%     fileStream.sr            = 0;
%     fileStream.units         = '';
%     fileStream.eegMultiplier = 0.0;
%     
%     if (~exist(filename, 'file'))
%         error('File dooes not exist');
%     end
%     
%     fileStream = class(fileStream, 'CsvFileStream');
end