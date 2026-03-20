#!/bin/bash -l        

set -e 

#====================================================================================================================

# Name:			do04_slurm_mv_idtxl.sh

# Author:		Kate Dembny
# Date:			3/17/23
# Updated:		6/21/23

# Syntax:		./do04_slurm_idtxl.sh
# Arguments:	

# Description:	make slurm calls for analysis
# Requirements:	
# Notes:		

#====================================================================================================================

# PATH

pdir=`pwd`
proj_dir=${pdir%/*}
scr_dir=${proj_dir}/scripts
data_dir=${proj_dir}/data
slurm_dir=${proj_dir}/__slurm

#====================================================================================================================

# INPUT


if [ "$#" -eq 1 ]; then
	usr_acct=$1
else
	usr_acct="netofft"
fi

echo "Fairshare Resources will be pulled from ${usr_acct}"

#====================================================================================================================

# START SCRIPT

#====================================================================================================================

# STEP 1: specify selection options

sels=('nodes' 'time_points' 'noise' 'comm_prob') # 'rereference'

#--------------------------------------------------------------------------------------------------------------------

# STEP 2: iterate through slections and specify folder options for each selection

for sel in ${sels[@]}; do
	# set folders for each sel
	if [[ ${sel} == 'nodes' ]]; then
		opts=('10' '20' '30' '50' '65') # '80')
	elif [[ ${sel} == 'time_points' ]]; then
		opts=('500' '1000' '5000' '10000' '50000')
	elif [[ ${sel} == 'noise' ]]; then
		opts=('0.01' '0.05' '0.1' '0.5' '1' '10' '5' '50') #'0.001' '0.005'
	elif [[ ${sel} == 'rereference' ]]; then
		opts=('cmn_avg' 'hrdwr_ref' 'random')
    elif [[ ${sel} == 'comm_prob' ]]; then
        opts=('0.2' '0.4' '0.6' '0.8' '1')
	fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 3: iterate through repetitions

	for opt in ${opts[@]}; do
		for lett in {001..100}; do
			for iter in a; do # {a..j}; do
				for drop in {10..90..10}; do 
					# assign directories
					wdir=${data_dir}/${sel}/${opt}/${lett}/drop_nodes/${iter}/drop_${drop}pct
					outdir=${wdir}/mvte
					outfile_dir=${wdir}/outfiles
					
					# make output folders
					if [ ! -d ${outdir} ]; then
						mkdir -p ${outdir}
					fi

					if [ ! -d ${outfile_dir} ]; then
						mkdir -p ${outfile_dir}
					fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 4: check for script completion
					
					if [[ ! -f ${outdir}/te_multivar_bin.mat ]]; then
						# skip if only 10 nodes with 90% drop because only 1 node remains
						if [[ ${opt} -eq '10' ]] && [[ ${drop} -eq '90' ]]; then
							continue
						fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 5: calculate script runtime based on number of nodes

						if [[ ${sel} == 'time_points' ]]; then
							if  [[ ${opt} == '500' ]]; then 
								set_time=8
							elif  [[ ${opt} == '1000' ]]; then 
								set_time=8
							elif  [[ ${opt} == '5000' ]]; then 
								set_time=19
							elif  [[ ${opt} == '10000' ]]; then 
								set_time=35
							elif  [[ ${opt} == '50000' ]]; then 
								set_time=96
							elif  [[ ${opt} == '100000' ]]; then 
								set_time=96
							fi

						elif [[ ${sel} == 'nodes' ]]; then
							if  [[ ${opt} == 10 ]]; then 
								set_time=2
							elif  [[ ${opt} == 20 ]]; then 
								set_time=2
							elif  [[ ${opt} == 30 ]]; then 
								set_time=9
							elif  [[ ${opt} == 50 ]]; then 
								set_time=43
							elif  [[ ${opt} == 65 ]]; then 
								set_time=96
							elif  [[ ${opt} == 80 ]]; then 
								set_time=240
							fi

						elif [[ ${sel} == 'noise' ]]; then
							set_time=35
						fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 6: make slurm script - mvte

						echo "#!/bin/bash -l
#SBATCH --time=${set_time}:00:00

#SBATCH --mem=25g
#SBATCH --tmp=25g
#SBATCH --mail-type=FAIL  
#SBATCH --mail-user=dembn002@umn.edu
#SBATCH --output=${outfile_dir}/mvte_slurm_%j.out
#SBATCH --error=${outfile_dir}/mvte_slurm_%j.err" > ${outfile_dir}/mvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh

#--------------------------------------------------------------------------------------------------------------------

# STEP 7: assign partition if 80 nodes

						if [[ ${opt} == '80' ]]; then
							echo "#SBATCH --ntasks=24
#SBATCH --partition=max" >> ${outfile_dir}/mvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh
						else
							echo "#SBATCH --ntasks=30" >> ${outfile_dir}/mvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh
						fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 8: add remaining default values to slurm script

						echo "#SBATCH -A ${usr_acct}

cd ${scr_dir}

module load python3 
module load conda

python3 calc_mvte_inplace.py ${wdir}" >> ${outfile_dir}/mvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh

#--------------------------------------------------------------------------------------------------------------------

# STEP 7: fix folder permissions and run individual slurm job

	 					echo mvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}
						chmod a+x ${outfile_dir}/mvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh
						sbatch ${outfile_dir}/mvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh
					fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 8: check for script completion - bivariate
					
					outdir=${wdir}/bvte

					# make output folders
					if [ ! -d ${outdir} ]; then
						mkdir -p ${outdir}
					fi

					if [[ ! -f ${outdir}/te_bivar_bin.mat ]]; then
						# skip if only 10 nodes with 90% drop because only 1 node remains
						if [[ ${opt} -eq '10' ]] && [[ ${drop} -eq '90' ]]; then
							continue
						fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 9: calculate script runtime based on number of nodes - bivariate

						if [[ ${sel} == 'time_points' ]]; then
							if  [[ ${opt} == '500' ]]; then 
								set_time=8
							elif  [[ ${opt} == '1000' ]]; then 
								set_time=8
							elif  [[ ${opt} == '5000' ]]; then 
								set_time=19
							elif  [[ ${opt} == '10000' ]]; then 
								set_time=35
							elif  [[ ${opt} == '50000' ]]; then 
								set_time=96
							elif  [[ ${opt} == '100000' ]]; then 
								set_time=96
							fi

						elif [[ ${sel} == 'nodes' ]]; then
							if  [[ ${opt} == 20 ]]; then 
								set_time=2
							elif  [[ ${opt} == 30 ]]; then 
								set_time=9
							elif  [[ ${opt} == 50 ]]; then 
								set_time=43
							elif  [[ ${opt} == 65 ]]; then 
								set_time=95
							elif  [[ ${opt} == 80 ]]; then 
								set_time=147
							fi

						elif [[ ${sel} == 'noise' ]]; then
							set_time=35
						fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 10: make slurm script - bvte

						echo "#!/bin/bash -l
#SBATCH --time=${set_time}:00:00
#SBATCH --mem=25g
#SBATCH --tmp=25g
#SBATCH --mail-type=FAIL  
#SBATCH --mail-user=dembn002@umn.edu
#SBATCH --output=${outfile_dir}/bvte_slurm_%j.out
#SBATCH --error=${outfile_dir}/bvte_slurm_%j.err" > ${outfile_dir}/bvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh

#--------------------------------------------------------------------------------------------------------------------

# STEP 7: assign partition if 85 nodes

						if [[ ${opt} == '80' ]]; then
							echo "#SBATCH --ntasks=24
#SBATCH --partition=max" >> ${outfile_dir}/bvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh
						else
							echo "#SBATCH --ntasks=30" >> ${outfile_dir}/bvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh
						fi

#--------------------------------------------------------------------------------------------------------------------

						echo "#SBATCH -A ${usr_acct}

cd ${scr_dir}

module load python3 
module load conda

python3 calc_bvte_inplace.py ${wdir}" >> ${outfile_dir}/bvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh

#--------------------------------------------------------------------------------------------------------------------

# STEP 11: fix folder permissions and run individual slurm job - bvte

	 					echo bvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}
						chmod a+x ${outfile_dir}/bvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh
						sbatch ${outfile_dir}/bvte_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh
					fi					
				done
			done
		done
	done
done
		
#====================================================================================================================

