#!/bin/python3

#====================================================================================================================

# Name:			calc_mvte_inplace.py

# Author:		Kate Dembny
# Date:			3/16/23
# Updated:		6/19/23

# Syntax:		python3 calc_bvte_inplace.py WDIR
# Arguments:	WDIR: working directory to pull data from and save data to

# Description:	use IDTxl to calculate bivariate transfer entropy in networks
# Requirements:	python
# Notes:		

#====================================================================================================================

# MODULES

import os
import numpy as np
import scipy.io
import idtxl
from idtxl.data import Data
from idtxl.multivariate_te import MultivariateTE
from idtxl.bivariate_te import BivariateTE
import networkx as nx
from idtxl import idtxl_io as io

import time
import sys

#====================================================================================================================
 
 # INPUT

wdir = sys.argv[1]
orig_dir = os.path.join(wdir, 'orig') 
outdir = os.path.join(wdir, 'bvte') 

#====================================================================================================================
# BEGIN SCRIPT
#====================================================================================================================

# STEP 1: load data

nodes = scipy.io.loadmat(os.path.join(orig_dir,'orig_data.mat'))
    
ts = nodes['ts']
d = Data(ts, dim_order='ps')
num_elec = np.shape(ts)[0]
    
#--------------------------------------------------------------------------------------------------------------------
    
# STEP 2: establish analysis parameters

network_analysis = BivariateTE()
settings = {'cmi_estimator': 'JidtGaussianCMI',
            'max_lag_sources': 10,
            'min_lag_sources': 1,
            'fdr_correction': True,
            'verbose': False}

#--------------------------------------------------------------------------------------------------------------------

# STEP 3: run analysis, including tracking time to run analysis

# start timer 
start = time.time()

# analyze data
results = network_analysis.analyse_network(settings=settings, data=d)

# stop timer
end = time.time()
time_elapsed = end - start

# save out timer data
tf = open(os.path.join(outdir, "te_bivar_runtime.txt"), "w")
tf.write(str(time_elapsed))
tf.close()

#--------------------------------------------------------------------------------------------------------------------

# STEP 4: extract multivariate TE values

te_mtx = np.zeros([num_elec,  num_elec])

for i in range(num_elec):
    source_locs = results.get_target_sources(i, fdr=False)
    te_vals = results.get_single_target(i, fdr=False)['te']
        
    if np.shape(source_locs)[0] == 0:
        continue
    
    te_mtx[i,source_locs] = te_vals

#--------------------------------------------------------------------------------------------------------------------

# STEP 5: save out mvTE

# save out TE weighted results
save_dict = {'te_bivar': te_mtx}
scipy.io.savemat(os.path.join(outdir,'te_bivar.mat'), save_dict)
        
# save out binary
weights = 'max_te_lag'
adj_mtx = results.get_adjacency_matrix(weights=weights, fdr=False)
nx_mtx = io.export_networkx_graph(adjacency_matrix=adj_mtx, weights = weights)
np_mtx = nx.to_numpy_array(nx_mtx, weight = 'union').transpose()

bin_dict = {'bin_te_bivar': np_mtx}
scipy.io.savemat(os.path.join(outdir,'te_bivar_bin.mat'), save_dict)

#====================================================================================================================
