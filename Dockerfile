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

# Step 11: Add Microsoft package repository and install .NET SDK
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-3.1

# Step 12: Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/

# Step 13: Install additional dependencies
RUN apt-get update && apt-get install -y libicu-dev curl && apt-get clean

# Step 14: Copy packages 
COPY ./NuGet.config ${HOME}/nuget.config

# Step 15: Set file ownership
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Step 16: Install nteract
RUN pip install nteract_on_jupyter

# Step 17: Install Microsoft.DotNet.Interactive and Jupyter kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install

# Step 18: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 19: Copy project files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Step 20: Set permissions for the notebook user
RUN chown -R ${NB_UID} ${HOME}

# Step 21: Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/

# Step 22: Set root to Notebooks
WORKDIR ${HOME}/WindowsPowerShell
