#!/bin/bash

#copy all the files we need into ./BPSM/MyFirstPipeline directory
cp /localdisk/data/BPSM/MyFirstPipeline/fastq . -r

cp /localdisk/data/BPSM/MyFirstPipeline/Tcongo_genome . -r

cp /localdisk/data/BPSM/MyFirstPipeline/TriTrypDB-46_TcongolenseIL3000_2019.bed . -r

#change directory to MyFirstPipeline
cd ./MyFirstPipeline

#make a directory for the fastqc outputs as it will not create one for you
mkdir fastqc_outputs

#run the fastqc programme on all files within the fastq directory that end with “.fq.gz” and put the outputs in our new directory
#this takes a few minutes
#to turn off the status reports, add -q at the end (it will run “quietly”)
fastqc ./fastq/*.fq.gz -o fastqc_outputs

#let’s check what’s in our fastqc_outputs directory
ls fastqc_outputs

#it seems like we have one .zip and one .html file for each sequence
#let’s count how many .zip files we have in fastqc_outputs
ls fastqc_outputs/*.zip | wc -l
#96

#let’s count how many .html files we have in fastqc_outputs
ls fastqc_outputs/*.html | wc -l
#96
#so we know they match

#let’s double check that this matches with our original “.fq.gz” files
ls fastq/*.fq.gz | wc -l 
#96
#great! they all match

#you can open individual html files by:
open fastqc_outputs/Tco-106_1_fastqc.html
#this will give you information about the quality control

#make a directory called index
mkdir index

#unzip reference sequence
gunzip ./Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta.gz                   
#this changes the file from .fasta.gz to .fasta

#build index using bowtie2 for our reference sequence
#this takes about half a minute
bowtie2-build ./Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta ./index/Tcongo

#check that we got the .bt2 files in the index directory
ls index

#make a directory for the aligned reads
mkdir aligned_reads

#align reads to the reference genome using bowtie2
#this takes quite a few minutes so grab your popcorn ig (not that there’s anything but the cursor to watch)
bowtie2 -x index/Tcongo -1 ./fastq/*_1.fq.gz -2 ./fastq/*_2.fq.gz -S aligned_reads/Tcongo.sam --threads 8

#.sam files are very large, so to save space, usually they are converted to .bam files
#convert ./aligned_reads/Tcongo.sam into a .bam file using samtools
samtools view -b -o ./aligned_reads/Tcongo.bam ./aligned_reads/Tcongo.sam

#check that you have generated a .bam file in the correct directory
ls aligned_reads

#generate counts data using bedtools and put the outputs in a new file called generated_counts
#the intersected counts are on the 5th field
bedtools intersect -a TriTrypDB-46_TcongolenseIL3000_2019.bed -b ./aligned_reads/Tcongo.bam -c > generated_counts
