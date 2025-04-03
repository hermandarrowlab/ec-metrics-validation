%% ========================================================================

% Name:			do03_drop_nodes.m

% Author:		Kate Dembny
% Date:			1/20/23
% Updated:		6/16/23

% Syntax:		
% Arguments:	

% Description:	drop nodes in timeseries
% Requirements: matlab
% Notes:    6/16/23 update - change orientation of ts to match input data
% for matching processing 

%% =======================================================================

% STEP 0: Take inputs

clearvars

% DIRECTORIES 

scr_dir = pwd;
pdir = fileparts(cd);
data_dir = [pdir filesep() 'data'];

%% ========================================================================

% STEP 1: open file

for opt = ["nodes", "time_points", "noise"]
    % set base directory
    var_dir = [data_dir filesep() convertStringsToChars(opt)];

    if strcmp(opt,'nodes')
        cycle = [10, 20, 30, 50, 65]; %, 80];
    elseif strcmp(opt,'time_points')
        cycle = [500, 1000, 5000, 10000, 50000];
    elseif strcmp(opt,'noise')
        cycle = [0.001, 0.005, 0.01, 0.05 0.1 0.5];
    end

    % iterate folder for node dropping
    for nd = cycle
        for rep = 1:100 %1:10
    
            disp(['Dropping data for ' convertStringsToChars(opt) ' = ' num2str(nd) ' iter ' num2str(rep,'%03.f')])
            cwd = [var_dir filesep() num2str(nd) filesep() num2str(rep,'%03.f')];
    
            % make directory to store dropped nodes
            if ~exist([cwd filesep() 'drop_nodes'], 'dir')
                mkdir([cwd filesep() 'drop_nodes'])
            end
    
%% ========================================================================
    
% STEP 2: generate 100 interations and 9 rounds of drops
    
            for iter = 'a' %'a':'j'
    
                load([cwd filesep() 'orig' filesep() 'orig_data.mat']);
                ts_size = size(ts,1);
    
                for drop_round = 1:9
    
% ========================================================================
    
% STEP 3: drop nodes
                    
                    savedir = [cwd filesep() 'drop_nodes' filesep() iter filesep() 'drop_' num2str(drop_round*10) 'pct' filesep() 'orig'];
                    if isfile([savedir filesep() 'orig_data.mat'])
                        continue
                    end
    
                    % fix rounding for numbers with 5 in ones place
                    if bitget(drop_round,1) == 1
                        drop_num = round(ts_size*.1);
                    else
                        drop_num =  floor(ts_size*.1);
                    end
                    
                    % select indices of random nodes to drop
                    git add 
                    
                    % drop nodes
                    ts(drop_idx, :) = [];
                    tcoup(drop_idx,:) = [];
                    tcoup(:,drop_idx) = [];
                    
                    % save out dropped nodes
                    
                    if ~exist(savedir, 'dir')
                        mkdir(savedir);
                    end
                    fname = 'orig_data.mat';
                    save([savedir filesep() fname], 'ts', 'tcoup')
                end
            end         
        end
    end
end