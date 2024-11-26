# Use the official Jupyter base-notebook as the base image
FROM jupyter/base-notebook:latest

# Upgrade pip and install required packages, Node.js, and dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    curl \
    libicu-dev \
    build-essential \
    wget \
    libssl-dev \
    git \
    sudo \
    && curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n \
    && chmod +x /usr/local/bin/n \
    && n 14.17.0 \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install notebook numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github

# Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets

# Install Tornado
RUN python -m pip install tornado==5.1.1

# Set up the working directory
WORKDIR /home/jovyan

# Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Change to root user to install system dependencies
USER root

# Install .NET SDK using the official Microsoft script
RUN curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 3.1

# Ensure .NET tools are available in PATH
ENV PATH="/root/.dotnet:/root/.dotnet/tools:$PATH"

# Install .NET Interactive tool and Jupyter kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" && \
    dotnet interactive jupyter install

# Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/
COPY ./NuGet.config ${HOME}/nuget.config

# Set file ownership and permissions
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Install nteract
RUN pip install nteract_on_jupyter

# Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Copy project files and set permissions
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
RUN chown -R ${NB_UID} ${HOME}

# Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/
WORKDIR ${HOME}/WindowsPowerShell
