ARG osversion=v1.0.0
FROM chloroextractorteam/chloroextractor-dockerbase:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

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

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
