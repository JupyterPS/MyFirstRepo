# Step 1: Use the Jupyter base-notebook as the base image
FROM jupyter/base-notebook:latest

# Step 2: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 3: Copy and install Python dependencies
COPY requirements.txt ./requirements.txt 
RUN python -m pip install -r requirements.txt

# Step 4: Reinstall Jupyter notebook for compatibility
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Step 5: Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github

# Step 6: Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets

# Step 7: Install Tornado
RUN python -m pip install tornado==5.1.1

# Step 8: Set up the working directory
WORKDIR /home/jovyan

# Step 9: Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 10: Change to root user to install system dependencies
USER root
RUN apt-get update && apt-get install -y curl
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

# Step 11: Install .NET CLI dependencies and OpenSSL
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu-dev \
        libssl-dev \
        libstdc++6 \
        zlib1g \
    && ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/x86_64-linux-gnu/libssl1.1.so.1.1 \
    && rm -rf /var/lib/apt/lists/*

# Step 12: Install .NET Core SDK
RUN dotnet_sdk_version=3.1.301 && \
    curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz && \
    dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' && \
    echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - && \
    mkdir -p /usr/share/dotnet && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet && \
    rm dotnet.tar.gz && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet && \
    dotnet help

# Step 13: Copy notebooks
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/

# Step 14: Install additional dependencies
RUN apt-get update && apt-get install -y libicu-dev curl && apt-get clean

# Step 15: Copy packages 
COPY ./NuGet.config ${HOME}/nuget.config

# Step 16: Set file ownership
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Step 17: Download and install .NET SDK
RUN dotnet_sdk_version=3.1.200 && \
    curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz && \
    mkdir -p /usr/share/dotnet && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet && \
    rm dotnet.tar.gz && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Step 18: Install nteract
RUN pip install nteract_on_jupyter

# Step 19: Install Microsoft.DotNet.Interactive and Jupyter kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install

# Step 20: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 21: Copy project files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Step 22: Set permissions for the notebook user
RUN chown -R ${NB_UID} ${HOME}

# Step 23: Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/

# Step 24: Set root to Notebooks
WORKDIR ${HOME}/WindowsPowerShell
