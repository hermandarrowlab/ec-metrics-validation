#!/bin/bash -l        

set -e 

#====================================================================================================================

# Name:			do06_copy_from_msi.sh


# Author:		Kate Dembny
# Date:			6/27/23
# Updated:		6/27/23

# Syntax:		./do06_copy_from_msi.sh
# Arguments:	

# Description:	copy data from MSI
# Requirements:	
# Notes:		

#====================================================================================================================

# PATH

scr_dir=`pwd`
proj_dir=${scr_dir%/*}
data_dir=${proj_dir}/data

#====================================================================================================================

# START SCRIPT

#====================================================================================================================

# STEP 1: rsync

# sync from MSI to home  computer
rsync -r dembn002@mangi.msi.umn.edu:/home/netofft/dembn002/herman_darrow_lab/metric_paper/data/ ${data_dir}/

# sync from home computer to MSI
#rsync -r ${data_dir}/ dembn002@mangi.msi.umn.edu:/home/netofft/dembn002/herman_darrow_lab/metric_paper/data/ 
