# Step 1: Use a stable base image that includes the .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:3.1 AS base

# Step 2: Use the Jupyter base-notebook as the secondary base image
FROM jupyter/base-notebook:latest AS jupyter

# Step 3: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 4: Copy and install Python dependencies
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

# Step 5: Reinstall Jupyter notebook for compatibility
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Step 6: Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github

# Step 7: Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets

# Step 8: Install Tornado
RUN python -m pip install tornado==5.1.1

# Step 9: Set up the working directory
WORKDIR /home/jovyan

# Step 10: Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 11: Change to root user to install system dependencies
USER root
RUN apt-get update && apt-get install -y libicu-dev curl && apt-get clean

# Step 12: Copy .NET SDK from the base image
COPY --from=base /usr/share/dotnet /usr/share/dotnet
COPY --from=base /usr/bin/dotnet /usr/bin/dotnet

# Step 13: Install Microsoft.DotNet.Interactive and Jupyter kernel
RUN /usr/bin/dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
ENV PATH="${PATH}:/root/.dotnet/tools"
RUN /usr/bin/dotnet interactive jupyter install

# Step 14: Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/
COPY ./NuGet.config ${HOME}/nuget.config

# Step 15: Set file ownership
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Step 16: Install nteract
RUN pip install nteract_on_jupyter

# Step 17: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 18: Copy project files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Step 19: Set permissions for the notebook user
RUN chown -R ${NB_UID} ${HOME}

# Step 20: Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/

# Step 21: Set root to Notebooks
WORKDIR ${HOME}/WindowsPowerShell
