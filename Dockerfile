# Upgrade pip
RUN python -m pip install --upgrade pip

# Copy and install Python dependencies
COPY requirements.txt ./requirements.txt 
RUN python -m pip install -r requirements.txt

# Reinstall Jupyter notebook for compatibility
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Install JupyterLab Git using pip
RUN python -m pip install jupyterlab_git

# Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets

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
RUN apt-get update && apt-get install -y curl
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true[_{{{CITATION{{{_2{Extensions — JupyterLab 4.3.1 documentation - Read the Docs](https://jupyterlab.readthedocs.io/en/stable/user/extensions.html)[_{{{CITATION{{{_3{Extensions — JupyterLab 3.6.8 documentation - Read the Docs](https://jupyterlab.readthedocs.io/en/3.6.x/user/extensions.html)

# Install .NET CLI dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu66 \
        libssl1.1 \
        libstdc++6 \
        zlib1g && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK
RUN dotnet_sdk_version=3.1.301 && \
    curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz && \
    dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' && \
    echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - && \
    mkdir -p /usr/share/dotnet && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet && \
    rm dotnet.tar.gz && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet && \
    dotnet help

# Copy notebooks
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/

# Install additional dependencies
RUN apt-get update && apt-get install -y libicu66 curl && apt-get clean

# Copy packages 
COPY ./NuGet.config ${HOME}/nuget.config

# Install .NET SDK for Jupyter Notebook integration
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

# Set file ownership
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Download and install .NET SDK
RUN dotnet_sdk_version=3.1.200 && \
    curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz && \
    mkdir -p /usr/share/dotnet && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet && \
    rm dotnet.tar.gz && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Install nteract
RUN pip install nteract_on_jupyter

# Install Microsoft.DotNet.Interactive and Jupyter kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install

# Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Copy project files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Set permissions for the notebook user
RUN chown -R ${NB_UID} ${HOME}

# Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Note
