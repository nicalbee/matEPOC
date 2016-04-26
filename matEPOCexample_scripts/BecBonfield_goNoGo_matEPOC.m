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
in.edf_dir = '/Users/mq20111600/Google Drive/nPeople/RebeccaBonfield/EPOC_gonogo/data/raw2/';
in.edf_file_list = matEPOCfileList(in.edf_dir,'type','.edf','display');

in.cond_dir = in.edf_dir;
in.cond_file_list = matEPOCfileList(in.cond_dir,'type','.txt','display');


% the data (edf) and condition (txt) files are named such that the first 6
% characters (or more) should be the same. Check this before calling the
% condition files for condition matching below
in.edf_cond_match = zeros(numel(in.edf_file_list),1);
in.edf_cond_match_files = [];
in.edf_cond_match_count = 0;
in.edf_match_characters = 3;

for i = 1 :  numel(in.edf_file_list)
    [~,tmp_edf_name,~] = fileparts(in.edf_file_list{i});
    for j = 1 : numel(in.cond_file_list)
        [~,tmp_cond_name,~] = fileparts(in.cond_file_list{j});
        if strcmp(tmp_edf_name(1:in.edf_match_characters),tmp_cond_name(1:in.edf_match_characters))
            in.edf_cond_match(i) = 1;
            in.edf_cond_match_count = in.edf_cond_match_count + 1;
            fprintf('%i match (file %i):\n\t> %s\n\t> %s\n',...
                in.edf_cond_match_count,i,tmp_edf_name,tmp_cond_name);
            in.edf_cond_match_files{i} = in.cond_file_list{j};
        end
    end
end

% 2 x 128 files, first in block 2 (6), second is block 1 (7)
in.edf_cond_match_files{6} = in.cond_file_list{6};
in.edf_cond_match_files{7} = in.cond_file_list{7};

% where should the data be saved
in.save_dir = '/Users/mq20111600/Google Drive/nPeople/RebeccaBonfield/EPOC_gonogo/data/mat2/';

% now loop through edf files
for i = 7 %: numel(in.edf_file_list)
    
    in.fullfile = in.edf_file_list{i}; % 'evnka101_1passive-evnka101_1passive-22.06.13.13.01.06.edf';
    
    in.Hertz = 128;
    
    mep = edf2mat(in.fullfile,in.Hertz);
    
    % returns a structured variable with:
    % mep.matrix = data matrix
    % mep.channel_labels = column lables for matrix
    % mep.table = table combining matrix and channel labels - another
    %   structure variable
    
    mep.event_channel_labels = {'O1','O2'};
    
    [mep,okay] = matEPOCevents(mep,'event_channels',mep.event_channel_labels,...'plot',...edi
        'pulse_length',100,'pulse_separation',1200,'event_threshold',50);
    
    if okay
        %% line the event markers up with behavioural conditions
        if ~isempty(in.edf_cond_match_files{i})
            
            %         in.pres_dir = '/Users/mq20111600/Google Drive/nWorkProjects/matEPOC/data/example/';
            %         in.pres_file_name = 'evnka101_1passive-EvN_auditoryMMN.txt';
            in.pres_fullfile = in.edf_cond_match_files{i};
            
            pres = readPresentationTxt(in.pres_fullfile);
            
            
            mep.markers = matEPOCcondMatch('event_channels',mep.event_channels,...
                'markers',mep.markers,'changes',mep.changes,...
                'conditions',pres.condition,'times',pres.times,...
                'Hertz',in.Hertz,'plot','file_name',in.fullfile,...
                'sort_by','number_events');
        end
        
        mep.tmp.data = [mep.event_channels,mep.markers];
        mep.tmp.data_labels = {'Ch1','Ch2','events'};
        mep.markers = matEPOCeventAdjust(mep.tmp.data,'channel_labels',mep.tmp.data_labels,...
            'Hertz',mep.tmp.Hertz,'delay',8);
        
        [~,in.save_name,~] = fileparts(in.fullfile);
        matEPOCsave(mep,'dir',in.save_dir,'file_name',in.save_name);
    end
end