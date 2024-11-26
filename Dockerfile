# Base image
FROM jupyter/base-notebook:latest

# Upgrade pip and install dependencies
RUN python -m pip install --upgrade pip
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook
RUN python -m pip install numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose
RUN python -m pip install jupyterlab-git jupyterlab_github
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets
RUN python -m pip install tornado==5.1.1

# Setup working directory and user env variables
WORKDIR /home/jovyan
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# System dependencies
USER root
RUN apt-get update && apt-get install -y libicu-dev curl && apt-get clean

# .NET SDK Installation
RUN curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 3.1
ENV PATH="/root/.dotnet:/root/.dotnet/tools:$PATH"

# Install DotNet.Interactive and Jupyter kernel
RUN /root/.dotnet/dotnet tool install --global Microsoft.dotnet-interactive --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" --version 1.0.155302
RUN /root/.dotnet/dotnet interactive jupyter install

# Copy configuration files and notebooks
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/
COPY ./NuGet.config ${HOME}/nuget.config

# Set file ownership and permissions
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Additional steps
RUN pip install nteract_on_jupyter
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Copy project files and set permissions
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
RUN chown -R ${NB_UID} ${HOME}

# Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/
WORKDIR ${HOME}/WindowsPowerShell
