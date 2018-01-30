#!/bin/bash

#$ -j y
#$ -l m_mem_free=5G
#$ -pe threads 16

### This script can be executed on mass via a parallel qsub and ParameterFile or one sample at a time by reading in appropriate arguments. Required are 'SampleName' 'read1' 'read2' 'ProjectFilesDirectory' 'BM_bisulfitegenome' and 'MP_indchr'

#Define path for all executable.

trimmomatic=$HOME/bin/Trimmomatic-0.32/trimmomatic-0.32.jar

declare -A argarr
### Define default values that we can and put in argarr
#SampleName= ### Required
#read1= ### Required
#read2= ### Required
#ProjectFilesDirectory= ### Required
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
		--SRAacc=*)
		argarr["SRAacc"]="${i#*=}"
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
        echo -e 'usage: ./test.sh --SampleName=SAMPLENAME --BM_bisulfitegenome=/path/to/bs_genome --MP_indchr=/path/to/methpipe/indchr ( --read1=/path/to/read1 --read2=/path/to/read2 ) | ( --SRAacc=SRR##### ) --ProjectFilesDirectory=/path/to/project\n\t**All arguments must use key=value. Required input is SampleName, BM_bisulfitegenome, MP_indchr, read1, read2, and ProjectFilesDirectory\n'
fi

if [[ -z "${argarr["SampleName"]}" || -z "${argarr["BM_bisulfitegenome"]}" || -z "${argarr["MP_indchr"]}" || -z "${argarr["ProjectFilesDirectory"]}" ]] ; then
        echo "One of the required options is not set! Please check the following have sane values:"
        echo -ne "\tSampleName="${argarr["SampleName"]}"\n"
        echo -ne "\tBM_bisulfitegenome="${argarr["BM_bisulfitegenome"]}"\n"
        echo -ne "\tMP_indchr="${argarr["MP_indchr"]}"\n"
        echo -ne "\tProjectFilesDirectory="${argarr["ProjectFilesDirectory"]}"\n"
        exit
fi

if [[ -n "${argarr["read1"]}" && -n "${argarr["read2"]}" ]] ; then
	rawreadprovided=1
fi
if [[ -n "${argarr["SRAacc"]}" ]] ; then
	SRAaccprovided=1
fi

if [[ ( -z ${rawreadprovided} && -z ${SRAaccprovided} ) || ( -n $rawreadprovided && -n $SRAaccprovided ) ]]; then 
	echo "Please provide paths to either paired reads (--read1=/path/to/read1 --read2=/path/to/read2) OR an SRA accession number (SRR1234567). Set values were:"
        echo -ne "\tread1="${argarr["read1"]}"\n"
        echo -ne "\tread2="${argarr["read2"]}"\n"
	echo -ne "\tSRRacc="${argarr["SRAacc"]}"\n"
	exit
fi

if [ ! -d "${argarr["BM_bisulfitegenome"]}"/Bisulfite_Genome/ ] ; then
	echo -ne ""${argarr["BM_bisulfitegenome"]}" does not seem to be a bismark generated reference genome directory. Please check this directory!\n\n"
	exit
fi

for chr in $( grep ">" "${argarr["BM_bisulfitegenome"]}"/*.fa | sed 's/>//g' ) ; do
	if [ ! -e "${argarr["MP_indchr"]}"$chr.fa ] ; then
		echo -ne "Did not find individual chromosome: "${argarr["MP_indchr"]}"$chr.fa. \n\tIs this the correct directory? Individual chromosome fasta files should be named CHROMOSOMEID.fa\n\n"
		exit
	fi
done

# print out options to stout
echo "Options set for the pipeline are:"
for i in "${!argarr[@]}" ; do
        echo -e "\t" $i ":" "${argarr[$i]}"
done

echo " ----- TRANSFERRING READS FROM SRA/LOCAL ----- " ; date

# fastq-dump files if needed
### NOTE ###
# If you need to prefetch with wget it is annoying as hell to find the path
# general construct is: ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/{SRR|ERR|DRR}/<first 6 characters of accession>/<accession>/<accession>.sra
# So for example for SRR4013317 your path is: ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR401/SRR4013317/SRR4013317.sra
## Fetch the sra file...

if [[ $SRAaccprovided -eq 1 ]] ; then
	echo -ne "checking SampleName syntax..." ; 
	if [[ "$SampleName" =~ ^SRR[0-9]{7}$ ]] ; then 
		echo -ne "correct\n\n" ; 
	else 
		echo -ne "incorrect SRA accession format, should be SRR[0-9]{7,}. Please check.\n\n"
		exit 1
	fi
firstsix=${SampleName:0:6}
wget -c -q -O "$TMPDIR"/"$SampleName".sra ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/"$firstsix"/"$SampleName"/"$SampleName".sra
## Dump reads to split fastq.gz in the TMPDIR.
echo " -----  fastq-dump fastq.gz files for $SampleName  ----- " ; date
fastq-dump -O "$TMPDIR" --split-files --gzip "$TMPDIR"/"$SampleName".sra
fi

# Trim reads 
##### NOTE ##### If you prefetched the SRA into temp space and dumped there need to make it "$TMPDIR"/"$read1"
java -jar "$trimmomatic" PE -threads "$TrimThreads "$TMPDIR"/"$read1" "$TMPDIR"/"$read2" "$TMPDIR"/"$SampleName"_P1.fastq "$TMPDIR"/"$SampleName"_U1.fastq "$TMPDIR"/"$SampleName"_P2.fastq "$TMPDIR"/"$SampleName"_U2.fastq ILLUMINACLIP:"$ILLUMINACLIP" LEADING:"$LEADING" TRAILING:"$TRAILING" MINLEN:"$MINLEN" TOPHRED33

#Run fastqc on the trimmed files...
echo " ----- Starting fastqc on the trimmed files ----- " ; date
mkdir -p ./fastqc
$HOME/bin/FastQC/fastqc -o ./fastqc "$TMPDIR"/*.fastq

#Run bismark on the files...
echo " ----- Aligning reads with bismark ----- " ; date
mkdir -pv "$ProjectFilesDirectory"
### NOTE ###
# the multicore argument is misleading, as it launches X number of bismark instances, each of which launches 2 (directional) or 4 (non-directional) bowtie2 processes. So the real number of threads to request in the job should be
# --multicore * 2|4 bowtie2 threads (dir|ndir) + --multicore (number of bismark instances launched) + 2 extra for random gzip, samtools needs.
### NOTE ###
$HOME/bin/bismark_v0.18.0/bismark --multicore "$BM_multicore" -N "$BM_seedmm" --score_min "$BM_score_min" -q -X "$BM_maxinsert" "$BM_directionality" --temp_dir "$TMPDIR" -o  "$ProjectFilesDirectory" "$BM_bisulfitegenome" -1 "$TMPDIR"/"$SampleName"_P1.fastq -2 "$TMPDIR"/"$SampleName"_P2.fastq 

#methpipe!

# first step converting the bam files to methpipe format
echo " ----- Converting bam files to methpipe format with to-mr ----- " ; date
to-mr -o "$TMPDIR"/"$SampleName".mr -m bismark "$ProjectFilesDirectory"/"$SampleName"_P1_bismark_bt2_pe.bam

# Next step sort the reads before removing duplications
echo " ----- Sorting the mr file with sort ----- " ; date
LC_ALL=C sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 -o "$TMPDIR"/"$SampleName"_sorted.mr "$TMPDIR"/"$SampleName".mr

# Next step remove duplicate reads
echo " ----- Removing duplicates with duplicate-remover ----- " ; date
duplicate-remover -S "$ProjectFilesDirectory"/"$SampleName"_dremove_stat.txt -o "$TMPDIR"/"$SampleName"_dremove.mr "$TMPDIR"/"$SampleName"_sorted.mr

# Next step: Computing single-site methylation levels
echo " ----- Counting methylation with methcounts ----- " ; date
methcounts -c "$MP_indchr" -o "$ProjectFilesDirectory"/"$SampleName".meth  -v "$TMPDIR"/"$SampleName"_dremove.mr

# Next step estimation of the bisulfite conversion rate
echo " ----- Calculating bisulfite conversion rate ----- " ; date
bsrate -o "$ProjectFilesDirectory"/"$SampleName".bsrate -c "$MP_indchr" -v "$TMPDIR"/"$SampleName"_dremove.mr
echo "Done calculating bisulfite conversion rate..."

# Next Step: Filtering low coverage Cs - the methpipe group recommend at least coverage of X10, JS is checking for at least 5, i think we should aim for X8 coverage... 
echo " ----- Filtering low coverage ----- " ; date
awk -v mindepth="$MP_mindepth" -F "\t" '$6 >= mindepth  { print $0 }' "$ProjectFilesDirectory"/"$SampleName".meth > "$ProjectFilesDirectory"/"$SampleName"_cov.meth
echo "Done removing low coverage methylation..."

# Next step: Finding HypoMethylated regions
echo " ----- calculate hypomethylated regions ----- " ; date
hmr -o "$ProjectFilesDirectory"/"$SampleName".hmr -i "$MP_hmr_itr" -v "$ProjectFilesDirectory"/"$SampleName"_cov.meth
echo "Done calculating hypomethylated regions..."

# Next step: Finding partial hypomethylated regions
echo " ----- calculate partial hypomethylated regions ----- " ; date
pmd  -o "$ProjectFilesDirectory"/"$SampleName".pmd -v -i "$MP_pmd_itr" "$ProjectFilesDirectory"/"$SampleName"_cov.meth
echo "Done calculating partial hypomethylated regions..."

# The last step Finding hypermethylated regions
echo " ----- Finding hypermr ----- " ; date
hypermr  -o "$ProjectFilesDirectory"/"$SampleName"_cov.hypermr -i "$MP_hypermr_itr" -v "$ProjectFilesDirectory"/"$SampleName"_cov.meth
echo "Done calculating hypermethylated regions..."

echo " ----- RUN ENDED AT  ----- " ; date

## In the next we can compare the methylation between two genomes and find DMR's. I think that should be done in a different file. 

