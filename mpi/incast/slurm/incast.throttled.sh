#!/bin/bash --login

###
# job name
#SBATCH --job-name=ppn-64
# specify its partition
#SBATCH --partition=workq
# job stdout file
#SBATCH --output=ppn-64.%J.out
# job stderr file
#SBATCH --error=ppn-64.%J.err
# maximum job time in HH:MM:SS
#SBATCH --time=01:00:00
#SBATCH --nodes=8
# maximum memory
#SBATCH --mem-per-cpu=512M
###

# Define experiment name
export EXPERIMENT_NAME=$SLURM_JOB_NAME

# Define allocations
export INCAST_NC=$SLURM_JOB_NUM_NODES
export INCAST_PPN=64

# Define directories and files
export APP_BASE_DIR=/lus/msrinivasa/develop
export EXPERIMENT_METAFILE=$EXPERIMENT_NAME.README.txt
export EXPERIMENT_JOBFILE=$EXPERIMENT_NAME.JOBFILE.csv

# Write metadata into a README file for the experiment
echo $EXPERIMENT_NAME>$EXPERIMENT_METAFILE
echo "Incast Allocation: "$INCAST_NC>>$EXPERIMENT_METAFILE
echo "Nodelist: "$SLURM_JOB_NODELIST>>$EXPERIMENT_METAFILE

# Record the job start time
export INCAST_START=`date -uI'seconds'`
# Run incast on its allocation
srun --relative=0 \
     --nodes=$INCAST_NC \
     --ntasks-per-node $INCAST_PPN \
     $APP_BASE_DIR/ember/mpi/incast/incast \
     -iterations 1000 \
     -msgsize 81920

# now we know INCAST is done
export INCAST_END=`date -uI'seconds'`

# record all jobsteps
echo "start_time,end_time,job_id,job_name,user">$EXPERIMENT_JOBFILE
echo $INCAST_START,$INCAST_END,$EXPERIMENT_NAME,$EXPERIMENT_NAME.INCAST,$USER>>$EXPERIMENT_JOBFILE

# sbatch
# sbatch --nodefile=./nodelist.txt incast.sh
