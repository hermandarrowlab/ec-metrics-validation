% =========================================================================

% Name:			doXX_addShuffs.m

% Author:		Kate Dembny
% Date:			4/24/24
% Updated:		4/24/24

% Syntax:		
% Arguments:	

% Description:	add suffled count of connections
% Requirements: matlab
% Notes:

%% ========================================================================
 
% DIRECTORIES 

clearvars 

scr_dir = pwd;
pdir = fileparts(cd);
data_dir = [pdir filesep() 'data'];
fig_dir = [pdir filesep() 'figures' filesep() 'prelim_figs'];

agg_dir = [data_dir filesep() 'agg'];

if ~exist(agg_dir, 'dir')
    mkdir(agg_dir)
end

addpath('/home/kdembny/MATLAB/toolboxes/cprintf/cprintf')

% =========================================================================

% STEP 1: set baseline connection parameters

cnxnProb = 0.1;

% -------------------------------------------------------------------------

% STEP 2: iterate through files 

for opt = ["nodes", "time_points", "noise"] % , "rereference"
    % set base directory
    var_dir = [data_dir filesep() convertStringsToChars(opt)];

    if strcmp(opt,'nodes')
        cycle = ["10", "20", "30", "50", "65"];
    elseif strcmp(opt,'time_points')
        cycle = ["500", "1000", "5000", "10000", "50000"];
    elseif strcmp(opt,'noise')
        cycle = ["0.001", "0.005", "0.01", "0.05", "0.1", "0.5", "1", "5", "10", "50"];
    elseif strcmp(opt, 'rereference')
        cycle = ["cmn_avg", "hrdwr_ref", "random"];
    end

    % iterate folder for node dropping
    for nd = cycle
        for rep = 1:100
    
            cwd = [var_dir filesep() convertStringsToChars(nd) filesep() num2str(rep,'%03.f')]; %num2str(nd)
            outdir = [cwd filesep 'shuff'];

            % make directory to store thresholded data
            if ~exist(outdir, 'dir')
                mkdir(outdir)
            end

            % skip if no original connection data
            if ~exist([cwd filesep 'orig' filesep 'orig_data.mat'], 'file')
                continue
            end

% -------------------------------------------------------------------------

% STEP 3: load data and make shuffled map with same number of connections (no node dropping)

            if ~exist([cwd filesep() 'shuff' filesep() 'shuff.mat'])
                %load true connection data
                cprintf('blue', ['Loading data for ' convertStringsToChars(opt) '=' convertStringsToChars(nd) ' rep ' num2str(rep,'%03.f') ' \n'])
                load([cwd filesep 'orig' filesep 'orig_data.mat'])
                
                % shuffle data
                disp('Shuffling data')
                shuff = shuffleCnxns(cnxnProb, size(tcoup,1), outdir);
            end

% STEP 4: run for node dropping

            for drop = 10:10:90

                cwd = [var_dir filesep() convertStringsToChars(nd) filesep() num2str(rep,'%03.f') filesep 'drop_nodes' filesep 'a' filesep 'drop_' num2str(drop) 'pct']; %num2str(nd)
                outdir = [cwd filesep 'shuff'];

                % make outdir if it doesn't exist
                if ~exist(outdir, 'dir')
                    mkdir(outdir)
                end

                % skip if there are no original data files
                if ~exist([cwd filesep 'orig' filesep 'orig_data.mat'], 'file')
                    continue
                end


                % check if shuffled file already exists 
                if ~exist([cwd filesep() 'shuff' filesep() 'shuff.mat'])
                     % load true connection data
                    cprintf('blue', ['Loading data for ' convertStringsToChars(opt) '=' convertStringsToChars(nd) ' rep ' num2str(rep,'%03.f') ', '  num2str(drop) ' percent nodes dropped \n'])
                    load([cwd filesep 'orig' filesep 'orig_data.mat'])

                    % generate shuffled data
                    disp('Shuffling data')
                    shuff = shuffleCnxns(cnxnProb, size(tcoup,1), outdir);
                end
            end
        end
    end
end

function shuff = shuffleCnxns(cnxnProb, szTcoup, outdir)

    % generate random array
    shuff = rand([szTcoup, szTcoup]);
    shuff = double(shuff <= cnxnProb);
    
    % zero out diagonal
    for i=1:szTcoup
        shuff(i,i)=0; % remove coupled diagnals
    end

    % save out data
    save([outdir filesep 'shuff.mat'], "shuff")
end