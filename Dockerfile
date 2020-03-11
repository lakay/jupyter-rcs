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
	'colorama==0.4.*' \
	'cx-Oracle==7.2.*' \
	'datacompy==0.6.*' \
	'datashader==0.8.*' \
	'datashape==0.5.*' \
	'datefinder==0.7.*' \
	'dateparser==0.7.*' \
	'defusedxml==0.6.*' \
	'docutils==0.14' \
	'feather-format==0.4.*' \
	'GitPython==3.0.*' \
	'grafanalib==0.5.*' \
	'graphviz==0.13.*' \
	'hypothesis==4.55.*' \
	'idna==2.6' \
	'imagesize==1.0.0' \
	'jarmanifest==1.0.*' \
	'javatools==1.3' \
	'jira==2.0.*' \
	'jira-python==0.2.*' \
	'jmespath==0.9.3' \
	'jmxquery==0.5.*' \
	'json5==0.8.*' \
	'jsonify==0.5' \
	'jsonschema==3.1.*' \
	'joypy==0.2.*' \
	'junit-xml==1.8' \
	'lxml==4.4.*' \
	'mccabe==0.6.1' \
	'missingno==0.4.*' \
	'more-itertools==4.1.*' \
	'mplleaflet==0.0.*' \
	'mpmath==1.0.0' \
	'nbconvert==5.6.*' \
	'nbdime==1.*' \
	'nbformat==4.4.*' \
	'nbopen==0.6*' \
	'nbparameterise==0.3*' \
	'networkx==2.4*' \
	'papermill==1.2.*' \
	'paramiko==2.4.1' \
	'pefile==2017.11.5' \
	'prometheus-client==0.7.*' \
	'prometheus-http-client==1.0.*' \
	'pyflakes==1.6.0' \
	'pytest==3.5.1' \
	'python-dateutil==2.8*' \
	'PyYAML==5.1.*' \
	'smmap2==2.0.3' \
	'snowballstemmer==1.2.1' \
	'Sphinx==2.2.*' \
	'SQLAlchemy==1.3.*' \
	'sphinxcontrib-websupport==1.1.*' \
	'tox==3.14.*' \
	'tqdm==4.23.4' \
	'pytest==3.5*'  \
	'urllib3==1.25.*' \
	'voila==0.1.*' \
	'voila-gridstack==0.0.*' \
	'wcwidth==0.1.*' \
	'webencodings==0.5.*' \
	'Werkzeug==0.16.*' \
	'XlsxWriter==1.2.*' \
	'xmltodict==0.12.*' && \
    conda install -c conda-forge jupyter_contrib_nbextensions && \
    conda remove --quiet --yes --force qt pyqt && \
    conda clean -tipsy 
 
    #Activate Notebook Contrib Extenstions
 RUN jupyter contrib nbextension install --user  && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
