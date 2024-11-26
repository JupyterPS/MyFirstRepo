# Step 1: Use a stable base image that includes the .NET SDK and runtime
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS base

# Step 2: Use the Jupyter base-notebook as the secondary base image
FROM jupyter/base-notebook:latest AS jupyter

# Step 3: Copy .NET SDK from the base image
COPY --from=base /usr/share/dotnet /usr/share/dotnet
COPY --from=base /usr/bin/dotnet /usr/bin/dotnet
COPY --from=base /usr/bin/host /usr/bin/host
COPY --from=base /usr/bin/host/fxr /usr/bin/host/fxr

# Step 4: Upgrade pip and install Python dependencies
RUN python -m pip install --upgrade pip
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose
RUN python -m pip install jupyterlab-git jupyterlab_github
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets
RUN python -m pip install tornado==5.1.1

# Step 5: Set up the working directory
WORKDIR /home/jovyan

# Step 6: Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 7: Change to root user to install system dependencies
USER root
RUN apt-get update && apt-get install -y libicu-dev curl && apt-get clean

# Step 8: Install Microsoft.DotNet.Interactive and Jupyter kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install

# Step 9: Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/
COPY ./NuGet.config ${HOME}/nuget.config

# Step 10: Set file ownership
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Step 11: Install nteract
RUN pip install nteract_on_jupyter

# Step 12: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 13: Copy project files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Step 14: Set permissions for the notebook user
RUN chown -R ${NB_UID} ${HOME}

# Step 15: Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/

# Step 16: Set root to Notebooks
WORKDIR ${HOME}/WindowsPowerShell
