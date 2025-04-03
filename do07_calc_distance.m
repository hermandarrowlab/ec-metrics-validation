%=========================================================================

% Name:			do07_calc_distance.m

% Author:		Kate Dembny
% Date:			6/27/2023
% Updated:		9/6/2023

% Syntax:		
% Arguments:	

% Description:	generate figures for images of generated networks
% Requirements: matlab
% Notes:

%% ========================================================================
 
% DIRECTORIES 

clearvars 

scr_dir = pwd;
pdir = fileparts(cd);
data_dir = [pdir filesep() 'data'];

addpath('/home/kdembny/MATLAB/toolboxes/cprintf/cprintf')

%% ========================================================================

% STEP 1: iterate over nodes - node dropping

for opt = ["nodes"] %, "time_points", "noise", "rereference"]
    % set base directory
    var_dir = [data_dir filesep() convertStringsToChars(opt)];

    if strcmp(opt,'nodes')
        cycle = [10, 20, 30, 50, 65];
    elseif strcmp(opt,'time_points')
        cycle = [500, 1000, 5000, 10000];
    elseif strcmp(opt,'noise')
        cycle = [0.01, 0.05 0.1 0.5 1 5 10 50];
    elseif strcmp(opt,'rereference')
        cycle = ["cmn_avg", "hrdwr_ref", "random"];
    end

    % iterate folder for node dropping
    for sel = cycle
        for lett = 1:100 
            lett = num2str(lett,'%03.f');
            for iter = 'a' %:'j'
                for drop = 10:10:90

% -------------------------------------------------------------------------

% STEP 2: check if data exists and run analysis

                    wdir = [var_dir filesep() num2str(sel) filesep() lett filesep() 'drop_nodes' filesep() iter filesep() 'drop_' num2str(drop) 'pct'];
                    outdir = [wdir filesep() 'norm'];

                    if isfile([wdir filesep() 'orig' filesep() 'orig_data.mat']) && isfile([wdir filesep() 'ml_fc' filesep() 'gc.mat']) && isfile([wdir filesep() 'mvte' filesep() 'te_multivar.mat']) && isfile([wdir filesep() 'bvte' filesep() 'te_bivar.mat']) && isfile([wdir filesep() 'mi_lagged' filesep() 'mi_lagged.mat']) && isfile([wdir filesep() 'mi_zerolag' filesep() 'mi_zerolag.mat']) && isfile([wdir filesep() 'ml_fc' filesep() 'xc_zerolag_biv.mat']) && isfile([wdir filesep() 'ml_fc' filesep() 'xc_zerolag_pt.mat']) 
                        if true %~exist([outdir filesep() 'cos_dist.mat'], 'file')

                            cprintf('blue', ['working on ' num2str(sel) ' letter ' lett ' iter ' iter ' drop ' num2str(drop) ' \n'])

                            % make directory if it does not exist
                            if ~exist(outdir, 'dir')
                                mkdir(outdir)
                            end

                            % run function to calculate  cosine distances
                            get_cosdsts(wdir, outdir)
                        else
                            % message for cosine distances already calculated
                            cprintf('blue', ['Cosine distances for ' num2str(sel) ' letter ' lett ' iter ' iter ' drop ' num2str(drop) ' have already been calculated \n'])
                            continue
                        end
                    else
                        % error message for missing files needed to calculate cosine distance
                        cprintf('red', ['Files are missing that prevent the calculation of cosine distances for ' num2str(sel) ' letter ' lett ' iter ' iter ' drop ' num2str(drop) ' \n'])
                        continue

                    end
                end
            end
        end
    end
end

%% ========================================================================

% STEP 4: iterate over nodes - no node dropping

for opt = ["nodes", "time_points", "noise"] %, "rereference"
    % set base directory
    var_dir = [data_dir filesep() convertStringsToChars(opt)];

    if strcmp(opt,'nodes')
        cycle = [10, 20, 30, 50, 65];
    elseif strcmp(opt,'time_points')
        cycle = [500, 1000, 5000, 10000];
    elseif strcmp(opt,'noise')
        cycle = [0.01, 0.05 0.1 0.5 1 5 10 50];
    elseif strcmp(opt,'rereference')
        cycle = ["cmn_avg", "hrdwr_ref", "random"];
    end

    % iterate folder for node dropping
    for sel = cycle

        for lett = 1:100
            lett = num2str(lett,'%03.f');
            
% -------------------------------------------------------------------------

% STEP 5: check if data exists and run analysis
    
            wdir = [var_dir filesep() num2str(sel) filesep() lett];
            outdir = [wdir filesep() 'norm'];

            if isfile([wdir filesep() 'orig' filesep() 'orig_data.mat']) && isfile([wdir filesep() 'ml_fc' filesep() 'gc.mat']) && isfile([wdir filesep() 'mvte' filesep() 'te_multivar.mat']) && isfile([wdir filesep() 'bvte' filesep() 'te_bivar.mat']) && isfile([wdir filesep() 'mi_lagged' filesep() 'mi_lagged.mat']) && isfile([wdir filesep() 'mi_zerolag' filesep() 'mi_zerolag.mat']) && isfile([wdir filesep() 'ml_fc' filesep() 'xc_zerolag_biv.mat']) && isfile([wdir filesep() 'ml_fc' filesep() 'xc_zerolag_pt.mat'])
                if true %~exist([outdir filesep() 'cos_dist.mat'], 'file')
                        
                    cprintf('blue', ['working on ' num2str(sel) ' letter ' lett ' \n'])
    
                    % make output directory if it does not exist
                    if ~exist(outdir, 'dir')
                        mkdir(outdir)
                    end
    
                    % run function to calculate  cosine distances
                    get_cosdsts(wdir, outdir)

                else
                    % message for cosine distances already calculated
                    cprintf('blue', ['Cosine distances for ' num2str(sel) ' letter ' lett ' have already been calculated \n'])
                    continue
                end
            else
                % error message for missing files needed to calculate cosine distance
                cprintf('red', ['Files are missing that prevent the calculation of cosine distances for ' num2str(sel) ' letter ' lett ' \n'])
                continue

            end
        end
    end
end

%% ========================================================================

function real_arr = remove_nans(arr)
    
    if ~isreal(arr)
        arr = real(arr);
    end

    find_real = ~isnan(arr);
    real_arr = arr(find_real);
    
end

function get_cosdsts(wdir, outdir)

    % load data
    load([wdir filesep 'orig' filesep 'orig_data.mat'])
    load([wdir filesep 'ml_fc' filesep 'gc.mat'])
    load([wdir filesep 'ml_fc' filesep 'xc_biv.mat'])
    xc_biv = xc_biv(:,:,1);
    load([wdir filesep 'ml_fc' filesep 'xc_pt.mat'])
    xc_partial = xc_partial(:,:,1);
    %load([wdir filesep 'mi' filesep() 'mi_bv.mat'])
    load([wdir filesep 'mi_lagged' filesep 'mi_lagged.mat'])
    load([wdir filesep 'mvte' filesep 'te_multivar.mat'])
    load([wdir filesep 'bvte' filesep 'te_bivar.mat'])
    
    load([wdir filesep 'mi_zerolag' filesep 'mi_zerolag.mat'])
    load([wdir filesep 'ml_fc' filesep 'xc_zerolag_biv.mat'])
    load([wdir filesep 'ml_fc' filesep 'xc_zerolag_pt.mat'])
    load([wdir filesep 'shuff' filesep 'shuff.mat'])

    % make all diagonals NaN
    for i = 1:size(gc,1)
        tcoup(i,i) = NaN;
        xc_biv(i,i) = NaN;
        xc_partial(i,i) = NaN;
        gc(i,i) = NaN;
        calc_mi_lag(i,i) = NaN;
        te_bivar(i,i) = NaN;
        te_multivar(i,i) = NaN;
        
        xc_zerolag_biv(i,i) = NaN;
        xc_zerolag_partial(i,i) = NaN;
        calc_mi_zerolag(i,i) = NaN;
        shuff(i,i) = NaN;
    end

    % turn off warning for values being small in cosine distance
    warning('off', 'stats:pdist2:ZeroPoints')

    % calculate cosine distance after removing nans
    cosdst_xc_biv = pdist2(remove_nans(tcoup)', remove_nans(xc_biv)', 'cosine');
    cosdst_xc_partial = pdist2(remove_nans(tcoup)', remove_nans(xc_partial)', 'cosine');
    cosdst_gc = pdist2(remove_nans(tcoup)', remove_nans(gc)','cosine');
    cosdst_mi_biv = pdist2(remove_nans(tcoup)', remove_nans(calc_mi_lag)', 'cosine');
    cosdst_te_bivar = pdist2(remove_nans(tcoup)', remove_nans(te_bivar)', 'cosine');
    cosdst_te_multivar = pdist2(remove_nans(tcoup)', remove_nans(te_multivar)', 'cosine');
    
    cosdst_mi_zerolag = pdist2(remove_nans(tcoup)', remove_nans(calc_mi_zerolag)', 'cosine');
    cosdst_xc_biv_zerolag = pdist2(remove_nans(tcoup)', remove_nans(xc_zerolag_biv)', 'cosine');
    cosdst_xc_partial_zerolag = pdist2(remove_nans(tcoup)', remove_nans(xc_zerolag_partial)', 'cosine');

    cosdst_shuff = pdist2(remove_nans(tcoup)', remove_nans(shuff)', 'cosine');

    check_nans = [cosdst_xc_biv, cosdst_xc_partial, cosdst_gc, cosdst_mi_biv, ... 
        cosdst_te_bivar, cosdst_te_multivar, cosdst_mi_zerolag, cosdst_xc_biv_zerolag ... 
        cosdst_xc_partial_zerolag, cosdst_shuff];

    if sum(remove_nans(tcoup)) == 0
        cprintf('black', 'Only zeros remain in the original coupling data. Cosine distance cannot be calculated. \n')
        return
    end

    % return if any of distances are NaN, this points to a potential error with NaN removal
    if anynan(check_nans)
        cprintf('red', 'ERROR: some of cosine distances were NaN, iteration is not being saved out \n')
        return
    end

    % save data out
    save([outdir filesep() 'cos_dist.mat'], 'cosdst_xc_biv', 'cosdst_xc_partial', 'cosdst_gc', 'cosdst_mi_biv', 'cosdst_te_bivar', 'cosdst_te_multivar', 'cosdst_mi_zerolag', 'cosdst_xc_biv_zerolag', 'cosdst_xc_partial_zerolag', 'cosdst_shuff')
end
