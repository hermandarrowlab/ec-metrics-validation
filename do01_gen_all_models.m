%=========================================================================

% Name:			do01_gen_all_models.m

% Author:		Kate Dembny
% Date:			9/1/2022
% Updated:		9/1/2022

% Syntax:		
% Arguments:	                                                   

% Description:	generate models of neural signals
% Requirements: matlab
% Notes:

%% ========================================================================
 
% DIRECTORIES 

clearvars 

scr_dir = pwd;
pdir = fileparts(cd);
data_dir = [pdir filesep() 'data'];

nd_dir = [data_dir filesep() 'nodes'];
tp_dir = [data_dir filesep() 'time_points'];
ns_dir = [data_dir  filesep() 'noise'];
ref_dir = [data_dir  filesep() 'rereference'];

if ~exist(nd_dir, 'dir')
    mkdir(nd_dir);
end

if ~exist(tp_dir, 'dir')
    mkdir(tp_dir);
end

if ~exist(ns_dir, 'dir')
    mkdir(ns_dir);
end

if ~exist(ref_dir, 'dir')
    mkdir(ref_dir);
end

% ========================================================================

% STEP 0: Generate items to iterate over

def_nd = 50;
def_tp = 10000;
def_dns = 0.01;
def_mns = 0;

%% ========================================================================

% STEP 1: Generate models for nodes

for nd = [10, 20, 30, 50, 65]
    for iter = 1:100

        cwd = [nd_dir filesep() num2str(nd) filesep() num2str(iter,'%03.f') filesep() 'orig'];
        if ~exist(cwd, 'dir')
            mkdir(cwd);
        end

        if ~exist([cwd filesep() 'orig_data.mat'], 'file')
            disp(['Making data for ' int2str(nd) ' nodes, repetition ' num2str(iter,'%03.f')])
            [tcoup, A, ts] = gen_model(nd,10,def_tp,0.1,0.1,def_dns, def_mns);
            
            reps = 1;
            while max(ts, [], 'all') > 10
                [tcoup, A, ts] = gen_model(nd,10,def_tp,0.1,0.1,def_dns, def_mns);
                reps = reps + 1;
            end
            ts = transpose(ts);

            disp(['For ' num2str(nd) ' nodes in iter ' num2str(iter,'%03.f') ', ' num2str(reps) ' steps were required for it to converge'])
            save([cwd filesep() 'orig_data'], 'tcoup', 'ts');
            save([cwd filesep() 'reps2gen'], 'reps');
        end
    end
end

%% ========================================================================

% STEP 2: Generate models for length of timeseries

for tp = [500, 1000, 5000, 10000, 50000, 100000]
    for iter = 1:100

        cwd = [tp_dir filesep() num2str(tp) filesep() num2str(iter,'%03.f') filesep() 'orig'];
        if ~exist(cwd, 'dir')
            mkdir(cwd);
        end
        
        if ~exist([cwd filesep() 'orig_data.mat'], 'file')
            disp(['Making data for ' int2str(tp) ' time points, repetition ' num2str(iter,'%03.f')])
            [tcoup, A, ts] = gen_model(def_nd,10,tp,0.1,0.1,def_dns, def_mns);
            
            reps = 1;
            while max(ts, [], 'all') > 10
                [tcoup, A, ts] = gen_model(def_nd,10,tp,0.1,0.1,def_dns, def_mns);
                reps = reps + 1;
            end
            ts = transpose(ts);

            disp(['For ' num2str(tp) ' timepoints in iter ' num2str(iter,'%03.f') ', ' num2str(reps) ' steps were required for it to converge'])
            save([cwd filesep() 'orig_data'], 'tcoup', 'ts');
            save([cwd filesep() 'reps2gen'], 'reps');
        end
    end
end

%% ========================================================================

% STEP 3: Generate models for noise

for snr_est = [50 10 5 1 0.5 0.1 0.05 0.01]
    for iter = 1:100
        cwd = [ns_dir filesep() num2str(snr_est) filesep() num2str(iter,'%03.f') filesep() 'orig'];
        if ~exist(cwd, 'dir')
            mkdir(cwd);
        end
        
        if ~exist([cwd filesep() 'orig_data.mat'], 'file')
            disp(['Making data for SNR = ' num2str(snr_est) ', repetition ' num2str(iter,'%03.f')])
            
            % generate model
           [tcoup, A, ts, noise_sig, true_snr] = gen_model(def_nd,10,def_tp,0.1,0.1,def_dns,snr_est);
            
            reps = 1;
            while max(ts, [], 'all') > 10
                [tcoup, A, ts, noise_sig, true_snr] = gen_model(def_nd,10,def_tp,0.1,0.1,def_dns,snr_est);
                reps = reps + 1;
            end
            ts = transpose(ts);

            disp(['For SNR = ' num2str(snr_est) ' in iter ' num2str(iter,'%03.f') ', ' num2str(reps) ' steps were required for it to converge'])
            save([cwd filesep() 'orig_data'], 'tcoup', 'ts', 'snr_est', 'noise_sig', 'true_snr');
            save([cwd filesep() 'reps2gen'], 'reps');
        end
    end
end

% =========================================================================