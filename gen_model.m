%=========================================================================

function [tcoup,A,XF,ns,snr] = gen_model(nc,d,tf, coup,c_prob,d_noise, m_noise)

% Name:			gen_model.m

% Author:		Kate Dembny
% Date:			8/3/2022
% Updated:		8/31/2022

% Syntax:		
% Arguments:	

% Description:	generate models of neural signals
% Requirements: matlab
% Notes:

%% =========================================================================
 
% STEP 1: hardcode basic parameters

% nc = 5; %number of channels
% d = 10; %dimension used to implement and remove coupling (nodes are sometimes coupled and sometimes non-coupled) 
% tf = 10000; %how far should the model predict?
% coup = 0.1; %average coupling strength
% c_prob = 0.1; %coupling probability
% d_noise = 0.01; %size of the dynamical noise
% m_noise = 0; % size of measurement noise - SNR

%% -------------------------------------------------------------------------

% STEP 2: establish empty model vectors

A = zeros(nc,nc,d); %connectivity array with delays
XN = zeros(nc,d); %working vectors (continuously updating)
XF = zeros(tf,nc); %whole timeseries

% Initialize XO (dynamical noise)

XN = d_noise*(randn(size(XN))+1);

%% -------------------------------------------------------------------------

% STEP 3: select channels that are linked

tcoup = rand([nc,nc]); % coupling matrix
dd = find(tcoup>=c_prob); % uncoupled indices
uu = find(tcoup<c_prob); % coupled indices
tcoup(dd) = 0;
tcoup(uu) = 1;

for i=1:nc
    tcoup(i,i)=0; % remove coupled diagnals
end

%% -------------------------------------------------------------------------

% STEP 4: Maps values of coupling to cosine transfer function  

for i=1:nc
    for j=1:nc
        if (tcoup(i,j) == 1)
            A(i,j,1:3) = coup*[1, -2 , 1]';
        end
        
    end
end

%% -------------------------------------------------------------------------

% STEP 5: randomly shift numbers circularly through matrix to signify
% coupling turning on and off 

randshift = round(randn([nc,nc])*(d-3));
% make array of random numbers the size of square of number of channels,
% multiply values by 7, indicating how far to circularly shift values

for i=1:nc
    for j=1:nc
        A(i,j,:) = circshift(squeeze(A(i,j,:)),randshift(i,j));
    end
end

%% -------------------------------------------------------------------------

% STEP 6: iterate model to create timeseries

%iterate the model
for j=1:tf
    for i=1:d
        XF(j,:) = (squeeze(XF(j,:)') + squeeze(A(:,:,i))*squeeze(XN(:,i)))'+ d_noise*(randn(size(squeeze(XF(1,:)))));
    end

    %time to update the time to the next step
    idx = [1:d];
    nidx = circshift(idx',1)';
        
    XN = XN(:,nidx);
    XN(:,1) = squeeze(XF(j,:))';
end

%% -------------------------------------------------------------------------

% STEP 7: add measurement noise

% add noise and calculate
if m_noise ~= 0
    %ns = m_noise*rand(size(XF));

    ns = awgn(XF,m_noise, 'measured') - XF;
    
    % add noise to the model
    XF = XF + ns;
    snr = m_noise;
    
else
    snr = Inf;
    ns = zeros(size(XF));
end
    
%% =========================================================================
