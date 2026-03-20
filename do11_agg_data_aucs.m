% =========================================================================

% Name:			do08_agg_data.m

% Author:		Kate Dembny
% Date:			3/15/2024
% Updated:		3/15/2024

% Syntax:		
% Arguments:	

% Description:	aggregate AUC data
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
agg_dir = [data_dir filesep() 'roc'];

if ~exist(agg_dir, 'dir')
    mkdir(agg_dir)
end

% ========================================================================

%% NODE DATA

% ========================================================================

disp('Working on Nodes Data')

% STEP 1: set option labels

nodes_opts = [10, 20, 30, 50, 65];

% -------------------------------------------------------------------------

% STEP 2: run analysis for ROC curve and save

[nodes_roc_aucs, nodes_roc_curves_x, nodes_roc_curves_y, lab_order, dim_order] = agg_auc_data(data_dir, 'nodes', nodes_opts, 'roc', true);

% get number of calues in each group for visualization
nodes_roc_num_iters = sum(~isnan(nodes_roc_aucs),2);
nodes_roc_num_iters = squeeze(nodes_roc_num_iters(:,:,:,1));

% save analysis
save([agg_dir filesep() 'nodes_roc.mat'], 'nodes_roc_aucs', 'nodes_roc_curves_x', 'nodes_roc_curves_y', 'nodes_roc_num_iters', 'lab_order', 'nodes_opts', 'dim_order')

% -------------------------------------------------------------------------

% STEP 3: run analysis for precision-recall curve and save 

[nodes_precrec_aucs, nodes_precrec_curves_x, nodes_precrec_curves_y, lab_order, dim_order] = agg_auc_data(data_dir, 'nodes', nodes_opts, 'prec_rec', true);

% get number of calues in each group for visualization
nodes_precrec_num_iters = sum(~isnan(nodes_precrec_aucs),2);
nodes_precrec_num_iters = squeeze(nodes_precrec_num_iters(:,:,:,1));

% save analysis
save([agg_dir filesep() 'nodes_precrec.mat'], 'nodes_precrec_aucs', 'nodes_precrec_curves_x', 'nodes_precrec_curves_y', 'nodes_precrec_num_iters', 'lab_order', 'nodes_opts', 'dim_order')

% ========================================================================

%% TIME POINT DATA

% ========================================================================

disp('Working on Time Point Data')

% STEP 1: set option labels

tps_opts = [500, 1000, 5000, 10000];

% -------------------------------------------------------------------------

% STEP 2: run analysis for ROC curve and save

[tps_roc_aucs, tps_roc_curves_x, tps_roc_curves_y, lab_order, dim_order] = agg_auc_data(data_dir, 'time_points', tps_opts, 'roc', false);

% get number of calues in each group for visualization
tps_roc_num_iters = sum(~isnan(tps_roc_aucs),2);
tps_roc_num_iters = squeeze(tps_roc_num_iters(:,:,:,1));

% save analysis
save([agg_dir filesep() 'tps_roc.mat'], 'tps_roc_aucs', 'tps_roc_curves_x', 'tps_roc_curves_y', 'tps_roc_num_iters', 'lab_order', 'tps_opts', 'dim_order')

% -------------------------------------------------------------------------

% STEP 3: run analysis for precision-recall curve and save 

[tps_precrec_aucs, tps_precrec_curves_x, tps_precrec_curves_y, lab_order, dim_order] = agg_auc_data(data_dir, 'time_points', tps_opts, 'prec_rec', false);

% get number of calues in each group for visualization
tps_precrec_num_iters = sum(~isnan(tps_precrec_aucs),2);
tps_precrec_num_iters = squeeze(tps_precrec_num_iters(:,:,:,1));

% save analysis
save([agg_dir filesep() 'tps_precrec.mat'], 'tps_precrec_aucs', 'tps_precrec_curves_x', 'tps_precrec_curves_y', 'tps_precrec_num_iters', 'lab_order', 'tps_opts', 'dim_order')

% ========================================================================

%% NOISE DATA

% ========================================================================

disp('Working on Noise Data')

% STEP 1: set option labels

noise_opts = [0.01, 0.05, 0.1, 0.5 1 5 10 50];

% -------------------------------------------------------------------------

% STEP 2: run analysis for ROC curve and save

[noise_roc_aucs, noise_roc_curves_x, noise_roc_curves_y, lab_order, dim_order] = agg_auc_data(data_dir, 'noise', noise_opts, 'roc', false);

% get number of values in each group for visualization
noise_roc_num_iters = sum(~isnan(noise_roc_aucs),2);
noise_roc_num_iters = squeeze(noise_roc_num_iters(:,:,:,1));

% save analysis
save([agg_dir filesep() 'noise_roc.mat'], 'noise_roc_aucs', 'noise_roc_curves_x', 'noise_roc_curves_y', 'noise_roc_num_iters', 'lab_order', 'noise_opts', 'dim_order')

% -------------------------------------------------------------------------

% STEP 3: run analysis for precision-recall curve and save 

[noise_precrec_aucs, noise_precrec_curves_x, noise_precrec_curves_y, lab_order, dim_order] = agg_auc_data(data_dir, 'noise', noise_opts, 'prec_rec', false);

% get number of calues in each group for visualization
noise_precrec_num_iters = sum(~isnan(noise_precrec_aucs),2);
noise_precrec_num_iters = squeeze(noise_precrec_num_iters(:,:,:,1));

% save analysis
save([agg_dir filesep() 'noise_precrec.mat'], 'noise_precrec_aucs', 'noise_precrec_curves_x', 'noise_precrec_curves_y', 'noise_precrec_num_iters', 'lab_order', 'noise_opts', 'dim_order')

% ========================================================================

%% REREFERNCING DATA

% ========================================================================

disp('Working on Re-Referencing Data')

% STEP 1: set option labels

reref_opts =  ["cmn_avg", "hrdwr_ref", "random"];

% -------------------------------------------------------------------------

% STEP 2: run analysis for ROC curve and save

[reref_roc_aucs, reref_roc_curves_x, reref_roc_curves_y, lab_order, dim_order] = agg_auc_data(data_dir, 'rereference', reref_opts, 'roc', false);

% get number of values in each group for visualization
reref_roc_num_iters = sum(~isnan(reref_roc_aucs),2);
reref_roc_num_iters = squeeze(reref_roc_num_iters(:,:,:,1));

% save analysis
save([agg_dir filesep() 'reref_roc.mat'], 'reref_roc_aucs', 'reref_roc_curves_x', 'reref_roc_curves_y', 'reref_roc_num_iters', 'lab_order', 'reref_opts', 'dim_order')

% -------------------------------------------------------------------------

% STEP 3: run analysis for precision-recall curve and save 

[reref_precrec_aucs, reref_precrec_curves_x, reref_precrec_curves_y, lab_order, dim_order] = agg_auc_data(data_dir, 'rereference', reref_opts, 'prec_rec', false);

% get number of calues in each group for visualization
reref_precrec_num_iters = sum(~isnan(reref_precrec_aucs),2);
reref_precrec_num_iters = squeeze(reref_precrec_num_iters(:,:,:,1));

% save analysis
save([agg_dir filesep() 'reref_precrec.mat'], 'reref_precrec_aucs', 'reref_precrec_curves_x', 'reref_precrec_curves_y', 'reref_precrec_num_iters', 'lab_order', 'reref_opts', 'dim_order')

%% ========================================================================

% LOCAL FUNCTIONS

function [aucs, curves_x, curves_y, lab_order, dim_order] = agg_auc_data(data_dir, method, opts, auc_type, drop_nodes)
    % instantiate array to hold AUCs

    lab_order = ["xc biv", "xc pt", "gc", "mi", "te bv", "te mv", "xc biv zerolag", "xc pt zerolag", "xc mi zerolag", "shuffled"];
    dim_order = ["opts", "iters", "drop_pct", "fc_metrics"];
    
    aucs = NaN(length(opts), 100, 10, size(lab_order,2));
    curves_x = NaN(length(opts), 100, 10, size(lab_order,2), 1001);
    curves_y = NaN(length(opts), 100, 10, size(lab_order,2), 1001); 

    j = 1; % flips up when we progress to next of opts
    % STEP 1: iterate through functions
    for opt = opts
        i=1;
        for lett = 1:100
            lett_st = num2str(lett,'%03.f');
            wdir = [data_dir filesep() method filesep() num2str(opt) filesep() lett_st];
        
    % STEP 2: load data and assign to arrays 
            foutdir = [data_dir filesep() 'roc'];
            indir = [wdir filesep() 'roc'];
            
            if strcmp(auc_type, 'roc')
                req_file = 'norm_roc4_vertavg.mat';
            elseif strcmp(auc_type, 'prec_rec')
                req_file = 'norm_precrec4_vertavg.mat';
            else
                error('Type of AUC file to retrive does not exist')
            end

            if exist([indir filesep() req_file], 'file')
                disp([num2str(opt) ' ' lett_st])
                
                % load auc files
                load([indir filesep() req_file])

                if strcmp(auc_type, 'roc')
                    
                    % assign AUC values to array for ROC curve
                    aucs(j,lett,1,1) = aucROC_xc_biv;
                    aucs(j,lett,1,2) = aucROC_xc_pt;
                    aucs(j,lett,1,3) = aucROC_gc;
                    aucs(j,lett,1,4) = aucROC_mi;
                    aucs(j,lett,1,5) = aucROC_te_biv;
                    aucs(j,lett,1,6) = aucROC_te_mv;
                    aucs(j,lett,1,7) = aucROC_xc_biv_zerolag;
                    aucs(j,lett,1,8) = aucROC_xc_pt_zerolag;
                    aucs(j,lett,1,9) = aucROC_mi_zerolag;
                    aucs(j,lett,1,10) = aucROC_shuff;

                    % assign curves for curve averaging on x-axis -- should all be identical 
                    curves_x(j,lett,1,1,:) = norm_xax_fpr_xc_biv;
                    curves_x(j,lett,1,2,:) = norm_xax_fpr_xc_pt;
                    curves_x(j,lett,1,3,:) = norm_xax_fpr_mi;
                    curves_x(j,lett,1,4,:) = norm_xax_fpr_gc;
                    curves_x(j,lett,1,5,:) = norm_xax_fpr_te_biv;
                    curves_x(j,lett,1,6,:) = norm_xax_fpr_te_mv;
                    curves_x(j,lett,1,7,:) = norm_xax_fpr_xc_biv_zerolag;
                    curves_x(j,lett,1,8,:) = norm_xax_fpr_xc_pt_zerolag;
                    curves_x(j,lett,1,9,:) = norm_xax_fpr_mi_zerolag;
                    curves_x(j,lett,1,10,:) = norm_xax_fpr_shuff;

                    % assign curves for curve averaging on y-axis
                    curves_y(j,lett,1,1,:) = norm_yax_tpr_xc_biv;
                    curves_y(j,lett,1,2,:) = norm_yax_tpr_xc_pt;
                    curves_y(j,lett,1,3,:) = norm_yax_tpr_gc;
                    curves_y(j,lett,1,4,:) = norm_yax_tpr_mi;
                    curves_y(j,lett,1,5,:) = norm_yax_tpr_te_biv;
                    curves_y(j,lett,1,6,:) = norm_yax_tpr_te_mv;
                    curves_y(j,lett,1,7,:) = norm_yax_tpr_xc_biv_zerolag;
                    curves_y(j,lett,1,8,:) = norm_yax_tpr_xc_pt_zerolag;
                    curves_y(j,lett,1,9,:) = norm_yax_tpr_mi_zerolag;
                    curves_y(j,lett,1,10,:) = norm_yax_tpr_shuff;

                elseif strcmp(auc_type, 'prec_rec')
                    % assign AUC values to array for prec rec curve
                    aucs(j,lett,1,1) = aucPR_xc_biv;
                    aucs(j,lett,1,2) = aucPR_xc_pt;
                    aucs(j,lett,1,3) = aucPR_gc;
                    aucs(j,lett,1,4) = aucPR_mi;
                    aucs(j,lett,1,5) = aucPR_te_biv;
                    aucs(j,lett,1,6) = aucPR_te_mv;
                    aucs(j,lett,1,7) = aucPR_xc_biv_zerolag;
                    aucs(j,lett,1,8) = aucPR_xc_pt_zerolag;
                    aucs(j,lett,1,9) = aucPR_mi_zerolag;
                    aucs(j,lett,1,10) = aucPR_shuff;

                    % assign curves for curve averaging on x-axis -- should all be identical 
                    curves_x(j,lett,1,1,:) = norm_xax_recall_xc_biv;
                    curves_x(j,lett,1,2,:) = norm_xax_recall_xc_pt;
                    curves_x(j,lett,1,3,:) = norm_xax_recall_mi;
                    curves_x(j,lett,1,4,:) = norm_xax_recall_gc;
                    curves_x(j,lett,1,5,:) = norm_xax_recall_te_biv;
                    curves_x(j,lett,1,6,:) = norm_xax_recall_te_mv;
                    curves_x(j,lett,1,7,:) = norm_xax_recall_xc_biv_zerolag;
                    curves_x(j,lett,1,8,:) = norm_xax_recall_xc_pt_zerolag;
                    curves_x(j,lett,1,9,:) = norm_xax_recall_mi_zerolag;
                    curves_x(j,lett,1,10,:) = norm_xax_recall_shuff;

                    % assign curves for curve averaging on y-axis
                    curves_y(j,lett,1,1,:) = norm_yax_precision_xc_biv;
                    curves_y(j,lett,1,2,:) = norm_yax_precision_xc_pt;
                    curves_y(j,lett,1,3,:) = norm_yax_precision_mi;
                    curves_y(j,lett,1,4,:) = norm_yax_precision_gc;
                    curves_y(j,lett,1,5,:) = norm_yax_precision_te_biv;
                    curves_y(j,lett,1,6,:) = norm_yax_precision_te_mv;
                    curves_y(j,lett,1,7,:) = norm_yax_precision_xc_biv_zerolag;
                    curves_y(j,lett,1,8,:) = norm_yax_precision_xc_pt_zerolag;
                    curves_y(j,lett,1,9,:) = norm_yax_precision_mi_zerolag;
                    curves_y(j,lett,1,10,:) = norm_yax_precision_shuff;
                end
            end

            if drop_nodes
                for drop = 1:9
                    drop_dir = [wdir filesep() 'drop_nodes' filesep() 'a' filesep() 'drop_' num2str(drop) '0pct'];
                    
                    indir = [drop_dir filesep() 'roc'];

                    if exist([indir filesep() req_file], 'file')
                        disp([num2str(opt) ' ' lett_st ' drop_' num2str(drop) '0pct'])
                        
                        % load auc files
                        load([indir filesep() req_file])
        
                        if strcmp(auc_type, 'roc')
                            
                            % assign AUC values to array for ROC curve
                            aucs(j,lett,drop,1) = aucROC_xc_biv;
                            aucs(j,lett,drop,2) = aucROC_xc_pt;
                            aucs(j,lett,drop,3) = aucROC_gc;
                            aucs(j,lett,drop,4) = aucROC_mi; 
                            aucs(j,lett,drop,5) = aucROC_te_biv;
                            aucs(j,lett,drop,6) = aucROC_te_mv;
                            aucs(j,lett,drop,7) = aucROC_xc_biv_zerolag;
                            aucs(j,lett,drop,8) = aucROC_xc_pt_zerolag;
                            aucs(j,lett,drop,9) = aucROC_mi_zerolag;
                            aucs(j,lett,drop,10) = aucROC_shuff;
        
                            % assign curves for curve averaging on x-axis -- should all be identical 
                            curves_x(j,lett,drop,1,:) = norm_xax_fpr_xc_biv;
                            curves_x(j,lett,drop,2,:) = norm_xax_fpr_xc_pt;
                            curves_x(j,lett,drop,3,:) = norm_xax_fpr_gc;
                            curves_x(j,lett,drop,4,:) = norm_xax_fpr_mi;
                            curves_x(j,lett,drop,5,:) = norm_xax_fpr_te_biv;
                            curves_x(j,lett,drop,6,:) = norm_xax_fpr_te_mv;
                            curves_x(j,lett,drop,7,:) = norm_xax_fpr_xc_biv_zerolag;
                            curves_x(j,lett,drop,8,:) = norm_xax_fpr_xc_pt_zerolag;
                            curves_x(j,lett,drop,9,:) = norm_xax_fpr_mi_zerolag;
                            curves_x(j,lett,drop,10,:) = norm_xax_fpr_shuff;
        
                            % assign curves for curve averaging on y-axis
                            curves_y(j,lett,drop,1,:) = norm_yax_tpr_xc_biv;
                            curves_y(j,lett,drop,2,:) = norm_yax_tpr_xc_pt;
                            curves_y(j,lett,drop,3,:) = norm_yax_tpr_gc;
                            curves_y(j,lett,drop,4,:) = norm_yax_tpr_mi;
                            curves_y(j,lett,drop,5,:) = norm_yax_tpr_te_biv;
                            curves_y(j,lett,drop,6,:) = norm_yax_tpr_te_mv;
                            curves_y(j,lett,drop,7,:) = norm_yax_tpr_xc_biv_zerolag;
                            curves_y(j,lett,drop,8,:) = norm_yax_tpr_xc_pt_zerolag;
                            curves_y(j,lett,drop,9,:) = norm_yax_tpr_mi_zerolag;
                            curves_y(j,lett,drop,10,:) = norm_yax_tpr_shuff;
        
                        elseif strcmp(auc_type, 'prec_rec')
                            % assign AUC values to array for pref rec curve
                            aucs(j,lett,drop,1) = aucPR_xc_biv;
                            aucs(j,lett,drop,2) = aucPR_xc_pt;
                            aucs(j,lett,drop,3) = aucPR_gc;
                            aucs(j,lett,drop,4) = aucPR_mi;
                            aucs(j,lett,drop,4) = aucPR_te_biv;
                            aucs(j,lett,drop,6) = aucPR_te_mv;
                            aucs(j,lett,drop,7) = aucPR_xc_biv_zerolag;
                            aucs(j,lett,drop,8) = aucPR_xc_pt_zerolag;
                            aucs(j,lett,drop,9) = aucPR_mi_zerolag;
                            aucs(j,lett,drop,10) = aucPR_shuff;
        
                            % assign curves for curve averaging on x-axis -- should all be identical 
                            curves_x(j,lett,drop,1,:) = norm_xax_recall_xc_biv;
                            curves_x(j,lett,drop,2,:) = norm_xax_recall_xc_pt;
                            curves_x(j,lett,drop,3,:) = norm_xax_recall_gc;
                            curves_x(j,lett,drop,4,:) = norm_xax_recall_mi;
                            curves_x(j,lett,drop,5,:) = norm_xax_recall_te_biv;
                            curves_x(j,lett,drop,6,:) = norm_xax_recall_te_mv;
                            curves_x(j,lett,drop,7,:) = norm_xax_recall_xc_biv_zerolag;
                            curves_x(j,lett,drop,8,:) = norm_xax_recall_xc_pt_zerolag;
                            curves_x(j,lett,drop,9,:) = norm_xax_recall_mi_zerolag;
                            curves_x(j,lett,drop,10,:) = norm_xax_recall_shuff;
        
                            % assign curves for curve averaging on y-axis
                            curves_y(j,lett,drop,1,:) = norm_yax_precision_xc_biv; 
                            curves_y(j,lett,drop,2,:) = norm_yax_precision_xc_pt;
                            curves_y(j,lett,drop,3,:) = norm_yax_precision_gc;
                            curves_y(j,lett,drop,4,:) = norm_yax_precision_mi;
                            curves_y(j,lett,drop,5,:) = norm_yax_precision_te_biv;
                            curves_y(j,lett,drop,6,:) = norm_yax_precision_te_mv;
                            curves_y(j,lett,drop,7,:) = norm_yax_precision_xc_biv_zerolag;
                            curves_y(j,lett,drop,8,:) = norm_yax_precision_xc_pt_zerolag;
                            curves_y(j,lett,drop,9,:) = norm_yax_precision_mi_zerolag;
                            curves_y(j,lett,drop,10,:) = norm_yax_precision_shuff;
                        end
                    end
                end
            end
        end
        j = j+1;
    end
end


               


