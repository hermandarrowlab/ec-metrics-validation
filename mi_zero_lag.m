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

function [out] = mi_zero_lag(wdir)

% STEP 0: check computer system and assign paths if on MSI

[~, hn] = system('hostname');
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
out_dir = [wdir filesep() 'mi_zerolag'];
        
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

load([orig_dir filesep() 'orig_data.mat']);

out = 1;

% -------------------------------------------------------------------------

% STEP 2: Bivariate MI calculation

if isfile([out_dir filesep() 'mi_zerolag.mat'])
    disp('Zero-lag bivariate MI already calculated')
else 
    disp('Running zero-lag bivariate mutual information')
    % time function
    st_time = tic;
    
    % run function for zero lag
    calc_mi_zerolag = ft_connectivity_mutualinformation(ts, 'method', 'gcmi', 'lags', 0);

    for i = 1:size(ts,1)
        calc_mi_zerolag(i,i) = 0;
    end

    % check for remaining imaginary values
    if sum(imag(calc_mi_zerolag) > 0, "all")
        error('MI calculation has imaginary values outside the diagonal. Exiting program..')
    end
    
    % remove imaginary value tags if there are no remaining imaginary values
    calc_mi_zerolag = real(calc_mi_zerolag);

    end_time = toc(st_time);

    disp('Saving')
    save([out_dir filesep() 'mi_zerolag.mat'], 'calc_mi_zerolag')
    save([out_dir filesep() 'mi_zerolag_runtime.mat'], 'end_time')
end

%% -------------------------------------------------------------------------


