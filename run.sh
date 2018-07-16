#!/bin/bash

ACCESSION=${1}
CPUCORES=${2:-16}
RANDOMSEED=${3:-556854669}

echo "ACCESSION: ${ACCESSION}, RANDOMSEED: ${RANDOMSEED}, CPUCORES: ${CPUCORES}"

export LC_ALL="C.UTF-8"

### Downloading
time prefetch --progress --max-size=100G --verbose ${ACCESSION}

if [ ! -e $(srapath ${ACCESSION}) ]
then
    echo "ERROR DOWNLOADING ${ACCESSION}">&2
    exit 1;
fi

### Converting
time fastq-dump --outdir ${ACCESSION} --split-files -v ${ACCESSION}

if [ ! -e ${ACCESSION}/${ACCESSION}_1.fastq ]
then
    echo "ERROR CONVERTING ${ACCESSION}">&2
    exit 2;
fi

if [ ! -e ${ACCESSION}/${ACCESSION}_2.fastq ]
then
    echo "ERROR CONVERTING ${ACCESSION}">&2
    exit 2;
fi

cd ${ACCESSION}
time fastq-shuffle.pl --randomseed ${RANDOMSEED} -1 ${ACCESSION}_1.fastq -2 ${ACCESSION}_2.fastq

time ptx --threads ${CPUCORES} -1 ${ACCESSION}_1.fastq.shuffled -2 ${ACCESSION}_2.fastq.shuffled -d CE_${ACCESSION}_out

time fast-plast.pl -1 ${ACCESSION}_1.fastq.shuffled -2 ${ACCESSION}_2.fastq.shuffled --name FP_${ACCESSION}_out --coverage_analysis --threads ${CPUCORES}
