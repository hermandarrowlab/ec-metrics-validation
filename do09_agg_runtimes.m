%=========================================================================

% Name:			do09_agg_runtimes.m

% Author:		Kate Dembny
% Date:			10/12/2023
% Updated:		4/4/2024

% Syntax:		
% Arguments:	

% Description:	aggregate rumtime data for iterations
% Requirements: matlab
% Notes:

%% ========================================================================
 
% DIRECTORIES 

clearvars 

scr_dir = pwd;
pdir = fileparts(cd);
data_dir = [pdir filesep() 'data'];
fig_dir = [pdir filesep() 'figures' filesep() 'prelim_figs'];

nd_dir = [data_dir filesep() 'nodes'];
tp_dir = [data_dir filesep() 'time_points'];
ns_dir = [data_dir  filesep() 'noise'];
agg_dir = [data_dir filesep() 'agg'];

%% ========================================================================

%% NODE DATA

% ========================================================================

disp('Working on Nodes Data')

% STEP 1: Set labels for dimension orders

%labels = ["xc biv", "xc ptl", "mi biv", "gc", "te mv", "te bv"];
num_metrics = 9;

nodes_opts = [10, 20, 30, 50, 65];
pcts = 0:10:90;

dim_order = ["opts", "iters", "drop_pct", "fc_metrics"];

% -------------------------------------------------------------------------

% STEP 2: intstantiate arrays

nodes_runtimes = NaN(length(nodes_opts), 400, 10, num_metrics);

% -------------------------------------------------------------------------

% STEP 2: iterate over nodes - no node dropping
j=1;
for opt = [10,20, 30, 50, 65]
    for lett = 1:100
        lett_str = num2str(lett,'%03.f');
        wdir = [nd_dir filesep() num2str(opt) filesep() lett_str];

% -------------------------------------------------------------------------
    
% STEP 3: load data and assign to arrays 
        
        if exist([wdir filesep() 'mvte' filesep() 'te_multivar_runtime.txt'], 'file') && exist([wdir filesep() 'ml_fc' filesep() 'gc_runtime.mat'], 'file') && exist([wdir filesep() 'bvte'  filesep() 'te_bivar_runtime.txt'], 'file') && exist([wdir filesep() 'mi_lagged' filesep() 'mi_lagged_runtime.mat'], 'file') 
            disp([num2str(opt) ' ' lett_str])
                    
            % load data
            [nodes_runtimes(j,lett,1,:), labels]= load_data(wdir);
        end
    end
    j = j+1;
end

%% -------------------------------------------------------------------------

% STEP 4: iterate over nodes - 
j=1;
for opt = [10, 20, 30, 50, 65] %80
    for drop = 1:9
        i=1;
        for lett = 1:100
            lett_str = num2str(lett,'%03.f');
            
            for iter = 'a' %:'j'
                wdir = [nd_dir filesep() num2str(opt) filesep() lett_str filesep() 'drop_nodes' filesep() iter filesep() 'drop_' num2str(drop) '0pct'];

% -------------------------------------------------------------------------
    
% STEP 5: load data and assign to arrays 

                if exist([wdir filesep() 'mvte' filesep() 'te_multivar_runtime.txt'], 'file') && exist([wdir filesep() 'ml_fc' filesep() 'gc_runtime.mat'], 'file') && exist([wdir filesep() 'bvte'  filesep() 'te_bivar_runtime.txt'], 'file') && exist([wdir filesep() 'mi_lagged' filesep() 'mi_lagged_runtime.mat'], 'file') 
                    disp([num2str(opt) ' ' lett_str ' ' iter ' ' num2str(drop*10)])

                    % load data
                    [nodes_runtimes(j,lett,drop+1,:), labels] = load_data(wdir);
                    
                end
            end
        end
    end
    j = j+1;
end

% -------------------------------------------------------------------------

% STEP 7: get number of values in each group for visualization

nodes_rt_num_iters = sum(~isnan(nodes_runtimes),2);
nodes_rt_num_iters = squeeze(nodes_rt_num_iters(:,:,:,1));

% -------------------------------------------------------------------------

% STEP 8: save out data 

save([agg_dir filesep() 'nodes_all_rts.mat'], 'nodes_runtimes', 'nodes_rt_num_iters', 'labels', 'nodes_opts', 'pcts', 'dim_order')


%% ========================================================================

%% TIME POINT DATA

% ========================================================================

disp('Working on Time Points Data')

% STEP 1: Set labels for dimension orders

%labels = ["xc biv", "xc ptl", "mi biv", "gc", "te mv", "te bv"];
num_metrics = length(labels);

tps_opts = [500, 1000, 5000, 10000];
pcts = 0:10:90;

dim_order = ["opts", "iters", "drop_pct", "fc_metrics"];

% -------------------------------------------------------------------------

% STEP 2: intstantiate arrays

tps_runtimes = NaN(length(tps_opts), 400, 1, num_metrics);

% -------------------------------------------------------------------------

% STEP 2: iterate over nodes - no node dropping
j=1;
for opt = tps_opts
    i=1;
    for lett = 1:100
        lett_str = num2str(lett,'%03.f');
        wdir = [tp_dir filesep() num2str(opt) filesep() lett_str];

% -------------------------------------------------------------------------
    
% STEP 3: load data and assign to arrays 
        
        % mvte_dir = [wdir filesep() 'mvte'];
        % bvte_dir = [wdir filesep() 'bvte'];
        % mi_dir = [wdir filesep() 'mi'];
        % ml_dir = [wdir filesep() 'ml_fc'];
        
        if exist([wdir filesep() 'mvte' filesep() 'te_multivar_runtime.txt'], 'file') && exist([wdir filesep() 'ml_fc' filesep() 'gc_runtime.mat'], 'file') && exist([wdir filesep() 'bvte'  filesep() 'te_bivar_runtime.txt'], 'file') && exist([wdir filesep() 'mi_lagged' filesep() 'mi_lagged_runtime.mat'], 'file') 
            disp([num2str(opt) ' ' lett_str])

            % load data 
            [tps_runtimes(j,lett,1,:), labels] = load_data(wdir);
        end
    end
    j = j+1;
end

% -------------------------------------------------------------------------

% STEP 7: get number of values in each group for visualization

tps_rt_num_iters = sum(~isnan(tps_runtimes),2);
tps_rt_num_iters = squeeze(tps_rt_num_iters(:,:,:,1));

% -------------------------------------------------------------------------

% STEP 8: save out data 

save([agg_dir filesep() 'tps_all_rts.mat'], 'tps_runtimes', 'tps_rt_num_iters', 'labels', 'tps_opts', 'pcts', 'dim_order')


%% ========================================================================

%% NOISE DATA

% ========================================================================

disp('Working on Noise Data')

% STEP 1: Set labels for dimension orders

%labels = ["xc biv", "xc ptl", "mi biv", "gc", "te mv", "te bv"];
num_metrics = length(labels);

noise_opts = [0.01, 0.05, 0.1, 0.5 1 5 10 50];
pcts = 0:10:90;

dim_order = ["opts", "iters", "drop_pct", "fc_metrics"];

% -------------------------------------------------------------------------

% STEP 2: intstantiate arrays

noise_runtimes = NaN(length(noise_opts), 400, 1, num_metrics);

% -------------------------------------------------------------------------

% STEP 2: iterate over nodes - no node dropping
j=1;
for opt = noise_opts
    i=1;
    for lett = 1:100
        lett_str = num2str(lett,'%03.f');
        wdir = [ns_dir filesep() num2str(opt) filesep() lett_str];

% -------------------------------------------------------------------------
    
% STEP 3: load data and assign to arrays 
        
        if exist([wdir filesep() 'mvte' filesep() 'te_multivar_runtime.txt'], 'file') && exist([wdir filesep() 'ml_fc' filesep() 'gc_runtime.mat'], 'file') && exist([wdir filesep() 'bvte'  filesep() 'te_bivar_runtime.txt'], 'file') && exist([wdir filesep() 'mi_lagged' filesep() 'mi_lagged_runtime.mat'], 'file') 
            disp([num2str(opt) ' ' lett_str])
                    
            % load
           [noise_runtimes(j,lett,1,:), labels] = load_data(wdir);
        end
    end
    j = j+1;
end

% -------------------------------------------------------------------------

% STEP 7: get number of values in each group for visualization

noise_rt_num_iters = sum(~isnan(noise_runtimes),2);
noise_rt_num_iters = squeeze(noise_rt_num_iters(:,:,:,1));

% -------------------------------------------------------------------------

% STEP 8: save out data 

save([agg_dir filesep() 'noise_all_rts.mat'], 'noise_runtimes', 'noise_rt_num_iters', 'labels', 'noise_opts', 'pcts', 'dim_order')

%% ========================================================================

function [out_arr, lab_ord] = load_data(wdir)
    
    % load data

    rt_xc_biv = load([wdir filesep() 'ml_fc' filesep() 'xc_biv_runtime.mat']).end_time;
    rt_xc_pt = load([wdir filesep() 'ml_fc'  filesep() 'xc_pt_runtime.mat']).end_time;
    rt_mi = load([wdir filesep() 'mi_lagged'  filesep() 'mi_lagged_runtime.mat']).end_time;
    
    rt_gc = load([wdir filesep() 'ml_fc' filesep() 'gc_runtime.mat']).end_time;
    rt_bvte = importdata([wdir filesep() 'bvte' filesep() 'te_bivar_runtime.txt']);
    rt_mvte = importdata([wdir filesep() 'mvte' filesep() 'te_multivar_runtime.txt']);

    rt_xc_biv_zerolag = load([wdir filesep() 'ml_fc' filesep() 'xc_zerolag_biv_runtime.mat']).end_time;
    rt_xc_pt_zerolag = load([wdir filesep() 'ml_fc' filesep() 'xc_zerolag_pt_runtime.mat']).end_time;
    rt_mi_zerolag = load([wdir filesep() 'mi_zerolag'  filesep() 'mi_zerolag_runtime.mat']).end_time;

    % assign data to array
    out_arr = zeros(1,1,1,9);

    out_arr(1) =rt_xc_biv;
    out_arr(2) = rt_xc_pt;
    out_arr(3) = rt_gc;
    out_arr(4) = rt_mi;
    out_arr(5) = rt_bvte;
    out_arr(6) = rt_mvte;

    out_arr(7) = rt_xc_biv_zerolag;
    out_arr(8) = rt_xc_pt_zerolag;
    out_arr(9) = rt_mi_zerolag;

    lab_ord = ["xc biv", "xc pt", "gc", "mi biv", "te bv", "te mv", "xc biv zerolag", "xc pt zerolag", "mi zerolag"];

end
