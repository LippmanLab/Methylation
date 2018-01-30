#!/bin/bash

echo " ----- RUN STARTED AT  ----- " ; date; echo ""

# define variables with various info from the ParameterFile...

trimmomatic=$HOME/bin/Trimmomatic-0.32/trimmomatic-0.32.jar

declare -A argarr
### Define default values that we can and put in argarr
#SampleName= ### Required
argarr["TrimThreads"]=1
argarr["ILLUMINACLIP"]="${trimmomatic/trimmomatic-0.32.jar/adapters/TruSeq3-PE-2.fa}":2:30:10
argarr["LEADING"]=3
argarr["TRAILING"]=3
argarr["MINLEN"]=36
argarr["SLIDINGWINDOW"]=4:15
argarr["BM_multicore"]=2
argarr["BM_seedmm"]=1
argarr["BM_score_min"]="L,0,-0.3"
argarr["BM_maxinsert"]=1500
argarr["BM_directionality"]="--non_directional"
#BM_bisulfitegenome= ### Required
#MP_indchr= ### Required
argarr["MP_mindepth"]=10
argarr["MP_hmr_itr"]=15
argarr["MP_pmd_itr"]=15
argarr["MP_hypermr_itr"]=15

echo " ----- READING IN OPTIONS  ----- " ; date; echo ""

for i in "$@"; do
	case $i in
		--SampleName=*)
		argarr["SampleName"]="${i#*=}"
		shift
	;;
		--read1=*)
		argarr["read1"]="${i#*=}"
		shift
	;;
		--read2=*)
		argarr["read2"]="${i#*=}"
		shift
	;;
		--ProjectFilesDirectory=*)
		argarr["ProjectFilesDirectory"]="${i#*=}"
		shift
	;;

		--TrimThreads=*)
		 argarr["TrimThreads"]="${i#*=}"
		 shift # past argument=value
	;;
		--ILLUMINACLIP=*)
		argarr["ILLUMINACLIP"]="${i#*=}"
		shift # past argument=value
	;;
		--LEADING=*)
		argarr["LEADING"]="${i#*=}"
		shift # past argument=value
	;;
		--TRAILING=*)
		argarr["TRAILING"]="${i#*=}"
		shift # past argument=value
	;;
		--MINLEN=*)
		argarr["MINLEN"]="${i#*=}"
		shift # past argument=value
	;;
		--SLIDINGWINDOW=*)
		argarr["SLIDINGWINDOW"]="${i#*=}"
		shift # past argument=value
	;;
		--BM_multicore=*)
		argarr["BM_multicore"]="${i#*=}"
		shift # past argument=value
	;;
		--BM_seedmm=*)
		argarr["BM_seedmm"]="${i#*=}"
		shift # past argument=value
	;;
		--BM_score_min=*)
		argarr["BM_score_min"]="${i#*=}"
		shift # past argument=value
	;;
		--BM_maxinsert=*)
		argarr["BM_maxinsert"]="${i#*=}"
		shift # past argument=value
	;;
		--BM_directionality=*)
		argarr["BM_directionality"]="${i#*=}"
		shift # past argument=value
	;;
		--BM_bisulfitegenome=*)
		argarr["BM_bisulfitegenome"]="${i#*=}"
		shift
	;;
		--MP_indchr=*)
		argarr["MP_indchr"]="${i#*=}"
		shift
	;;
		--MP_mindepth=*)
		argarr["MP_mindepth"]="${i#*=}"
		shift
	;;
		--MP_hmr_itr=*)
		argarr["MP_hmr_itr"]="${i#*=}"
		shift
	;;
		--MP_pmd_itr=*)
		argarr["MP_pmd_itr"]="${i#*=}"
		shift
	;;
		--MP_hypermr_itr=*)
		argarr["MP_hypermr_itr"]="${i#*=}"
		shift
	;;
		--default)
		DEFAULT=YES
		shift # past argument with no value
	;;
	esac
done

### Test that critical values are reasonable, throw error and exit if something looks off.

if [ $# != 3 ] ; then
	echo -e 'usage: ./test.sh --SampleName=SAMPLENAME --BM_bisulfitegenome=/path/to/bs_genome --MP_indchr=/path/to/methpipe/indchr --read1=/path/to/read1 --read2=/path/to/read2 --ProjectFilesDirectory=/path/to/project\n\t**All arguments must use key=value. Required input is SampleName, BM_bisulfitegenome, MP_indchr, read1, read2, and ProjectFilesDirectory\n'
fi

if [[ -z "${argarr["SampleName"]}" || -z "${argarr["BM_bisulfitegenome"]}" || -z "${argarr["MP_indchr"]}" || -z "${argarr["read1"]}" || -z "${argarr["read2"]}" || -z "${argarr["ProjectFilesDirectory"]}" ]] ; then
	echo "One of the required options is not set! Please check the following have sane values:"
	echo -ne "\tSampleName : "${argarr["SampleName"]}"\n"
	echo -ne "\tBM_bisulfitegenome : "${argarr["BM_bisulfitegenome"]}"\n"
	echo -ne "\tMP_indchr : "${argarr["MP_indchr"]}"\n"
	echo -ne "\tread1 : "${argarr["read1"]}"\n"
	echo -ne "\tread2 : "${argarr["read2"]}"\n"
	echo -ne "\tProjectFilesDirectory : "${argarr["ProjectFilesDirectory"]}"\n"
	exit
fi

# print out options to stout
echo "Options set for the pipeline are:"
for i in "${!argarr[@]}" ; do 
	echo -e "\t" $i ":" "${argarr[$i]}"
done


