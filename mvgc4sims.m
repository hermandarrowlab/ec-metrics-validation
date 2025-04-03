function [F, pval, sig]  = mvgc4sims(ts, morder)

% Name:			mvgc4sims.m

% Author:		Kate Dembny
% Date:			9/30/2022
% Updated:		9/30/2022

% Syntax:		
% Arguments:	

% Description:	calculate granger causality for simulated data 
% Requirements: matlab
% Notes:

%% =========================================================================

% Base variables

momax     = 20; % max number for model
regmode   = 'LWR';
nobs      = size(ts,2); % number of observations
ntrials   = 1; % number of trials
nvars     = size(ts,1); % number of channels
tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

%% =========================================================================

% STEP 1: estimate model order

[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(ts,momax,regmode);

% Select model order.
if strcmpi(morder,'actual')
    morder = amo;
    fprintf('\nusing actual model order = %d\n',morder);
elseif strcmpi(morder,'AIC')
    morder = moAIC;
    fprintf('\nusing AIC best model order = %d\n',morder);
elseif strcmpi(morder,'BIC')
    morder = moBIC;
    fprintf('\nusing BIC best model order = %d\n',morder);
else
    fprintf('\nusing specified model order = %d\n',morder);
end

%% =========================================================================

% STEP 2: estimate VAR model

% Estimate VAR model of selected order from data.
[A,SIG] = tsdata_to_var(ts,morder,regmode);

% Check for failed regression
assert(~isbad(A),'VAR estimation failed');

%% =========================================================================

% STEP 3: autocovariance calculation with error checking

[G,info] = var_to_autocov(A,SIG);

% report and check for errors here (and bail out on error)
var_acinfo(info,true);

%% =========================================================================

% STEP 4: calculate granger causality

F = autocov_to_pwcgc(G);

% Check for failed GC calculation
assert(~isbad(F,false),'GC calculation failed');

% Significance test using theoretical null distribution, adjusting for multiple hypotheses.
pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat); % take careful note of arguments!
sig  = significance(pval,alpha,mhtc);

