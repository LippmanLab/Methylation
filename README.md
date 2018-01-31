# Methylation
## January 26, 2018

Pipeline for bismark alignment and methpipe cytosine analysis implemented by Zachary H Lemmon and Anat Hendelman.

git clone into a bin directory and symbolic link 'ln -s Methylation/bm_mp.sh' into the bin. All required programs should be working from cmdline. For instance "fastqc" and "trimmomatic" should be accessible. May need to mod the path to trimmomatic jar. bismark and methpipe as well need to be installed and on $PATH.

in directory where you are doing analysis. cp down the bm_mp_launch.sh script and example parameter file. Edit the parameterfile to have all options you want for analysis using --key=value syntax and then edit the bm_mp_launch.sh script to point to the log directory (usually $PWD/log), with the right number of parallel processes (#$ -t 1-NUMBEROFLINESINPARAMETERFILE) and make sure the Parameters=$( ...... ) is pointing to your parameter file.

qsub bm_mp_launch.sh
