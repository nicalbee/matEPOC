clear
clc

% define the file location
in.dir = fileparts(which('matEPOC_example.m'));%'/Users/mq20111600/Google Drive/nWorkProjects/emotiv_context/data/raw/p2/p2_m_23_r_down/';
in.file_name = 'evnka101_1passive-evnka101_1passive-22.06.13.13.01.06.edf';
in.fullfile = fullfile(in.dir,in.file_name);
in.Hertz = 128;

in.remove_constant = 1;
% whether or not channel median is removed from each channel to correct for
% TestBench units - aroudn 4000 or so.

mep = edf2mat(in.fullfile,in.Hertz,in.remove_constant);

mep = matEPOCsampleRate(mep);

% returns a structured variable with:
% mep.matrix = data matrix
% mep.channel_labels = column lables for matrix
% mep.table = table combining matrix and channel labels - another
%   structure variable

mep.event_channels = {'O1','O2'};

mep = matEPOCevents(mep,'event_channels',mep.event_channels,'plot',...
    'pulse_length',[160 300],'pulse_separation',1000);

%% line the event markers up with behavioural conditions

in.pres_dir = in.dir;%'/Users/mq20111600/Google Drive/nWorkProjects/matEPOC/data/example/';
in.pres_file_name = 'evnka101_1passive-EvN_auditoryMMN.txt';
in.pres_fullfile = fullfile(in.pres_dir,in.pres_file_name);

% import the timing information of the events recorded by the behavioural
% presentation
pres = readPresentationTxt(in.pres_fullfile,'Var3','Var5');
% note: could also use:
% condition_header = 'Code';
% time_header = 'Time';
% pres = readPresentationTxt(in.pres_fullfile,condition_header,time_header);

mep.markers = matEPOCcondMatch('event_channels',mep.event_channels,...
    'markers',mep.markers,'sort_by','number_events',...
    'conditions',pres.condition,'times',pres.times,...
    'changes',mep.changes,'plot',...
    'Hertz',in.Hertz);

%% adjust event
% not sure whether to keep this function in the events function or not
mep.tmp.data = [mep.event_channels,mep.markers];
mep.tmp.data_labels = {'Ch1','Ch2','events'};
mep.markers = matEPOCeventAdjust(mep.tmp.data,'channel_labels',mep.tmp.data_labels,...
    'Hertz',mep.tmp.Hertz,'delay',8);

%% check channel

mep.tmp.data = [mep.matrix(:,3),mep.markers];
mep.tmp.data_labels = {'data','events'};
matEPOCcheckERP(mep.tmp.data,'channel_labels',mep.tmp.data_labels,...
    'Hertz',mep.tmp.Hertz,'plot');

%% save the data
in.save_dir = fullfile([matEPOCgetHigherDir(3),'data']); %'/Users/mq20111600/Google Drive/nWorkProjects/matEPOC/data/matEPOCout/';
[~,in.save_name,~] = fileparts(in.file_name);
matEPOCsave(mep,'dir',in.save_dir,'file_name',in.save_name);
