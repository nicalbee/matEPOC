% Bec Bonfield's GoNoGo data processing for EPOC data
%
% date: 19-Aug-2015
%
% Nic Badcock (nicholas.badcock@mq.edu.au)
%
% aim:
% check in the new EPOC trigger programs (now affectionately known as
% 'matEPOC') will help to sort of the condition matching from Bec's data
%
clear
clc

% define the file location

in.data_dir = 'c:\Desktop\Emotiv\Matlab\rawdata\';
in.edf_file_name = '101-gngH_1-101_gngH_1-12.04.13.15.58.46.edf';
in.presention_file_name = '101-gngH_1-block_1corr2.txt';

in.fullfile = fullfile(in.data_dir,in.edf_file_name); % 'evnka101_1passive-evnka101_1passive-22.06.13.13.01.06.edf';
in.pres_fullfile = fullfile(in.data_dir,in.presention_file_name);

if ~exist(in.fullfile,'file')
    warndlg(sprintf('File does''t exist: %s',in.edf_file_name),'Missing File:');
    return;
end
if ~exist(in.pres_fullfile,'file')
    warndlg(sprintf('Presentation file does''t exist: %s',in.presentation_file_name),'Missing File:');
    return;
end

% where should the data be saved
in.save_dir = 'c:\Desktop\Emotiv\Matlab\matdata\';
if ~exist(in.save_dir,'dir')
    mkdir(in.save_dir);
end


in.Hertz = 128;

mep = edf2mat(in.fullfile,in.Hertz);

% returns a structured variable with:
% mep.matrix = data matrix
% mep.channel_labels = column lables for matrix
% mep.table = table combining matrix and channel labels - another
%   structure variable

mep.event_channel_labels = {'O1','O2'};

[mep,okay] = matEPOCevents(mep,'event_channels',mep.event_channel_labels,...'plot',...
    'pulse_length',100,'pulse_separation',1200,'event_threshold',50);

if okay
    %% line the event markers up with behavioural conditions
    
    pres = readPresentationTxt(in.pres_fullfile);
    
    mep.markers = matEPOCcondMatch('event_channels',mep.event_channels,...
        'markers',mep.markers,'changes',mep.changes,...
        'conditions',pres.condition,'times',pres.times,...
        'Hertz',in.Hertz,'plot','file_name',in.edf_file_name,......
        'sort_by','number_events');    
    
    mep.tmp.data = [mep.event_channels,mep.markers];
    mep.tmp.data_labels = {'Ch1','Ch2','events'};
    mep.markers = matEPOCeventAdjust(mep.tmp.data,'channel_labels',mep.tmp.data_labels,...
        'Hertz',mep.tmp.Hertz,'delay',8);
    
    [~,in.save_name,~] = fileparts(in.fullfile);
    
    matEPOCsave(mep,'dir',in.save_dir,'file_name',in.save_name);
end
