
% Name:			corr_inplace.m

% Author:		Kate Dembny
% Date:			9/2/2022
% Updated:		6/19/23

% Syntax:		
% Arguments:	

% Description:	calculate correlations between nodes in place
% Requirements: matlab
% Notes:

%% ========================================================================

function [out] = corr_inplace(wdir)

% STEP 0: check computer system and assign paths if on MSI

[ret, hn] = system('hostname');
disp(hn)

if isempty(regexp(hn, regexptranslate('wildcard', 'bme-netoff*'),'ONCE'))

    disp('MSI Identified as Computer - Paths Added')
    addpath /home/netofft/dembn002/matlab_toolboxes/fc_toolbox;
    addpath(genpath('/home/netofft/dembn002/matlab_toolboxes/mvgc_toolbox'));
else
    disp('home computer found')
end

%% -------------------------------------------------------------------------

% STEP 1: load data

orig_dir = [wdir filesep() 'orig'];
out_dir = [wdir filesep() 'ml_fc'];
        
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

load([orig_dir filesep() 'orig_data.mat']);

out = 1;

%ts = transpose(ts);

%% -------------------------------------------------------------------------
        
% STEP 2: Bivariate  cross correlation
        
if isfile([out_dir filesep() 'xc_biv.mat'])
    disp('Bivariate cross correlation already calculated.')
else 
    disp('Running bivariate cross correlation')
    % time function
    st_time = tic;
    % run function
    xc_biv = zeros(size(tcoup,1), size(tcoup,1), 2);
    
    for y1 = 1:size(tcoup,1)
        for y2 = (y1+1):size(tcoup,1)
            if y1 == y2
                continue
            end
            [xcorr, xcorr_lag]=lagged(ts(y1,:), ts(y2,:));
            [max_val_fwd, max_idx_fwd] = max(xcorr(1, 11:end));
            [max_val_bk, max_idx_bk] = max(xcorr(1, 1:11));

            xc_biv(y2,y1,:) = [max_val_fwd, xcorr_lag(1,max_idx_fwd+10)];
            xc_biv(y1,y2,:) = [max_val_bk, -xcorr_lag(max_idx_bk)];

        end
    end

    end_time = toc(st_time);

    disp('Saving')
    save([out_dir filesep() 'xc_biv.mat'], 'xc_biv')
    save([out_dir filesep() 'xc_biv_runtime.mat'], 'end_time')
end

% -------------------------------------------------------------------------

% STEP 3: Partial cross correlation

if isfile([out_dir filesep() 'xc_pt.mat'])
    disp('Partial cross correlation already calculated')
else 
    disp('Running partial cross correlation')
    % time function
    st_time = tic;
    % run function
    xc_pt = Plagged(transpose(ts));

    [max_val, max_idx] = max(xc_pt(:,:,1:11), [], 3);
    xc_partial = cat(3,max_val, max_idx);

    end_time = toc(st_time);

    disp('Saving')
    save([out_dir filesep() 'xc_pt.mat'], 'xc_partial')
    save([out_dir filesep() 'xc_pt_runtime.mat'], 'end_time')
end

%% -------------------------------------------------------------------------

% STEP 2.2 - Bivariate cross correlation - zero lag

if isfile([out_dir filesep() 'xc_zerolag_biv.mat'])
    disp('Zero-lag bivariate cross correlation already calculated.')
else 
    disp('Running zero-lag bivariate cross correlation')
    % time function
    st_time = tic;
    % run function
    xc_zerolag_biv = zeros(size(tcoup,1), size(tcoup,1));

    for y1 = 1:size(tcoup,1)
        for y2 = (y1+1):size(tcoup,1)
            if y1 == y2
                continue
            end
            xc_zerolag_biv(y1,y2) = lagged(ts(y1,:), ts(y2,:),0);
            xc_zerolag_biv(y2,y1) = xc_zerolag_biv(y1,y2);
        end
    end

    end_time = toc(st_time);

    disp('Saving')
    save([out_dir filesep() 'xc_zerolag_biv.mat'], 'xc_zerolag_biv')
    save([out_dir filesep() 'xc_zerolag_biv_runtime.mat'], 'end_time')
end

%% Test Zero lag with corrcoef
% 
% xc_zerolag_biv_cc = corrcoef(ts');
% 
% for i = 1:size(xc_zerolag_biv_cc, 1)
%     xc_zerolag_biv_cc(i,i) = 0;
% end
% 
% %% Test Zero lag with xcorr
% 
% xc_zerolag_biv_xc = zeros(size(ts,1));
% for y1 = 1:size(tcoup,1)
%     for y2 = (y1+1):size(tcoup,1)
%         if y1 == y2
%             continue
%         end
%         xc_zerolag_biv_xc(y1,y2) = xcorr(ts(y1,:), ts(y2,:),0);
%         xc_zerolag_biv_xc(y2,y1) = xc_zerolag_biv_xc(y1,y2);
% 
%     end
% end
% 
% for i = 1:size(xc_zerolag_biv_cc, 1)
%     xc_zerolag_biv_cc(i,i) = 0;
% end
% 
% %%
% 
% figure
% subplot(131)
% imagesc(xc_zerolag_biv)
% title('toolbox')
% 
% subplot(132)
% imagesc(xc_zerolag_biv_cc)
% title('corrcoef')
% 
% subplot(133)
% imagesc(xc_zerolag_biv_xc)
% title('xcorr')

%% -------------------------------------------------------------------------

% % STEP 3.2: Partial cross correlation - zero lag
% 
% if isfile([out_dir filesep() 'xc_zerolag_pt.mat'])
%     disp('Zero-lag partial cross correlation already calculated')
% else 
%     disp('Running zero-lag partial cross correlation')
%     % time function
%     st_time = tic;
%     % run function
%     xc_zerolag_partial = Plagged(transpose(ts),0);
% 
%     %[max_val, max_idx] = max(xc_pt(:,:,1:11), [], 3);
%     %xc_partial = cat(3,max_val, max_idx);
% 
%     end_time = toc(st_time);
% 
%     disp('Saving')
%     save([out_dir filesep() 'xc_zerolag_pt.mat'], 'xc_zerolag_partial')
%     save([out_dir filesep() 'xc_zerolag_pt_runtime.mat'], 'end_time')
% end
 
%% -------------------------------------------------------------------------

% STEP 4: Bivariate coherence

% num_freq_bins = 1000;
% hz = 1500;
% 
% if isfile([out_dir filesep() 'coh_biv.mat'])
%     disp('Bivariate coherence already calculated')
% else 
%     disp('Running bivariate coherence')
%     % time function
%     st_time = tic;
%     % run function
%     coh_biv = zeros(size(tcoup,1), size(tcoup,1), num_freq_bins);
% 
%     for y1 = 1:size(tcoup,1)
%         for y2 = 1:size(tcoup,1)
%             if y1 == y2
%                 continue
%             end
%             [coh_biv(y1,y2,:), coh_biv_lambda]=coh(transpose(ts(y1,:)), transpose(ts(y2,:)), num_freq_bins, hz);
%         end
%     end
% 
%     end_time = toc(st_time);
% 
%     disp('Saving')
%     save([out_dir filesep() 'coh_biv.mat'], 'coh_biv', 'coh_biv_lambda')
%     save([out_dir filesep() 'coh_biv_runtime.mat'], 'end_time')
% end

% -------------------------------------------------------------------------

% STEP 5: Partial coherence

%         if isfile([cwd filesep() 'coh_pt.mat'])
%             disp(['Partial coherence already calculated for ' int2str(nd) ' nodes with rep ' rep])
%         else 
%             disp(['Running partial coherence for ' int2str(nd) ' nodes with rep ' rep])           
%             [coh_partial, coh_pt_lambda] = Pcoh(ts, num_freq_bins, hz);
% 
%             disp('saving')
%             save([cwd filesep() 'coh_pt.mat'], 'coh_partial', 'coh_pt_lambda')
%         end
 
% -------------------------------------------------------------------------

% STEP 6: Bivariate mutual Information

% if isfile([out_dir filesep() 'mi_biv.mat'])
%     disp('Bivariate mutual information already calculated')
% else 
%     disp('Running bivariate MI')
%     % time function
%     st_time = tic;
%     % run function
%     mi_biv = zeros(size(tcoup,1), size(tcoup,1));
% 
%     for y1 = 1:size(tcoup,1)
%         for y2 = 1:size(tcoup,1)
%             if y1 >= y2
%                 continue
%             end
%             mi_biv(y1,y2) = mutualinf(transpose(ts(y1,:)), transpose(ts(y2,:)), hz, 0, 0.5);
%             mi_biv(y2,y1) = mutualinf(transpose(ts(y1,:)), transpose(ts(y2,:)), hz, 0, 0.5);
% 
%         end
%     end
% 
%     end_time = toc(st_time);
% 
%     disp('Saving')
%     save([out_dir filesep() 'mi_biv.mat'], 'mi_biv')
%     save([out_dir filesep() 'mi_biv_runtime.mat'], 'end_time')
% end

% -------------------------------------------------------------------------

% STEP 7: Partial Mutual Information

% if isfile([out_dir filesep() 'mi_pt.mat'])
%     disp('Partial mutual information already calculated')
% else 
%     disp('Running partial mutual information') 
%     % time function
%     st_time = tic;
%     % run function
%     mi_partial = Pmutualinf(transpose(ts), hz, 0, 0.5);
% 
%     end_time = toc(st_time);
% 
%     disp('Saving')
%     save([out_dir filesep() 'mi_pt.mat'], 'mi_partial')
%     save([out_dir filesep() 'mi_pt_runtime.mat'], 'end_time')
% end

% -------------------------------------------------------------------------

% STEP 8: Granger Causality
if isfile([out_dir filesep() 'gc.mat'])
    disp('Granger Causality already calculated')
else 
    disp('Running GC')
    st_time = tic;

    [gc, gc_pval, gc_sig]  = mvgc4sims(ts, 'AIC');
    
    end_time = toc(st_time);

    disp('Saving')
    save([out_dir filesep() 'gc.mat'], 'gc', 'gc_pval', 'gc_sig')
    save([out_dir filesep() 'gc_runtime.mat'], 'end_time')
end         

%% ========================================================================
