# Use Jupyter Base Notebook image
FROM jupyter/base-notebook:latest

# Upgrade pip x
RUN python -m pip install --upgrade pip

# Copy and install Python dependencies
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

# Reinstall Jupyter notebook for compatibility
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook

# Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github
RUN jupyter labextension install @jupyterlab/git

# Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets

# Set up the working directory
WORKDIR $HOME

# Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Change to root user to install system dependencies
USER root
RUN apt-get update && \
    apt-get install -y libicu66 curl && \
    apt-get clean

# Install .NET SDK for Jupyter Notebook integration
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_USE_POLLING_FILE_WATCHER=true
ENV NUGET_XMLDOC_MODE=skip
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

# Download and install .NET SDK
RUN dotnet_sdk_version=3.1.200 && \
    curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz && \
    echo "Validating dotnet tarball..." && \
    mkdir -p /usr/share/dotnet && \
    tar -ozxf dotnet.tar.gz -C /usr/share/dotnet && \
    rm dotnet.tar.gz && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Install Jupyter kernel for .NET Interactive
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install

# Copy project files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Set proper permissions for the notebook user
RUN chown -R ${NB_UID} ${HOME}

# Revert to default user
USER ${USER}

# Default working directory for Jupyter
WORKDIR ${HOME}/Notebooks/

