#!/bin/bash
#$ -cwd
#$ -j y
#$ -l m_mem_free=5G

#$ -pe threads 16
### MAKE A NEW DIRECTORY IN 'Bismark_Run' that is called 'log'
#$ -o /sonas-hs/lippman/hpc/data/Methylation_project/MicroTom-fruit-Epigenomics/log
#$ -t 1-2

# define variables with various info from the ParameterFile...
Parameters=$(sed -n -e "$SGE_TASK_ID p" ParameterFile_Full) # ParameterFile is a text file in working directory that is space/tab separated for various run variables. You can change read names, output directories, genomes, etc with this.

bash $HOME/common_jobscripts/bm_mp.sh $Parameters
