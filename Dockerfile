# Step 1: Use the official .NET Core SDK image as the base image for building the .NET components
FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build

# Step 2: Copy the content and restore as distinct layers
WORKDIR /source
COPY . .

# Step 3: Use the Jupyter base-notebook as the base image for the final build
FROM jupyter/base-notebook:latest

# Step 4: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 5: Copy and install Python dependencies
COPY requirements.txt ./requirements.txt 
RUN python -m pip install -r requirements.txt

# Step 6: Reinstall Jupyter notebook for compatibility
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Step 7: Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github

# Step 8: Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets

# Step 9: Install Tornado
RUN python -m pip install tornado==5.1.1

# Step 10: Set up the working directory
WORKDIR /home/jovyan

# Step 11: Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 12: Change to root user to install system dependencies
USER root
RUN apt-get update && apt-get install -y curl
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

# Step 13: Install .NET CLI dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu-dev \
        libssl-dev \
        libstdc++6 \
        zlib1g && rm -rf /var/lib/apt/lists/*

# Step 14: Copy the .NET SDK from the build stage
COPY --from=build /usr/share/dotnet /usr/share/dotnet
COPY --from=build /usr/bin/dotnet /usr/bin/dotnet

# Step 15: Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/

# Step 16: Install additional dependencies
RUN apt-get update && apt-get install -y libicu-dev curl && apt-get clean

# Step 17: Copy packages
COPY ./NuGet.config ${HOME}/nuget.config

# Step 18: Set file ownership
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Step 19: Install nteract
RUN pip install nteract_on_jupyter

# Step 20: Install Microsoft.DotNet.Interactive and Jupyter kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install

# Step 21: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 22: Copy project files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Step 23: Set permissions for the notebook user
RUN chown -R ${NB_UID} ${HOME}

# Step 24: Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/

# Step 25: Set root to Notebooks
WORKDIR ${HOME}/WindowsPowerShell
