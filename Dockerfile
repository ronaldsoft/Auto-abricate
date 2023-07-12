FROM continuumio/miniconda3:latest

ARG HOME=/root
ARG FolderInput=${HOME}/input
ARG FolderOutput=${HOME}/output
ARG FolderProcessed=${HOME}/processed
ENV FolderInputEnv=${HOME}/input
ENV FolderOutputEnv=${HOME}/output
ENV FolderProcessedEnv=${HOME}/processed

#update libs systems
RUN apt-get update && apt-get -y upgrade

# requiered extra libs
RUN apt-get install -y bioperl ncbi-blast+ gzip unzip git \
  libjson-perl libtext-csv-perl libpath-tiny-perl liblwp-protocol-https-perl libwww-perl

# install any2fasta
RUN cd /usr/local/bin && \
    wget https://raw.githubusercontent.com/tseemann/any2fasta/master/any2fasta && \
    chmod +x any2fasta

# install abrigrate
RUN cd /root/ && git clone https://github.com/tseemann/abricate.git && \
    cp -r /root/abricate/db /usr/local/ && \
    cp /root/abricate/bin/abricate /usr/local/bin && \
    chmod +x /usr/local/bin/abricate

#valid libraries and include dbs
RUN abricate --check && abricate --setupdb

# create folders to mirror volume
RUN mkdir $FolderInput $FolderOutput $FolderProcessed && \
    chmod 777 $FolderInput $FolderOutput $FolderProcessed

# ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
# ENTRYPOINT ["tail"]
# CMD ["-f","/dev/null"]

COPY entrypoint.sh $HOME/

#Grant all execution permissions
RUN chmod +x $HOME/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
CMD [$FolderInput,  $FolderOutput, $FolderProcessed]