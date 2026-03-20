#!/bin/bash -l        

set -e 

#====================================================================================================================

# Name:			do05_slurm_mi.sh

# Author:		Kate Dembny
# Date:			9/11/23
# Updated:		9/11/23

# Syntax:		./do05_slurm_mi.sh
# Arguments:	FLDR: folder to pull data from

# Description:	make slurm calls for analysis with matlab
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

sels=('nodes' 'time_points' 'noise' 'rereference')

#--------------------------------------------------------------------------------------------------------------------

# STEP 2: iterate through slections and specify folder options for each selection

for sel in ${sels[@]}; do
	# set folders for each sel
	if [[ ${sel} == 'nodes' ]]; then
		opts=('10' '20' '30' '50' '65') # '80')
	elif [[ ${sel} == 'time_points' ]]; then
		opts=('500' '1000' '5000' '10000') # '50000')
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
					outdir=${wdir}/mi
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
					
					
						# skip if only 10 nodes with 90% drop because only 1 node remains
					if [[ ${opt} -eq '10' ]] && [[ ${drop} -eq '90' ]]; then
							continue
					fi

					if [[ ! -f ${outdir}/mi_bv_runtime.mat ]]; then
						echo ${sel}/${opt}/${lett}/drop_nodes/${iter}/drop_${drop}pct

#--------------------------------------------------------------------------------------------------------------------

# STEP 5: make slurm script - mi in place (defunct)

						echo "#!/bin/bash -l
#SBATCH --time=2:00:00
#SBATCH --ntasks=30
#SBATCH --mem=10g
#SBATCH --tmp=10g
#SBATCH --mail-type=FAIL  
#SBATCH --mail-user=dembn002@umn.edu
#SBATCH --output=${outfile_dir}/mi_slurm_%j.out
#SBATCH --error=${outfile_dir}/mi_slurm_%j.err
#SBATCH -A ${usr_acct}
cd ${proj_dir}/scripts

module load matlab

matlab -nodisplay -nosplash -r \"cd $scr_dir; mi_inplace('${wdir}');exit\"" > ${outfile_dir}/mi_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh

#--------------------------------------------------------------------------------------------------------------------

# STEP 6: fix folder permissions and run individual slurm job
 
						chmod a+x ${outfile_dir}/mi_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh
						sbatch ${outfile_dir}/mi_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh	
					fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 7: check for script completion - multi-lag MI

					if [[ ! -f ${outdir}_lagged/mi_lagged_runtime.mat ]]; then
						echo ${sel}/${opt}/${lett}/drop_nodes/${iter}/drop_${drop}pct

#--------------------------------------------------------------------------------------------------------------------

# STEP 8: make slurm script - multi-lag mi

						echo "#!/bin/bash -l
#SBATCH --time=2:00:00
#SBATCH --ntasks=30
#SBATCH --mem=10g
#SBATCH --tmp=10g
#SBATCH --mail-type=FAIL  
#SBATCH --mail-user=dembn002@umn.edu
#SBATCH --output=${outfile_dir}/mi_lagged_slurm_%j.out
#SBATCH --error=${outfile_dir}/mi_lagged_slurm_%j.err
#SBATCH -A ${usr_acct}
cd ${proj_dir}/scripts

module load matlab

matlab -nodisplay -nosplash -r \"cd $scr_dir; mi_lagged_inplace('${wdir}');exit\"" > ${outfile_dir}/mi_lagged_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh

#--------------------------------------------------------------------------------------------------------------------

# STEP 9: fix folder permissions and run individual slurm job
 
						chmod a+x ${outfile_dir}/mi_lagged_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh
						sbatch ${outfile_dir}/mi_lagged_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh	
					fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 10: check for script completion - zero-lag MI

					if [[ ! -f ${outdir}_zerolag/mi_zerolag_runtime.mat ]]; then
						echo ${sel}/${opt}/${lett}/drop_nodes/${iter}/drop_${drop}pct

#--------------------------------------------------------------------------------------------------------------------

# STEP 11: make slurm script - zero-lag mi

						echo "#!/bin/bash -l
#SBATCH --time=2:00:00
#SBATCH --ntasks=30
#SBATCH --mem=10g
#SBATCH --tmp=10g
#SBATCH --mail-type=FAIL  
#SBATCH --mail-user=dembn002@umn.edu
#SBATCH --output=${outfile_dir}/mi_zerolag_slurm_%j.out
#SBATCH --error=${outfile_dir}/mi_zerolag_slurm_%j.err
#SBATCH -A ${usr_acct}
cd ${proj_dir}/scripts

module load matlab

matlab -nodisplay -nosplash -r \"cd $scr_dir; mi_zero_lag('${wdir}');exit\"" > ${outfile_dir}/mi_zerolag_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh

#--------------------------------------------------------------------------------------------------------------------

# STEP 12: fix folder permissions and run individual slurm job
 
						chmod a+x ${outfile_dir}/mi_zerolag_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh
						sbatch ${outfile_dir}/mi_zerolag_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}.sh	
					fi
				done
			done
		done
	done
done
		
#====================================================================================================================
