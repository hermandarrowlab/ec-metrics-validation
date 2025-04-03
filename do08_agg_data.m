% =========================================================================

% Name:			do08_agg_data.m

% Author:		Kate Dembny
% Date:			10/4/2023
% Updated:		10/4/2023

% Syntax:		
% Arguments:	

% Description:	aggregate data
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
rr_dir = [data_dir filesep() 'rereference'];
agg_dir = [data_dir filesep() 'agg'];

if ~exist(agg_dir, 'dir')
    mkdir(agg_dir)
end

% ========================================================================

% Set variables used for all iterations
num_metrics = 10;
pcts = 0:10:90;
dim_order = ["opts", "iters", "drop_pct", "fc_metrics"];

cosdst_flder = 'norm';

% ========================================================================

%% NODE DATA

% ========================================================================

disp('Working on Nodes Data')

% STEP 1: set options for node number experiments

nodes_opts = [10, 20, 30, 50, 65];

% -------------------------------------------------------------------------

% STEP 2: instantiate arrays

nodes_cos_dist = NaN(length(nodes_opts), 100, 10, num_metrics);

% -------------------------------------------------------------------------

% STEP 3: iterate over nodes without node dropping

j=1;
for opt = [10, 20, 30, 50, 65]
    for lett = 1:100
        lett_str = num2str(lett,'%03.f');
        wdir = [nd_dir filesep() num2str(opt) filesep() lett_str];
    
% -------------------------------------------------------------------------
    
% STEP 4: load data and assign to arrays 

        outdir = [wdir filesep() cosdst_flder];
        if exist([outdir filesep() 'cos_dist.mat'], 'file')

            disp([num2str(opt) ' ' lett_str])
            
            % load data with function
            [nodes_cos_dist(j,lett,1,:), labels] = load_data(outdir);
        end
    end
    j = j+1;
end

%% -------------------------------------------------------------------------

% STEP 5: iterate over nodes in node dropping

j=1;
for opt = [10, 20, 30, 50, 65]

    for drop = 1:9
        for lett = 1:100 %0
            lett_str = num2str(lett,'%03.f');
            
            for iter = 'a' %:'j'
                wdir = [nd_dir filesep() num2str(opt) filesep() lett_str filesep() 'drop_nodes' filesep() iter filesep() 'drop_' num2str(drop) '0pct'];
    
% -------------------------------------------------------------------------
    
% STEP 6: load data and assign to arrays 

                outdir = [wdir filesep() cosdst_flder];
                if exist([outdir filesep() 'cos_dist.mat'], 'file')
                    disp([num2str(opt) ' ' lett_str ' ' iter ' ' num2str(drop*10)])

                    % load data with function
                    [nodes_cos_dist(j,lett,drop+1,:), labels] = load_data(outdir);    
                end
            end
        end
    end
    j = j+1;
end

% -------------------------------------------------------------------------

% STEP 7: get number of values in each group for visualization

nodes_num_iters = sum(~isnan(nodes_cos_dist),2);
nodes_num_iters = squeeze(nodes_num_iters(:,:,:,1));

% -------------------------------------------------------------------------

% STEP 8: save out data 

save([agg_dir filesep() 'nodes_all_dist.mat'], 'nodes_cos_dist', 'nodes_num_iters', 'labels', 'nodes_opts', 'pcts', 'dim_order')

% ========================================================================

%% TIME POINT DATA

% ========================================================================

disp('Working on Time Point Data')

% STEP 1: set options time point experminents

tps_opts = [500, 1000, 5000, 10000];

% -------------------------------------------------------------------------

% STEP 2: instantiate arrays

tps_cos_dist = NaN(length(tps_opts), 100, 10, num_metrics);

% -------------------------------------------------------------------------

% STEP 3: iterate over tp options without node dropping

j=1;
for opt = [500, 1000, 5000, 10000]
    i=1;
    for lett = 1:100
        lett_str = num2str(lett,'%03.f');
        wdir = [tp_dir filesep() num2str(opt) filesep() lett_str];
    
% -------------------------------------------------------------------------
    
% STEP 4: load data and assign to arrays 
        outdir = [wdir filesep() cosdst_flder];
        if ~exist([outdir filesep() 'cos_dist.mat'], 'file')
            disp(['Missing: ' num2str(opt) ' ' lett_str])
        else
            disp([num2str(opt) ' ' lett_str])

            % load data with function
            [tps_cos_dist(j,lett,1,:), labels] = load_data(outdir);
        end
    end
    j = j+1;
end

% -------------------------------------------------------------------------

% STEP 7: get number of values in each group for visualization

tps_num_iters = sum(~isnan(tps_cos_dist),2);
tps_num_iters = squeeze(tps_num_iters(:,:,:,1));

% -------------------------------------------------------------------------

% STEP 8: save out data 

save([agg_dir filesep() 'tps_all_dist.mat'], 'tps_cos_dist', 'tps_num_iters', 'labels', 'tps_opts', 'pcts', 'dim_order')

% ========================================================================

%% NOISE DATA

% ========================================================================

disp('Working on Noise Data')

% STEP 1: set labels for dimension orders

noise_opts = [0.01, 0.05, 0.1, 0.5 1 5 10 50];

% -------------------------------------------------------------------------

% STEP 2: instantiate arrays

noise_cos_dist = NaN(length(noise_opts), 100, 10, num_metrics);

% -------------------------------------------------------------------------

% STEP 3: iterate over noise opts without node dropping

j=1;
for opt = noise_opts;
    i=1;
    for lett = 1:100
        lett_str = num2str(lett,'%03.f');
        wdir = [ns_dir filesep() num2str(opt) filesep() lett_str];
    
% -------------------------------------------------------------------------
    
% STEP 4: load data and assign to arrays 
        outdir = [wdir filesep() cosdst_flder];
        if exist([outdir filesep() 'cos_dist.mat'], 'file')
            %disp(['Missing: ' num2str(opt) ' ' lett_str])
        %else
            disp([num2str(opt) ' ' lett_str])

            % load data with function 
            [noise_cos_dist(j,lett,1,:), labels] = load_data(outdir);
        end
    end
    j = j+1;
end

% -------------------------------------------------------------------------

% STEP 7: get number of values in each group for visualization

noise_num_iters = sum(~isnan(noise_cos_dist),2);
noise_num_iters = squeeze(noise_num_iters(:,:,:,1));

% -------------------------------------------------------------------------

% STEP 8: save out data 

save([agg_dir filesep() 'noise_all_dist.mat'], 'noise_cos_dist', 'noise_num_iters', 'labels', 'noise_opts', 'pcts', 'dim_order')

% ========================================================================

%% Internal Functions

function [out_arr, lab_ord] = load_data(wdir)
    
    % load data array 
    load([wdir filesep() 'cos_dist.mat'])

    out_arr = zeros(1,1,1,10);

    out_arr(1) = cosdst_xc_biv;
    out_arr(2) = cosdst_xc_partial;
    out_arr(3) = cosdst_gc;
    out_arr(4) = cosdst_mi_biv;
    out_arr(5) = cosdst_te_bivar;
    out_arr(6) = cosdst_te_multivar;

    out_arr(7) = cosdst_xc_biv_zerolag;
    out_arr(8) = cosdst_xc_partial_zerolag;
    out_arr(9) = cosdst_mi_zerolag;
    out_arr(10) = cosdst_shuff;

    lab_ord = ["xc biv", "xc pt", "gc", "mi biv", "te bv", "te mv", "xc biv zerolag", "xc pt zerolag", "mi zerolag", "shuffle"];

end
