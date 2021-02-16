#!/bin/bash --login

###
# job name
#SBATCH --job-name=trial
# specify its partition
#SBATCH --partition=workq
# job stdout file
#SBATCH --output=trial.%J.out
# job stderr file
#SBATCH --error=trial.%J.err
# maximum job time in HH:MM:SS
#SBATCH --time=01:00:00
#SBATCH --nodes=10
# maximum memory
#SBATCH --mem-per-cpu=512M
# run a single task
###

module restore PrgEnv-cray

# Define experiment name
export EXPERIMENT_NAME=$SLURM_JOB_NAME

# Define allocations
export TOTAL_NC=$SLURM_JOB_NUM_NODES
export INCAST_NC=10
export INCAST_PPN=64

# Define directories and files
export APP_BASE_DIR=/home/users/msrinivasa/develop
export EXPERIMENT_METAFILE=$EXPERIMENT_NAME.README.txt
export EXPERIMENT_JOBFILE=$EXPERIMENT_NAME.JOBFILE.csv

# Write metadata into a README file for the experiment
echo $EXPERIMENT_NAME>$EXPERIMENT_METAFILE
echo "Total Allocation: "$TOTAL_NC>>$EXPERIMENT_METAFILE
echo "Incast Allocation: "$GPCNET_NC>>$EXPERIMENT_METAFILE
echo "Nodelist: "$SLURM_JOB_NODELIST>>$EXPERIMENT_METAFILE

# Record the job start time
export INCAST_START=`date -uI'seconds'`
# Run incast on its allocation with 64 ppn
srun --relative=0 \
     --nodes=$INCAST_NC \
     --ntasks-per-node $INCAST_PPN \
     $APP_BASE_DIR/ember/mpi/incast/incast \
     -iterations 1000 \
     -msgsize 1024

# now we know INCAST is done
export INCAST_END=`date -uI'seconds'`

# record all jobsteps
echo "start_time,end_time,job_id,job_name,user">$EXPERIMENT_JOBFILE
echo $INCAST_START,$INCAST_END,$EXPERIMENT_NAME,$EXPERIMENT_NAME.INCAST,$USER>>$EXPERIMENT_JOBFILE

