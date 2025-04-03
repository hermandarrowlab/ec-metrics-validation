% =========================================================================

% Name:			mi_inplace.m

% Author:		Kate Dembny
% Date:			9/11/2023
% Updated:		9/11/23

% Syntax:		
% Arguments:	

% Description:	calculate mutual information between nodes in folder
% Requirements: matlab
% Notes:

%% ========================================================================

function [out] = mi_inplace(wdir)

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
out_dir = [wdir filesep() 'mi'];
        
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

load([orig_dir filesep() 'orig_data.mat']);

out = 1;

% -------------------------------------------------------------------------

% STEP 2: Bivariate MI calculation

if isfile([out_dir filesep() 'mi_bv.mat'])
    disp('Bivariate MI already calculated')
else 
    disp('Running bivariate mutual information')
    % time function
    st_time = tic;
    
    % run function
    calc_mi = ft_connectivity_mutualinformation(ts, 'method', 'gcmi', 'lags', 10);
    calc_mi = calc_mi';

    end_time = toc(st_time);

    disp('Saving')
    save([out_dir filesep() 'mi_bv.mat'], 'calc_mi')
    save([out_dir filesep() 'mi_bv_runtime.mat'], 'end_time')
end

% -------------------------------------------------------------------------

