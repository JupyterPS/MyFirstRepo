# Step 1: Use a specific tag of the Jupyter base-notebook as the base image
FROM jupyter/base-notebook:latest

# Step 2: Upgrade pip and install required packages, Node.js, and dependencies
USER root
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    curl \
    libicu-dev \
    build-essential \
    wget \
    libssl-dev \
    git \
    sudo

# Step 3: Install Node.js
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n && \
    chmod +x /usr/local/bin/n && \
    n 14.17.0

# Step 4: Upgrade pip
RUN python3 -m pip install --upgrade pip

# Step 5: Install Python dependencies in smaller chunks to avoid errors
RUN python3 -m pip install notebook numpy spotipy
RUN python3 -m pip install scipy matplotlib ipython jupyter pandas sympy nose

# Step 6: Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github

# Step 7: Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes ipywidgets

# Step 8: Install Tornado
RUN python -m pip install tornado==5.1.1

# Step 9: Install .NET SDK using the official Microsoft script and alternative download links
RUN curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 3.1 || \
    (echo 'Attempting alternative download link...' && \
     curl -L https://dotnetcli.azureedge.net/dotnet/Sdk/3.1.426/dotnet-sdk-3.1.426-linux-x64.tar.gz -o dotnet-sdk.tar.gz && \
     mkdir -p /usr/share/dotnet && \
     tar -zxf dotnet-sdk.tar.gz -C /usr/share/dotnet && \
     ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet)

# Step 10: Set the PATH environment variable
ENV PATH="/root/.dotnet:/root/.dotnet/tools:/usr/share/dotnet:${PATH}"

# Step 11: Verify .NET SDK installation
RUN dotnet --info

# Step 12: Install .NET Interactive tool
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source 'https://dotnet.myget.org/F/dotnet-try/api/v3/index.json'

# Step 13: Install .NET Interactive Jupyter kernel
RUN dotnet interactive jupyter install

# Step 14: Set up the working directory
WORKDIR /home/jovyan

# Step 15: Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 16: Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/
COPY ./NuGet.config ${HOME}/nuget.config

# Step 17: Set file ownership and permissions
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Step 18: Install nteract
RUN pip install nteract_on_jupyter

# Step 19: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 20: Copy project files and set permissions
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
RUN chown -R ${NB_UID} ${HOME}

# Step 21: Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/
WORKDIR ${HOME}/WindowsPowerShell
