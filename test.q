#!/bin/bash
#SBATCH --array=1
#SBATCH --output=slurm_tm.out
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$HOME/utility/nlopt_compile/lib
srun /opt/apps/matlabR2015a/bin/matlab -nodisplay -nodesktop -nosplash -singleCompThread -nojvm -r "rank=$SLURM_ARRAY_TASK_ID;t_m;quit"
