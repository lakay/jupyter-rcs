# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/datascience-notebook

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
    && apt-get -y install language-pack-en alien libaio1 \
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
    && sh -c "echo /opt/oracle/instantclient_12_2 > /etc/ld.so.conf.d/oracle-instantclient.conf" \
    && ldconfig

# Install Python 3 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda install --quiet --yes \
	'altgraph==0.15' \
	'astcheck==0.2*' \
	'attrs==18.1*' \
	'Babel==2.5*' \
	'bcrypt==3.1*' \
	'boto3==1.7.28' \
	'botocore==1.10.28' \
	'click==6.7' \
	'colorama==0.3.9' \
	'docutils==0.14' \
	'flake8==3.5.0' \
	'future==0.16.0' \
	'gitdb2==2.0.3' \
	'GitPython==2.1.10' \
	'idna==2.6' \
	'imagesize==1.0.0' \
	'jmespath==0.9.3' \
	'lxml==4.2.1' \
	'mccabe==0.6.1' \
	'missingno==0.4.0' \
	'more-itertools==4.1.0' \
	'mplleaflet==0.0.5' \
	'mpmath==1.0.0' \
	'nbdime==1.0.1' \
	'paramiko==2.4.1' \
	'pefile==2017.11.5' \
	'pyflakes==1.6.0' \
	'pytest==3.5.1' \
	'smmap2==2.0.3' \
	'snowballstemmer==1.2.1' \
	'Sphinx==1.7.4' \
	'sphinxcontrib-websupport==1.0.1' \
	'tqdm==4.23.4' \
	'pytest==3.5*'  && \
    conda install -c conda-forge jupyter_contrib_nbextensions && \
    conda remove --quiet --yes --force qt pyqt && \
    conda clean -tipsy 

RUN pip install 'splunk-sdk==1.6.3' \
	'pyreadline==2.1' \
	'atlassian-python-api==1.6.0' \
	'libkeepass==0.3.0' \
	'nbparameterise==0.3' \
	'tox==3.0.0' \
	'textwrap3==0.9.1' \
	'jupyter-highlight-selected-word==0.2.0' \
	'papermill==0.12.6' \
	'astsearch==0.1.3' \
	'jupyter-latex-envs==1.4.4' \
	'pycryptodome==3.6.1' \
	'ansiwrap==0.8.3' \
	'graphviz==0.8.3' \
	'jupyter-nbextensions-configurator==0.4.0' \
	'macholib==1.9' \
	'pyreadline==2.1' \
	'cx-Oracle==6.3.1' 
 
    #Activate Notebook Contrib Extenstions
 RUN jupyter contrib nbextension install --user  && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

