ARG osversion=v1.0.0
FROM chloroextractorteam/chloroextractor-dockerbase:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE
ARG CHLOROEXTRACTORVERSION=v1.0.5

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}", chloroExtractor version:"${CHLOROEXTRACTORVERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing our screening tools for new chloroplasts" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/screening_container.git"

### Setup additional software required by the software
RUN apt update && \
    apt --yes install \
       wget \
       git \
       python \
       parallel \
       bzip2 && \
    apt --yes autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

### Setup of sratools to retrieve SRA datasets
WORKDIR /opt/
RUN wget -O - https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz | \
    tar xzf - && \
    ln -s sratoolkit* sratoolkit
ENV PATH "/opt/sratoolkit/bin/:${PATH}"

### Setup fast-plast
### Install required software
RUN apt update && \
    apt --yes install \
       wget \
       git \
       python \
       default-jre \
       unzip \
       build-essential \
       libz-dev \
       ncbi-blast+ && \
    apt --yes autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

WORKDIR /opt/
RUN git clone https://github.com/mrmckain/fast-plast.git && \
    cd fast-plast && \
    git checkout fefdf462cab66d9de39023ee7d04ca13ed637950 && \
    echo -e "n\nall" | \
    perl INSTALL.pl && \
    chmod +x fast-plast.pl
ENV PATH="/opt/fast-plast/:${PATH}"

### Installation of fastq-shuffle
WORKDIR /opt/
RUN wget -O - https://github.com/chloroExtractorTeam/fastq-shuffle/archive/v0.9.1.tar.gz | \
    tar xzf - && \
    ln -s fastq-shuffle-0.9.1 fastq-shuffle
ENV PATH="/opt/fastq-shuffle/:${PATH}"

### Installation of chloroExtractor
RUN git clone --recursive \
              --branch ${CHLOROEXTRACTORVERSION} \
        https://github.com/chloroExtractorTeam/chloroExtractor.git \
        /opt/chloroExtractor/ && \
    rm -rf /opt/chloroExtractor/.git
ENV PATH "/opt/chloroExtractor/bin/:$PATH"

### Add runner script
ADD run.sh /usr/local/bin/run.sh

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data

### Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]
