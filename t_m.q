#!/bin/bash
#SBATCH --array=1-20
#SBATCH --output=slurm_tm.out
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$HOME/utility/nlopt_compile/lib
srun /opt/apps/matlabR2015a/bin/matlab -nodisplay -nodesktop -nosplash -singleCompThread -nojvm -r "clear;clc;rank_id=$SLURM_ARRAY_TASK_ID;bootstrap_flag=0;t_m;quit"
