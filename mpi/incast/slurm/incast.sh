#!/bin/bash --login

###
# job name
#SBATCH --job-name=congestion
# specify its partition
#SBATCH --partition=workq
# job stdout file
#SBATCH --output=congestion.%J.out
# job stderr file
#SBATCH --error=congestion.%J.err
# maximum job time in HH:MM:SS
#SBATCH --time=01:00:00
#SBATCH --nodes=8
# maximum memory
#SBATCH --mem-per-cpu=512M
###

# Define experiment name
export EXPERIMENT_NAME=$SLURM_JOB_NAME

# Define variables
export NUM_ITERATIONS=10000
export INCAST_NC=$SLURM_JOB_NUM_NODES
export INCAST_PPN=64
export INCAST_MSG_BYTES=81920


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
     -iterations $NUM_ITERATIONS \
     -msgsize $INCAST_MSG_BYTES

# now we know INCAST is done
export INCAST_END=`date -uI'seconds'`

# record all jobsteps
echo "start_time,end_time,job_id,job_name,user">$EXPERIMENT_JOBFILE
echo $INCAST_START,$INCAST_END,$EXPERIMENT_NAME,$EXPERIMENT_NAME.INCAST,$USER>>$EXPERIMENT_JOBFILE

# sbatch
# sbatch --nodefile=./nodelist.txt incast.sh
