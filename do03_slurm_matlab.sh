#!/bin/bash -l        

set -e 

#====================================================================================================================

# Name:			do03_slurm_matlab.sh

# Author:		Kate Dembny
# Date:			6/19/23
# Updated:		6/19/23

# Syntax:		./do03_slurm_matlab.sh
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

sels=('nodes') # 'time_points' 'noise' 'rereference')

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
	fi

#--------------------------------------------------------------------------------------------------------------------

# STEP 3: iterate through repetitions

	for opt in ${opts[@]}; do
		for lett in {001..100}; do
			for iter in a; do # {a..j}; do 
				for drop in {10..90..10}; do 
					# assign directories
					wdir=${data_dir}/${sel}/${opt}/${lett}/drop_nodes/${iter}/drop_${drop}pct
					outdir=${wdir}/ml_fc
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
					
					#if [[ -f ${outdir}/gc_runtime.mat ]]; then
					if [[ -f ${outdir}/xc_zerolag_pt_runtime.mat ]]; then
						#echo "${sel} already run"
						continue
					elif [[ ${opt} -eq '10' ]] && [[ ${drop} -eq '90' ]]; then
						continue
					else
						echo ${sel}/${opt}/${lett}/drop_nodes/${iter}/drop_${drop}pct
					fi

					# if [[ ${sel} != 'nodes' ]]; then
					# 	nd=50; 
					# else
					# 	nd=$((opt))
					# fi

					# scale_fact=$((${nd}/20))
					# set_time=$((${scale_fact}*3))

#--------------------------------------------------------------------------------------------------------------------

# STEP 5: make slurm script - mvte

					echo "#!/bin/bash -l
#SBATCH --time=48:00:00
#SBATCH --ntasks=30
#SBATCH --mem=10g
#SBATCH --tmp=10g
#SBATCH --mail-type=FAIL  
#SBATCH --mail-user=dembn002@umn.edu
#SBATCH --output=${outfile_dir}/matlab_slurm_%j.out
#SBATCH --error=${outfile_dir}/matlab_slurm_%j.err
#SBATCH -A ${usr_acct}
cd ${proj_dir}/scripts

module load matlab

matlab -nodisplay -nosplash -r \"cd $scr_dir; corr_inplace('${wdir}');exit\"" > ${outfile_dir}/matlab_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh

#--------------------------------------------------------------------------------------------------------------------

# STEP 6: fix folder permissions and run individual slurm job
 
					chmod a+x ${outfile_dir}/matlab_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh
					sbatch ${outfile_dir}/matlab_slurm_${sel}_${opt}_${lett}_${iter}_drop${drop}_mvte.sh				
				done
			done
		done
	done
done
		
#====================================================================================================================
