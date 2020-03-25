# Copyright (c) SBB CH
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Kay Fricke <kay.fricke@sbb.ch>"

# Environment
ENV LANG=en_US.utf8
ENV ORACLE_HOME=/usr/lib/oracle/12.2/client64
ENV PATH=$PATH:$ORACLE_HOME/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib
ENV PYTHONPATH=$PYTHONPATH:/home/jovyan/work/rcs-autostabi/modules:/home/jovyan/work/rcs-autostabi/stabi/modules

ADD oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm /tmp/
ADD oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm /tmp/
ADD oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm /tmp/

# Install Oracle Instantclient
USER root
RUN apt-get update \
    && apt-get install -y language-pack-en alien libaio1 \
    && apt-get install -y --no-install-recommends ffmpeg \
    && apt install -y graphviz \
    && locale-gen en_US \
    && alien -i /tmp/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm \
    && alien -i /tmp/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm \
    && alien -i /tmp/oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm \
    && ls -al /usr/lib/oracle \
    && ln -snf /usr/lib/oracle/12.2/client64 /opt/oracle \
    && ls -al /opt/oracle \
    && mkdir -p /opt/oracle/network \
    && ln -snf /etc/oracle /opt/oracle/network/admin \
    && apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && sh -c "echo /opt/oracle/lib > /etc/ld.so.conf.d/oracle-instantclient.conf" \
    && ldconfig

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

RUN locale-gen de_CH.UTF-8

# Install and Setup Eclipse Mat
ARG MAT_VERSION=1.9.2
ARG MAT_BUILD_DATE=20200115
RUN wget -qO- "http://eclipse.mirror.garr.it/eclipse/mat/1.9.2/rcp/MemoryAnalyzer-${MAT_VERSION}.${MAT_BUILD_DATE}-linux.gtk.x86_64.zip" \
    | jar xvf /dev/stdin 
RUN chmod +x /mat/MemoryAnalyzer /mat/ParseHeapDump.sh
RUN apk add --no-cache ttf-dejavu
ENV JAVA_OPTS="-Xmx4096m"

# Install Python 3 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda install --quiet --yes \
	'datacompy==0.6.*' \
	'pytest==*' \
	'SQLAlchemy==1.3.*' \
	'tox==3.14.*' \
	'pytest' && \
    conda install -c conda-forge jupyter_contrib_nbextensions && \
    conda install -c conda-forge voila && \
    conda clean -tipsy 
 
RUN pip install 'splunk-sdk==1.6.3' \
	'cx-Oracle==7.2.*' \
	'colorama' \
	'datefinder==0.7.*' \
	'docutils' \
	'graphviz==0.13.*' \
	'grafanalib==0.5.*' \
	'hypothesis' \
	'jsonify==0.5' \
	'jmxquery==0.5.*' \
	'jarmanifest==1.0.*' \
	'javatools==1.3' \
	'junit-xml' \
	'nbopen' \
	'nbformat==4.4.*' \
	'prometheus-client==0.7.*' \
	'prometheus-http-client==1.0.*' \
	'paramiko' \
	'xmltodict' \
	'feather-format' \
	'networkx' \
	'qgrid' \
	'jira' \
	'jupyterlab-git'

#Activate Notebook Contrib Extenstions
RUN jupyter contrib nbextension install --user  && \
    jupyter labextension install @jupyter-voila/jupyterlab-preview && \
    jupyter labextension install @jupyterlab/git && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
