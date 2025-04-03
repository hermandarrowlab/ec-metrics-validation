% =========================================================================

% Name:			mi_lagged_inplace.m

% Author:		Kate Dembny
% Date:			1/29/2034
% Updated:		1/29/2024

% Syntax:		
% Arguments:	

% Description:	calculate mutual information between nodes in folder
% Requirements: matlab
% Notes:

%% ========================================================================

function [out] = mi_lagged_inplace(wdir)

% STEP 0: check computer system and assign paths if on MSI

[ret, hn] = system('hostname');
disp(hn)

if isempty(regexp(hn, regexptranslate('wildcard', 'bme-netoff*'),'ONCE'))

    disp('MSI Identified as Computer - Paths Added')
    addpath /home/netofft/dembn002/matlab_toolboxes/fieldtrip-20221022;
else
    disp('home computer found')
end

% add fieldtrip folders to path
ft_defaults

%% -------------------------------------------------------------------------

% STEP 1: load data

orig_dir = [wdir filesep() 'orig'];
out_dir = [wdir filesep() 'mi_lagged'];
        
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

load([orig_dir filesep() 'orig_data.mat']);

out = 1;

% -------------------------------------------------------------------------

% STEP 2: Bivariate MI calculation

if isfile([out_dir filesep() 'mi_lagged.mat'])
    disp('Lagged bivariate MI already calculated')
else 
    disp('Running lagged bivariate mutual information')
    % time function
    st_time = tic;

    % make array to hold results from all calculated lags
    all_mi = zeros(size(ts,1),size(ts,1),11);
    
    % run function for all lags
    for lag = 1:10
        calc_mi = ft_connectivity_mutualinformation(ts, 'method', 'gcmi', 'lags', lag);
        all_mi(:,:,lag+1) = calc_mi';
    end
    
    % find max mi of all lags 
    calc_mi_lag = max(all_mi,[], 3);
    
    end_time = toc(st_time);

    disp('Saving')
    save([out_dir filesep() 'mi_lagged.mat'], 'calc_mi_lag')
    save([out_dir filesep() 'mi_lagged_runtime.mat'], 'end_time')
end

%% -------------------------------------------------------------------------


