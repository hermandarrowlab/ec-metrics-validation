% =========================================================================

% Name:			do10_roc.m

% Author:		Kate Dembny
% Date:			3/14/24
% Updated:		3/18/24

% Syntax:		
% Arguments:	

% Description:	calculate ROC and performance recall curves for data,
%               including AUCs for both
% Requirements: matlab
% Notes:

%% ========================================================================
 
% DIRECTORIES 

clearvars 

scr_dir = pwd;
pdir = fileparts(cd);
data_dir = [pdir filesep() 'data'];
fig_dir = [pdir filesep() 'figures' filesep() 'prelim_figs'];

%nd_dir = [data_dir filesep() 'nodes'];
%tp_dir = [data_dir filesep() 'time_points'];
%ns_dir = [data_dir  filesep() 'noise'];
%rr_dir = [data_dir filesep() 'rereference'];
agg_dir = [data_dir filesep() 'agg'];

if ~exist(agg_dir, 'dir')
    mkdir(agg_dir)
end

addpath('/home/kdembny/MATLAB/toolboxes/cprintf/cprintf')

%% ========================================================================

% STEP 1: iterate through files 

for opt = "noise_awgnProblems" %["nodes", "time_points", "noise", "rereference"]
    % set base directory
    var_dir = [data_dir filesep() convertStringsToChars(opt)];

    if strcmp(opt,'nodes')
        cycle = ["10", "20", "30", "50", "65"];
    elseif strcmp(opt,'time_points')
        cycle = ["500", "1000", "5000", "10000", "50000"];
    elseif contains(opt,'noise')
        cycle = ["0.01", "0.05", "0.1", "0.5", "1", "5", "10", "50"];
    elseif strcmp(opt, 'rereference')
        cycle = ["cmn_avg", "hrdwr_ref", "random"];
    end

    % iterate folder for node dropping
    for nd = cycle
        for rep = 1:100 %1:10
    
            cwd = [var_dir filesep() convertStringsToChars(nd) filesep() num2str(rep,'%03.f')]; %num2str(nd)

            % make directory to store thresholded data
            if ~exist([cwd filesep() 'roc'], 'dir')
                mkdir([cwd filesep() 'roc'])
            end

            % if exist([cwd filesep() 'roc' filesep() 'curve_results.jpeg'])
            %     cprintf('blue', ['ROC/PrecRec Curves for ' convertStringsToChars(opt) ' = ' convertStringsToChars(nd) ' iter ' num2str(rep,'%03.f') ' already exists\n'])
            %     continue
            % end
            


% -------------------------------------------------------------------------

% STEP 2: load data

            if isfile([cwd filesep() 'orig' filesep() 'orig_data.mat']) && isfile([cwd filesep() 'ml_fc' filesep() 'gc.mat']) && isfile([cwd filesep() 'mvte' filesep() 'te_multivar.mat']) && isfile([cwd filesep() 'bvte' filesep() 'te_bivar.mat']) && isfile([cwd filesep() 'mi_lagged' filesep() 'mi_lagged.mat']) && isfile([cwd filesep() 'mi_zerolag' filesep() 'mi_zerolag.mat']) && isfile([cwd filesep() 'ml_fc' filesep() 'xc_zerolag_biv.mat']) && isfile([cwd filesep() 'ml_fc' filesep() 'xc_zerolag_pt.mat'])
                cprintf('blue', ['Calculating ROC/PrefRec Curves for ' convertStringsToChars(opt) ' = ' num2str(nd) ' iter ' num2str(rep,'%03.f') '\n'])
                cprintf('Loading Data \n')
                load([cwd filesep() 'orig' filesep() 'orig_data.mat'])
                load([cwd filesep() 'ml_fc' filesep() 'xc_biv.mat'])
                load([cwd filesep() 'ml_fc' filesep() 'xc_pt.mat'])
                load([cwd filesep() 'ml_fc' filesep() 'xc_zerolag_biv.mat'])
                load([cwd filesep() 'ml_fc' filesep() 'xc_zerolag_pt.mat'])
                load([cwd filesep() 'ml_fc' filesep() 'gc.mat'])

                load([cwd filesep() 'mi_lagged' filesep() 'mi_lagged.mat'])
                load([cwd filesep() 'mi_zerolag' filesep() 'mi_zerolag.mat'])
                load([cwd filesep() 'bvte' filesep() 'te_bivar.mat'])
                load([cwd filesep() 'mvte' filesep() 'te_multivar.mat'])

% -------------------------------------------------------------------------

% STEP 3: make all diagonals NaNs sos they're excluded from percentile calculations

                for i = 1:size(calc_mi_lag,1)
                    tcoup(i,i) = NaN;
                    xc_biv(i,i,1) = NaN;
                    xc_partial(i,i,1) = NaN;
                    xc_zerolag_biv(i,i) = NaN;
                    xc_zerolag_partial(i,i) = NaN;
                    gc(i,i) = NaN;
                    calc_mi_lag(i,i) = NaN;
                    calc_mi_zerolag(i,i) = NaN;
                    te_bivar(i,i) = NaN;
                    te_multivar(i,i) = NaN;
                end

                % pull just connectivity layer from the lagged XC metrics
                xc_biv = xc_biv(:,:,1);
                xc_partial = xc_partial(:,:,1);

                % generate random permutation vector
                flt_tcoup = tcoup(:);
                rand_shuff = flt_tcoup(randperm(length(flt_tcoup)));

% -------------------------------------------------------------------------

% STEP 4: run ROC calculations

                disp('Calculating ROC curves')
                [fpr_xc_biv, tpr_xc_biv, ~, aucROC_xc_biv] = perfcurve(tcoup(:), xc_biv(:), 1);
                [fpr_xc_pt, tpr_xc_pt, ~, aucROC_xc_pt] = perfcurve(tcoup(:), xc_partial(:), 1);
                [fpr_xc_biv_zerolag, tpr_xc_biv_zerolag, ~, aucROC_xc_biv_zerolag] = perfcurve(tcoup(:), xc_zerolag_biv(:), 1);
                [fpr_xc_pt_zerolag, tpr_xc_pt_zerolag, ~, aucROC_xc_pt_zerolag] = perfcurve(tcoup(:), xc_zerolag_partial(:), 1);
                [fpr_gc, tpr_gc, ~, aucROC_gc] = perfcurve(tcoup(:), gc(:), 1);
                [fpr_mi, tpr_mi, ~, aucROC_mi] = perfcurve(tcoup(:), calc_mi_lag(:), 1);
                [fpr_mi_zerolag, tpr_mi_zerolag, ~, aucROC_mi_zerolag] = perfcurve(tcoup(:), calc_mi_zerolag(:), 1);
                [fpr_te_biv, tpr_te_biv, ~, aucROC_te_biv] = perfcurve(tcoup(:), te_bivar(:), 1);
                [fpr_te_mv, tpr_te_mv, ~, aucROC_te_mv] = perfcurve(tcoup(:), te_multivar(:), 1);
                [fpr_shuff, tpr_shuff, ~, aucROC_shuff] = perfcurve(tcoup(:), rand_shuff, 1);

% -------------------------------------------------------------------------

% STEP 5: run precision/recall calculations 

                [recall_xc_biv, precision_xc_biv, ~, aucPR_xc_biv] = perfcurve(tcoup(:), xc_biv(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_xc_pt, precision_xc_pt, ~, aucPR_xc_pt] = perfcurve(tcoup(:), xc_partial(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_xc_biv_zerolag, precision_xc_biv_zerolag, ~, aucPR_xc_biv_zerolag] = perfcurve(tcoup(:), xc_zerolag_biv(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_xc_pt_zerolag, precision_xc_pt_zerolag, ~, aucPR_xc_pt_zerolag] = perfcurve(tcoup(:), xc_zerolag_partial(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_gc, precision_gc, ~, aucPR_gc] = perfcurve(tcoup(:), gc(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_mi, precision_mi, ~, aucPR_mi] = perfcurve(tcoup(:), calc_mi_lag(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_mi_zerolag, precision_mi_zerolag, ~, aucPR_mi_zerolag] = perfcurve(tcoup(:), calc_mi_zerolag(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_te_biv, precision_te_biv, ~, aucPR_te_biv] = perfcurve(tcoup(:), te_bivar(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_te_mv, precision_te_mv, ~, aucPR_te_mv] = perfcurve(tcoup(:), te_multivar(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                [recall_shuff, precision_shuff, ~, aucPR_shuff] = perfcurve(tcoup(:), rand_shuff, 1, 'XCrit', 'reca', 'YCrit', 'prec');

% -------------------------------------------------------------------------

% STEP 6: set up vertical averaging for ROC curves
                
                [norm_xax_fpr_xc_biv, norm_yax_tpr_xc_biv] = prep4vertAvg(fpr_xc_biv, tpr_xc_biv);
                [norm_xax_fpr_xc_pt, norm_yax_tpr_xc_pt] = prep4vertAvg(fpr_xc_pt, tpr_xc_pt);
                [norm_xax_fpr_xc_biv_zerolag, norm_yax_tpr_xc_biv_zerolag] = prep4vertAvg(fpr_xc_biv_zerolag, tpr_xc_biv_zerolag);
                [norm_xax_fpr_xc_pt_zerolag, norm_yax_tpr_xc_pt_zerolag] = prep4vertAvg(fpr_xc_biv, tpr_xc_biv);
                [norm_xax_fpr_gc, norm_yax_tpr_gc] = prep4vertAvg(fpr_gc, tpr_gc);
                [norm_xax_fpr_mi, norm_yax_tpr_mi] = prep4vertAvg(fpr_mi, tpr_mi);
                [norm_xax_fpr_mi_zerolag, norm_yax_tpr_mi_zerolag] = prep4vertAvg(fpr_mi_zerolag, tpr_mi_zerolag);
                [norm_xax_fpr_te_biv, norm_yax_tpr_te_biv] = prep4vertAvg(fpr_te_biv, tpr_te_biv);
                [norm_xax_fpr_te_mv, norm_yax_tpr_te_mv] = prep4vertAvg(fpr_te_mv, tpr_te_mv);
                [norm_xax_fpr_shuff, norm_yax_tpr_shuff] = prep4vertAvg(fpr_shuff, tpr_shuff);

% -------------------------------------------------------------------------

% STEP 7: set up vertical averaging for precision/recall curves
                
                [norm_xax_recall_xc_biv, norm_yax_precision_xc_biv] = prep4vertAvg(recall_xc_biv, precision_xc_biv);
                [norm_xax_recall_xc_pt, norm_yax_precision_xc_pt] = prep4vertAvg(recall_xc_pt, precision_xc_pt);
                [norm_xax_recall_xc_biv_zerolag, norm_yax_precision_xc_biv_zerolag] = prep4vertAvg(recall_xc_biv_zerolag, precision_xc_biv_zerolag);
                [norm_xax_recall_xc_pt_zerolag, norm_yax_precision_xc_pt_zerolag] = prep4vertAvg(recall_xc_biv, precision_xc_biv);
                [norm_xax_recall_gc, norm_yax_precision_gc] = prep4vertAvg(recall_gc, precision_gc);
                [norm_xax_recall_mi, norm_yax_precision_mi] = prep4vertAvg(recall_mi, precision_mi);
                [norm_xax_recall_mi_zerolag, norm_yax_precision_mi_zerolag] = prep4vertAvg(recall_mi_zerolag, precision_mi_zerolag);
                [norm_xax_recall_te_biv, norm_yax_precision_te_biv] = prep4vertAvg(recall_te_biv, precision_te_biv);
                % run for TE - set up to fix specific interpolation error when TE finds no true connections in data
                try
                    [norm_xax_recall_te_mv, norm_yax_precision_te_mv] = prep4vertAvg(recall_te_mv, precision_te_mv);
                catch ME
                    if size(precision_te_mv,1) == 2 && sum(isnan(precision_te_mv)) == 1
                        precision_te_mv(isnan(precision_te_mv)) = 0;
                        [norm_xax_recall_te_mv, norm_yax_precision_te_mv] = prep4vertAvg(recall_te_mv, precision_te_mv);
                    else
                        error(getReport(ME, 'extended'));
                    end
                end

                [norm_xax_recall_shuff, norm_yax_precision_shuff] = prep4vertAvg(recall_shuff, precision_shuff);
                
% -------------------------------------------------------------------------

% STEP 8: Save out results

                save([cwd filesep() 'roc' filesep() 'roc.mat'], 'fpr_xc_biv', 'fpr_xc_pt', 'fpr_xc_biv_zerolag', 'fpr_xc_pt_zerolag', 'fpr_gc' , 'fpr_mi' , 'fpr_mi_zerolag' , 'fpr_te_mv', 'fpr_te_biv', 'fpr_shuff', 'tpr_xc_biv', 'tpr_xc_pt', 'tpr_xc_biv_zerolag', 'tpr_xc_pt_zerolag', 'tpr_gc', 'tpr_mi', 'tpr_mi_zerolag', 'tpr_te_mv', 'tpr_te_biv', 'tpr_shuff', 'aucROC_xc_biv', 'aucROC_xc_pt', 'aucROC_xc_biv_zerolag', 'aucROC_xc_pt_zerolag', 'aucROC_gc', 'aucROC_mi', 'aucROC_mi_zerolag', 'aucROC_te_mv', 'aucROC_te_biv', 'aucROC_shuff', 'rand_shuff')
                save([cwd filesep() 'roc' filesep() 'precrec_curve.mat'], 'recall_xc_biv', 'recall_xc_pt', 'recall_xc_biv_zerolag', 'recall_xc_pt_zerolag', 'recall_gc' , 'recall_mi' , 'recall_mi_zerolag' , 'recall_te_mv', 'recall_te_biv', 'recall_shuff', 'precision_xc_biv', 'precision_xc_pt', 'precision_xc_biv_zerolag', 'precision_xc_pt_zerolag', 'precision_gc', 'precision_mi', 'precision_mi_zerolag', 'precision_te_mv', 'precision_te_biv', 'precision_shuff', 'aucPR_xc_biv', 'aucPR_xc_pt', 'aucPR_xc_biv_zerolag', 'aucPR_xc_pt_zerolag', 'aucPR_gc', 'aucPR_mi', 'aucPR_mi_zerolag', 'aucPR_te_mv', 'aucPR_te_biv', 'aucPR_shuff', 'rand_shuff')
                save([cwd filesep() 'roc' filesep() 'norm_roc4_vertavg.mat'], 'norm_xax_fpr_xc_biv', 'norm_xax_fpr_xc_pt', 'norm_xax_fpr_xc_biv_zerolag', 'norm_xax_fpr_xc_pt_zerolag', 'norm_xax_fpr_gc' , 'norm_xax_fpr_mi' , 'norm_xax_fpr_mi_zerolag' , 'norm_xax_fpr_te_mv', 'norm_xax_fpr_te_biv', 'norm_xax_fpr_shuff', 'norm_yax_tpr_xc_biv', 'norm_yax_tpr_xc_pt', 'norm_yax_tpr_xc_biv_zerolag', 'norm_yax_tpr_xc_pt_zerolag', 'norm_yax_tpr_gc', 'norm_yax_tpr_mi', 'norm_yax_tpr_mi_zerolag', 'norm_yax_tpr_te_mv', 'norm_yax_tpr_te_biv', 'norm_yax_tpr_shuff', 'aucROC_xc_biv', 'aucROC_xc_pt', 'aucROC_xc_biv_zerolag', 'aucROC_xc_pt_zerolag', 'aucROC_gc', 'aucROC_mi', 'aucROC_mi_zerolag', 'aucROC_te_mv', 'aucROC_te_biv', 'aucROC_shuff')
                save([cwd filesep() 'roc' filesep() 'norm_precrec4_vertavg.mat'], 'norm_xax_recall_xc_biv', 'norm_xax_recall_xc_pt', 'norm_xax_recall_xc_biv_zerolag', 'norm_xax_recall_xc_pt_zerolag', 'norm_xax_recall_gc' , 'norm_xax_recall_mi' , 'norm_xax_recall_mi_zerolag' , 'norm_xax_recall_te_mv', 'norm_xax_recall_te_biv', 'norm_xax_recall_shuff', 'norm_yax_precision_xc_biv', 'norm_yax_precision_xc_pt', 'norm_yax_precision_xc_biv_zerolag', 'norm_yax_precision_xc_pt_zerolag', 'norm_yax_precision_gc', 'norm_yax_precision_mi', 'norm_yax_precision_mi_zerolag', 'norm_yax_precision_te_mv', 'norm_yax_precision_te_biv', 'norm_yax_precision_shuff', 'aucPR_xc_biv', 'aucPR_xc_pt', 'aucPR_xc_biv_zerolag', 'aucPR_xc_pt_zerolag', 'aucPR_gc', 'aucPR_mi', 'aucPR_mi_zerolag', 'aucPR_te_mv', 'aucPR_te_biv', 'aucPR_shuff')

% -------------------------------------------------------------------------

% STEP 9: Plot ROC and precision/recall curves

                f = figure(1);
                clf
                f.Position = [100 100 1400 600];

                subplot(121)
                hold on
                plot(fpr_xc_biv, tpr_xc_biv)
                plot(fpr_xc_pt, tpr_xc_pt)
                plot(fpr_xc_biv_zerolag, tpr_xc_biv_zerolag)
                plot(fpr_xc_pt_zerolag, tpr_xc_pt_zerolag)
                plot(fpr_gc, tpr_gc)
                plot(fpr_mi, tpr_mi)
                plot(fpr_mi_zerolag, tpr_mi_zerolag)
                plot(fpr_te_biv, tpr_te_biv)
                plot(fpr_te_mv, tpr_te_mv)
                plot(fpr_shuff, tpr_shuff)
                xlabel('False Positive Rate')
                ylabel('True Positive Rate')
                title('ROC')
                legend(['XC BIV - AUC = ' num2str(aucROC_xc_biv)], ['XC PT - AUC = ' num2str(aucROC_xc_pt)], ['XC BIV zerolag - AUC = ' num2str(aucROC_xc_biv_zerolag)], ['XC PT zerolag - AUC = ' num2str(aucROC_xc_pt_zerolag)], ['GC - AUC = ' num2str(aucROC_gc)], ['MI- AUC = ' num2str(aucROC_mi)], ['MI zerolag - AUC = ' num2str(aucROC_mi_zerolag)], ['BVTE - AUC = ' num2str(aucROC_te_biv)], ['MVTE - AUC = ' num2str(aucROC_te_mv)], ['Rand Shuffle - AUC = ' num2str(aucROC_shuff)], 'Location', 'southeast')

                subplot(122)
                hold on
                plot(recall_xc_biv, precision_xc_biv)
                plot(recall_xc_pt, precision_xc_pt)
                plot(recall_xc_biv_zerolag, precision_xc_biv_zerolag)
                plot(recall_xc_pt_zerolag, precision_xc_pt_zerolag)
                plot(recall_gc, precision_gc)
                plot(recall_mi, precision_mi)
                plot(recall_mi_zerolag, precision_mi_zerolag)
                plot(recall_te_biv, precision_te_biv)
                plot(recall_te_mv, precision_te_mv)
                plot(recall_shuff, precision_shuff)
                xlabel('Recall')
                ylabel('Precision')
                title('Precision Recall Curve')

                legend(['XC BIV - AUC = ' num2str(aucPR_xc_biv)], ['XC PT - AUC = ' num2str(aucPR_xc_pt)], ['XC BIV zerolag - AUC = ' num2str(aucPR_xc_biv_zerolag)], ['XC PT zerolag - AUC = ' num2str(aucPR_xc_pt_zerolag)], ['GC - AUC = ' num2str(aucPR_gc)], ['MI- AUC = ' num2str(aucPR_mi)], ['MI zerolag - AUC = ' num2str(aucPR_mi_zerolag)], ['BVTE - AUC = ' num2str(aucPR_te_biv)], ['MVTE - AUC = ' num2str(aucPR_te_mv)], ['Rand Shuffle - AUC = ' num2str(aucPR_shuff)])
                
                saveas(gcf, [cwd filesep() 'roc' filesep() 'curve_results.jpeg'])

            end
        end
    end
end

%% ========================================================================

% FOR NODE DROPPING

%% ========================================================================


% STEP 1: iterate through files 

for opt = ["nodes"] %, "time_points", "noise", "rereference"]
    % set base directory
    var_dir = [data_dir filesep() convertStringsToChars(opt)];

    if strcmp(opt,'nodes')
        cycle = ["50"]; %["10", "20", "30", "50", "65"];
    elseif strcmp(opt,'time_points')
        cycle = ["500", "1000", "5000", "10000", "50000"];
    elseif strcmp(opt,'noise')
        cycle = ["0.001", "0.005", "0.01", "0.05", "0.1", "0.5"];
    elseif strcmp(opt, 'rereference')
        cycle = ["cmn_avg", "hrdwr_ref", "random"];
    end

    % iterate folder for node dropping
    for nd = cycle
        for rep = 1:100 %1:10
            for drop_pct = 10:10:90

                if strcmp(nd, "10") && drop_pct >= 50
                    continue
                end

                if strcmp(nd, "10") && rep == 3 && drop_pct == 50
                    continue
                end
    
                cwd = [var_dir filesep() convertStringsToChars(nd) filesep() num2str(rep,'%03.f') filesep() 'drop_nodes' filesep() 'a' filesep() 'drop_' num2str(drop_pct) 'pct']; %num2str(nd)
    
                % make directory to store thresholded data
                if ~exist([cwd filesep() 'roc'], 'dir')
                    mkdir([cwd filesep() 'roc'])
                end
    
                if exist([cwd filesep() 'roc' filesep() 'curve_results.jpeg'])
                    cprintf('blue', ['ROC/PrefRec Curves for ' convertStringsToChars(opt) ' = ' convertStringsToChars(nd) ' iter ' num2str(rep,'%03.f') filesep() 'drop_nodes' filesep() 'a' filesep() 'drop_' num2str(drop_pct) 'pct already exists\n'])
                    continue
                end
    
    % -------------------------------------------------------------------------
    
    % STEP 2: load data
    
                if isfile([cwd filesep() 'ml_fc' filesep() 'gc.mat']) && isfile([cwd filesep() 'mvte' filesep() 'te_multivar.mat']) && isfile([cwd filesep() 'bvte' filesep() 'te_bivar.mat']) && isfile([cwd filesep() 'mi_lagged' filesep() 'mi_lagged.mat']) && isfile([cwd filesep() 'mi_zerolag' filesep() 'mi_zerolag.mat']) && isfile([cwd filesep() 'ml_fc' filesep() 'xc_zerolag_biv.mat']) && isfile([cwd filesep() 'ml_fc' filesep() 'xc_zerolag_pt.mat'])
                    cprintf('blue', ['Calculating ROC/PrefRec Curves for ' convertStringsToChars(opt) ' = ' num2str(nd) ' iter ' num2str(rep,'%03.f') filesep() 'drop_nodes' filesep() 'a' filesep() 'drop_' num2str(drop_pct) 'pct \n'])
                    cprintf('Loading Data \n')
                    load([cwd filesep() 'orig' filesep() 'orig_data.mat'])
                    load([cwd filesep() 'ml_fc' filesep() 'xc_biv.mat'])
                    load([cwd filesep() 'ml_fc' filesep() 'xc_pt.mat'])
                    load([cwd filesep() 'ml_fc' filesep() 'xc_zerolag_biv.mat'])
                    load([cwd filesep() 'ml_fc' filesep() 'xc_zerolag_pt.mat'])
                    load([cwd filesep() 'ml_fc' filesep() 'gc.mat'])
    
                    load([cwd filesep() 'mi_lagged' filesep() 'mi_lagged.mat'])
                    load([cwd filesep() 'mi_zerolag' filesep() 'mi_zerolag.mat'])
                    load([cwd filesep() 'bvte' filesep() 'te_bivar.mat'])
                    load([cwd filesep() 'mvte' filesep() 'te_multivar.mat'])
    
    % -------------------------------------------------------------------------
    
    % STEP 3: make all diagonals NaNs sos they're excluded from percentile calculations
    
                    for i = 1:size(calc_mi_lag,1)
                        tcoup(i,i) = NaN;
                        xc_biv(i,i,1) = NaN;
                        xc_partial(i,i,1) = NaN;
                        xc_zerolag_biv(i,i) = NaN;
                        xc_zerolag_partial(i,i) = NaN;
                        gc(i,i) = NaN;
                        calc_mi_lag(i,i) = NaN;
                        calc_mi_zerolag(i,i) = NaN;
                        te_bivar(i,i) = NaN;
                        te_multivar(i,i) = NaN;
                    end
    
                    % pull just connectivity layer from the lagged XC metrics
                    xc_biv = xc_biv(:,:,1);
                    xc_partial = xc_partial(:,:,1);
    
                    % generate random permutation vector
                    flt_tcoup = tcoup(:);
                    rand_shuff = flt_tcoup(randperm(length(flt_tcoup)));
    
    % -------------------------------------------------------------------------
    
    % STEP 4: run ROC calculations
    
                    if sum(tcoup, 'all', 'omitnan') > 1
                        disp('Calculating ROC curves')
                        [fpr_xc_biv, tpr_xc_biv, ~, aucROC_xc_biv] = perfcurve(tcoup(:), xc_biv(:), 1);
                        [fpr_xc_pt, tpr_xc_pt, ~, aucROC_xc_pt] = perfcurve(tcoup(:), xc_partial(:), 1);
                        [fpr_xc_biv_zerolag, tpr_xc_biv_zerolag, ~, aucROC_xc_biv_zerolag] = perfcurve(tcoup(:), xc_zerolag_biv(:), 1);
                        [fpr_xc_pt_zerolag, tpr_xc_pt_zerolag, ~, aucROC_xc_pt_zerolag] = perfcurve(tcoup(:), xc_zerolag_partial(:), 1);
                        [fpr_gc, tpr_gc, ~, aucROC_gc] = perfcurve(tcoup(:), gc(:), 1);
                        [fpr_mi, tpr_mi, ~, aucROC_mi] = perfcurve(tcoup(:), calc_mi_lag(:), 1);
                        [fpr_mi_zerolag, tpr_mi_zerolag, ~, aucROC_mi_zerolag] = perfcurve(tcoup(:), calc_mi_zerolag(:), 1);
                        [fpr_te_biv, tpr_te_biv, ~, aucROC_te_biv] = perfcurve(tcoup(:), te_bivar(:), 1);
                        [fpr_te_mv, tpr_te_mv, ~, aucROC_te_mv] = perfcurve(tcoup(:), te_multivar(:), 1);
                        [fpr_shuff, tpr_shuff, ~, aucROC_shuff] = perfcurve(tcoup(:), rand_shuff, 1);
    
    % -------------------------------------------------------------------------
    
    % STEP 5: run precision/recall calculations 
    
                        [recall_xc_biv, precision_xc_biv, ~, aucPR_xc_biv] = perfcurve(tcoup(:), xc_biv(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_xc_pt, precision_xc_pt, ~, aucPR_xc_pt] = perfcurve(tcoup(:), xc_partial(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_xc_biv_zerolag, precision_xc_biv_zerolag, ~, aucPR_xc_biv_zerolag] = perfcurve(tcoup(:), xc_zerolag_biv(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_xc_pt_zerolag, precision_xc_pt_zerolag, ~, aucPR_xc_pt_zerolag] = perfcurve(tcoup(:), xc_zerolag_partial(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_gc, precision_gc, ~, aucPR_gc] = perfcurve(tcoup(:), gc(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_mi, precision_mi, ~, aucPR_mi] = perfcurve(tcoup(:), calc_mi_lag(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_mi_zerolag, precision_mi_zerolag, ~, aucPR_mi_zerolag] = perfcurve(tcoup(:), calc_mi_zerolag(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_te_biv, precision_te_biv, ~, aucPR_te_biv] = perfcurve(tcoup(:), te_bivar(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_te_mv, precision_te_mv, ~, aucPR_te_mv] = perfcurve(tcoup(:), te_multivar(:), 1, 'XCrit', 'reca', 'YCrit', 'prec');
                        [recall_shuff, precision_shuff, ~, aucPR_shuff] = perfcurve(tcoup(:), rand_shuff, 1, 'XCrit', 'reca', 'YCrit', 'prec');
        
    % -------------------------------------------------------------------------
    
    % STEP 6: set up vertical averaging for ROC curves
                    
                        [norm_xax_fpr_xc_biv, norm_yax_tpr_xc_biv] = prep4vertAvg(fpr_xc_biv, tpr_xc_biv);
                        [norm_xax_fpr_xc_pt, norm_yax_tpr_xc_pt] = prep4vertAvg(fpr_xc_pt, tpr_xc_pt);
                        [norm_xax_fpr_xc_biv_zerolag, norm_yax_tpr_xc_biv_zerolag] = prep4vertAvg(fpr_xc_biv_zerolag, tpr_xc_biv_zerolag);
                        [norm_xax_fpr_xc_pt_zerolag, norm_yax_tpr_xc_pt_zerolag] = prep4vertAvg(fpr_xc_biv, tpr_xc_biv);
                        [norm_xax_fpr_gc, norm_yax_tpr_gc] = prep4vertAvg(fpr_gc, tpr_gc);
                        [norm_xax_fpr_mi, norm_yax_tpr_mi] = prep4vertAvg(fpr_mi, tpr_mi);
                        [norm_xax_fpr_mi_zerolag, norm_yax_tpr_mi_zerolag] = prep4vertAvg(fpr_mi_zerolag, tpr_mi_zerolag);
                        [norm_xax_fpr_te_biv, norm_yax_tpr_te_biv] = prep4vertAvg(fpr_te_biv, tpr_te_biv);
                        [norm_xax_fpr_te_mv, norm_yax_tpr_te_mv] = prep4vertAvg(fpr_te_mv, tpr_te_mv);
                        [norm_xax_fpr_shuff, norm_yax_tpr_shuff] = prep4vertAvg(fpr_shuff, tpr_shuff);
        
    % -------------------------------------------------------------------------
    
    % STEP 7: set up vertical averaging for precision/recall curves
                    
                        % [norm_xax_recall_xc_biv, norm_yax_precision_xc_biv] = prep4vertAvg(recall_xc_biv, precision_xc_biv);
                        % [norm_xax_recall_xc_pt, norm_yax_precision_xc_pt] = prep4vertAvg(recall_xc_pt, precision_xc_pt);
                        % [norm_xax_recall_xc_biv_zerolag, norm_yax_precision_xc_biv_zerolag] = prep4vertAvg(recall_xc_biv_zerolag, precision_xc_biv_zerolag);
                        % [norm_xax_recall_xc_pt_zerolag, norm_yax_precision_xc_pt_zerolag] = prep4vertAvg(recall_xc_biv, precision_xc_biv);
                        % [norm_xax_recall_gc, norm_yax_precision_gc] = prep4vertAvg(recall_gc, precision_gc);
                        % [norm_xax_recall_mi, norm_yax_precision_mi] = prep4vertAvg(recall_mi, precision_mi);
                        % [norm_xax_recall_mi_zerolag, norm_yax_precision_mi_zerolag] = prep4vertAvg(recall_mi_zerolag, precision_mi_zerolag);
                        % [norm_xax_recall_te_biv, norm_yax_precision_te_biv] = prep4vertAvg(recall_te_biv, precision_te_biv);
                        % % run for TE - set up to fix specific interpolation error when TE finds no true connections in data
                        % try
                        %     [norm_xax_recall_te_mv, norm_yax_precision_te_mv] = prep4vertAvg(recall_te_mv, precision_te_mv);
                        % catch ME
                        %     if size(precision_te_mv,1) == 2 && sum(isnan(precision_te_mv)) == 1
                        %         precision_te_mv(isnan(precision_te_mv)) = 0;
                        %         [norm_xax_recall_te_mv, norm_yax_precision_te_mv] = prep4vertAvg(recall_te_mv, precision_te_mv);
                        %     else
                        %         error(getReport(ME, 'extended'));
                        %     end
                        % end
                        % 
                        % [norm_xax_recall_shuff, norm_yax_precision_shuff] = prep4vertAvg(recall_shuff, precision_shuff);
                        % 
    % -------------------------------------------------------------------------
    
    % STEP 8: Save out results
    
                        save([cwd filesep() 'roc' filesep() 'roc.mat'], 'fpr_xc_biv', 'fpr_xc_pt', 'fpr_xc_biv_zerolag', 'fpr_xc_pt_zerolag', 'fpr_gc' , 'fpr_mi' , 'fpr_mi_zerolag' , 'fpr_te_mv', 'fpr_te_biv', 'fpr_shuff', 'tpr_xc_biv', 'tpr_xc_pt', 'tpr_xc_biv_zerolag', 'tpr_xc_pt_zerolag', 'tpr_gc', 'tpr_mi', 'tpr_mi_zerolag', 'tpr_te_mv', 'tpr_te_biv', 'tpr_shuff', 'aucROC_xc_biv', 'aucROC_xc_pt', 'aucROC_xc_biv_zerolag', 'aucROC_xc_pt_zerolag', 'aucROC_gc', 'aucROC_mi', 'aucROC_mi_zerolag', 'aucROC_te_mv', 'aucROC_te_biv', 'aucROC_shuff', 'rand_shuff')
                        save([cwd filesep() 'roc' filesep() 'prec_rec_curve.mat'], 'recall_xc_biv', 'recall_xc_pt', 'recall_xc_biv_zerolag', 'recall_xc_pt_zerolag', 'recall_gc' , 'recall_mi' , 'recall_mi_zerolag' , 'recall_te_mv', 'recall_te_biv', 'recall_shuff', 'precision_xc_biv', 'precision_xc_pt', 'precision_xc_biv_zerolag', 'precision_xc_pt_zerolag', 'precision_gc', 'precision_mi', 'precision_mi_zerolag', 'precision_te_mv', 'precision_te_biv', 'precision_shuff', 'aucPR_xc_biv', 'aucPR_xc_pt', 'aucPR_xc_biv_zerolag', 'aucPR_xc_pt_zerolag', 'aucPR_gc', 'aucPR_mi', 'aucPR_mi_zerolag', 'aucPR_te_mv', 'aucPR_te_biv', 'aucPR_shuff', 'rand_shuff')
                        save([cwd filesep() 'roc' filesep() 'norm_roc4_vertavg.mat'], 'norm_xax_fpr_xc_biv', 'norm_xax_fpr_xc_pt', 'norm_xax_fpr_xc_biv_zerolag', 'norm_xax_fpr_xc_pt_zerolag', 'norm_xax_fpr_gc' , 'norm_xax_fpr_mi' , 'norm_xax_fpr_mi_zerolag' , 'norm_xax_fpr_te_mv', 'norm_xax_fpr_te_biv', 'norm_xax_fpr_shuff', 'norm_yax_tpr_xc_biv', 'norm_yax_tpr_xc_pt', 'norm_yax_tpr_xc_biv_zerolag', 'norm_yax_tpr_xc_pt_zerolag', 'norm_yax_tpr_gc', 'norm_yax_tpr_mi', 'norm_yax_tpr_mi_zerolag', 'norm_yax_tpr_te_mv', 'norm_yax_tpr_te_biv', 'norm_yax_tpr_shuff', 'aucROC_xc_biv', 'aucROC_xc_pt', 'aucROC_xc_biv_zerolag', 'aucROC_xc_pt_zerolag', 'aucROC_gc', 'aucROC_mi', 'aucROC_mi_zerolag', 'aucROC_te_mv', 'aucROC_te_biv', 'aucROC_shuff')
                        %save([cwd filesep() 'roc' filesep() 'norm_precrec4_vertavg.mat'], 'norm_xax_recall_xc_biv', 'norm_xax_recall_xc_pt', 'norm_xax_recall_xc_biv_zerolag', 'norm_xax_recall_xc_pt_zerolag', 'norm_xax_recall_gc' , 'norm_xax_recall_mi' , 'norm_xax_recall_mi_zerolag' , 'norm_xax_recall_te_mv', 'norm_xax_recall_te_biv', 'norm_xax_recall_shuff', 'norm_yax_precision_xc_biv', 'norm_yax_precision_xc_pt', 'norm_yax_precision_xc_biv_zerolag', 'norm_yax_precision_xc_pt_zerolag', 'norm_yax_precision_gc', 'norm_yax_precision_mi', 'norm_yax_precision_mi_zerolag', 'norm_yax_precision_te_mv', 'norm_yax_precision_te_biv', 'norm_yax_precision_shuff', 'aucPR_xc_biv', 'aucPR_xc_pt', 'aucPR_xc_biv_zerolag', 'aucPR_xc_pt_zerolag', 'aucPR_gc', 'aucPR_mi', 'aucPR_mi_zerolag', 'aucPR_te_mv', 'aucPR_te_biv', 'aucPR_shuff')
                    else
                        disp('Error: no positive connections. Skipping')
                        continue
                    end
    
    % -------------------------------------------------------------------------
    
    % STEP 9: Plot ROC and precision/recall curves
    
                    f = figure(1);
                    clf
                    f.Position = [100 100 1400 600];
    
                    subplot(121)
                    hold on
                    plot(fpr_xc_biv, tpr_xc_biv)
                    plot(fpr_xc_pt, tpr_xc_pt)
                    plot(fpr_xc_biv_zerolag, tpr_xc_biv_zerolag)
                    plot(fpr_xc_pt_zerolag, tpr_xc_pt_zerolag)
                    plot(fpr_gc, tpr_gc)
                    plot(fpr_mi, tpr_mi)
                    plot(fpr_mi_zerolag, tpr_mi_zerolag)
                    plot(fpr_te_biv, tpr_te_biv)
                    plot(fpr_te_mv, tpr_te_mv)
                    plot(fpr_shuff, tpr_shuff)
                    xlabel('False Positive Rate')
                    ylabel('True Positive Rate')
                    title('ROC')
                    legend(['XC BIV - AUC = ' num2str(aucROC_xc_biv)], ['XC PT - AUC = ' num2str(aucROC_xc_pt)], ['XC BIV zerolag - AUC = ' num2str(aucROC_xc_biv_zerolag)], ['XC PT zerolag - AUC = ' num2str(aucROC_xc_pt_zerolag)], ['GC - AUC = ' num2str(aucROC_gc)], ['MI- AUC = ' num2str(aucROC_mi)], ['MI zerolag - AUC = ' num2str(aucROC_mi_zerolag)], ['BVTE - AUC = ' num2str(aucROC_te_biv)], ['MVTE - AUC = ' num2str(aucROC_te_mv)], ['Rand Shuffle - AUC = ' num2str(aucROC_shuff)], 'Location', 'southeast')
    
                    subplot(122)
                    hold on
                    plot(recall_xc_biv, precision_xc_biv)
                    plot(recall_xc_pt, precision_xc_pt)
                    plot(recall_xc_biv_zerolag, precision_xc_biv_zerolag)
                    plot(recall_xc_pt_zerolag, precision_xc_pt_zerolag)
                    plot(recall_gc, precision_gc)
                    plot(recall_mi, precision_mi)
                    plot(recall_mi_zerolag, precision_mi_zerolag)
                    plot(recall_te_biv, precision_te_biv)
                    plot(recall_te_mv, precision_te_mv)
                    plot(recall_shuff, precision_shuff)
                    xlabel('Recall')
                    ylabel('Precision')
                    title('Precision Recall Curve')
    
                    legend(['XC BIV - AUC = ' num2str(aucPR_xc_biv)], ['XC PT - AUC = ' num2str(aucPR_xc_pt)], ['XC BIV zerolag - AUC = ' num2str(aucPR_xc_biv_zerolag)], ['XC PT zerolag - AUC = ' num2str(aucPR_xc_pt_zerolag)], ['GC - AUC = ' num2str(aucPR_gc)], ['MI- AUC = ' num2str(aucPR_mi)], ['MI zerolag - AUC = ' num2str(aucPR_mi_zerolag)], ['BVTE - AUC = ' num2str(aucPR_te_biv)], ['MVTE - AUC = ' num2str(aucPR_te_mv)], ['Rand Shuffle - AUC = ' num2str(aucPR_shuff)])
                    
                    saveas(gcf, [cwd filesep() 'roc' filesep() 'curve_results.jpeg'])
                end
            end
        end
    end
end

% ========================================================================

% LOCAL FUNCTIONS 

% get normalized version of x and y axis for vertical averaging of ROC curves
function [norm_xax, norm_yax] = prep4vertAvg(x,y)
    
    % turn off warning about NANs in data
    warning('off', 'MATLAB:interp1:NaNstrip')

    % remove nan values
    [y, rm_idx] = rmmissing(y);
    x = x(~rm_idx);

    
    % check that x values are sorted, and sort so higest number is last
    if ~issorted(x) || ~issorted(y)
        grp4sort = [x, y];
        grp4sort = sortrows(grp4sort, [1,2], {'ascend', 'ascend'});
        x = grp4sort(:,1);
        y = grp4sort(:,2);
    end

    % identify and pull uniques
    [x_sel, idx] = unique(x, 'last');
    y_sel = y(idx);

    % interpolate to get values onto same x axis
    norm_xax= linspace(0, 1, 1001);
    %try
    norm_yax = interp1(x_sel, y_sel, norm_xax, 'spline');
    % catch ME
    %     if size(x_sel,1) == 2 && sum(isnan(x_sel)) == 1
    %         [x_sel, idx] = unique(x, 'last');
    % 
    %         x_sel(isnan(x_sel)) = 0;
    %         norm_yax = interp1(x_sel, y_sel, norm_xax, 'spline');
    %     else
    %         error(getReport(ME, 'extended'));
    %     end
    % end

end
