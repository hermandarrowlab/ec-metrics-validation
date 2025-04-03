#!/bin/bash -l        

set -e 

#====================================================================================================================

# Name:			make_slurm.sh

# Author:		Kate Dembny
# Date:			3/17/23
# Updated:		3/17/23

# Syntax:		bash make_slurm.sh
# Arguments:	FLDR: folder to pull data from

# Description:	make slurm calls for analysis
# Requirements:	
# Notes:		

#====================================================================================================================

module load conda

# PATH

wdir=`pwd`
proj_dir=${wdir%/*}
slurm_dir=${proj_dir}/__slurm
data_dir=${proj_dir}/data/nodes

#====================================================================================================================

# START SCRIPT

#====================================================================================================================

# STEP 1: generate slurm files

for nodes in 20 30 50 65 80; do
	for lett in {a..j}; do
		for iter in {001..100}; do 
			for drop in {10..90..10}; do 
				outdir=${data_dir}/${nodes}/${lett}/drop_nodes/${iter}/drop_${drop}pct
				
				echo "#!/bin/bash -l
				#SBATCH --time=5:00:00
				#SBATCH --ntasks=30
				#SBATCH --mem=30g
				#SBATCH --tmp=30g
				#SBATCH --mail-type=FAIL  
				#SBATCH --mail-user=dembn002@umn.edu
				#SBATCH --output=${slurm_dir}/stdout/slurm_${nodes}_${lett}_${iter}_drop${drop}.out
				#SBATCH --error=${slurm_dir}/stdout/slurm_${nodes}_${lett}_${iter}_drop${drop}.err
				cd ${proj_dir}/scripts

				module load python3 
				module load conda

				python3 calc_mvte_inplace.py ${outdir}" > ${slurm_dir}/scripts/slurm_${nodes}_${lett}_${iter}_drop${drop}.sh
				chmod a+x ${slurm_dir}/scripts/slurm_${nodes}_${lett}_${iter}_drop${drop}.sh

			done
		done
	done
done



#====================================================================================================================

# STEP 2: run slurm


# for nodes in 20 30 50 65 80; do
# 	for lett in {a..j}; do
# 		for iter in {001..100}; do 
# 			for drop in {10..90..10}; do 
# 				outdir=${nodes}/${lett}/drop_nodes/${iter}/drop_${drop}pct

# 				sbatch {slurm_dir}/scripts/slurm_${nodes}_${lett}_${iter}_drop${drop}.sh
# 			done
# 		done
# 	done
# done
