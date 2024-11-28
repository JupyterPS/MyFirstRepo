# Use a specific tag of the Jupyter base-notebook as the base image
FROM jupyter/base-notebook:latest

# Upgrade pip and install required packages, Node.js, and dependencies
USER root
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    curl \
    libicu-dev \
    build-essential \
    wget \
    git \
    sudo

# Install Node.js
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n && \
    chmod +x /usr/local/bin/n && \
    n 14.17.0

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install Python dependencies in smaller chunks to avoid errors
RUN python3 -m pip install notebook numpy spotipy
RUN python3 -m pip install scipy matplotlib ipython jupyter pandas sympy nose

# Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github

# Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes ipywidgets

# Install Tornado
RUN python -m pip install tornado==5.1.1

# Install .NET SDK using the official Microsoft script
RUN curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 3.1

# Manually download and install libssl1.1
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
    dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb

# Verify .NET SDK installation in /home/jovyan/.dotnet
RUN ls -la /home/jovyan/.dotnet && \
    echo "DOTNET SDK installation completed."

# Set the PATH environment variable
ENV PATH="/home/jovyan/.dotnet:/home/jovyan/.dotnet/tools:${PATH}"
ENV DOTNET_ROOT="/home/jovyan/.dotnet"

# Install .NET Interactive tool
RUN /home/jovyan/.dotnet/dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source 'https://dotnet.myget.org/F/dotnet-try/api/v3/index.json'

# Install .NET Interactive Jupyter kernel
RUN /home/jovyan/.dotnet/dotnet interactive jupyter install

# Create directories with correct permissions
RUN mkdir -p /home/jovyan/.local/lib && \
    chown -R jovyan /home/jovyan/.local/lib

# Switch back to jovyan user for installing nteract_on_jupyter
USER jovyan

# Install nteract
RUN pip install --user nteract_on_jupyter

# Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Set up the working directory
WORKDIR /home/jovyan

# Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/
COPY ./NuGet.config ${HOME}/nuget.config

# Set file ownership and permissions
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Copy project files and set permissions
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
RUN chown -R ${NB_UID} ${HOME}

# Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/
WORKDIR ${HOME}/WindowsPowerShell
