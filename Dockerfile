# Stage 1: Install .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:3.1 AS dotnet

# Stage 2: Use the Jupyter base-notebook as the base image
FROM jupyter/base-notebook:latest

# Step 1: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 2: Copy and install Python dependencies
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

# Step 3: Reinstall Jupyter notebook for compatibility
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Step 4: Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github

# Step 5: Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets

# Step 6: Install Tornado
RUN python -m pip install tornado==5.1.1

# Step 7: Set up the working directory
WORKDIR /home/jovyan

# Step 8: Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 9: Change to root user to install system dependencies
USER root
RUN apt-get update && apt-get install -y libicu-dev curl && apt-get clean

# Step 10: Copy .NET SDK from the first stage
COPY --from=dotnet /usr/share/dotnet /usr/share/dotnet
COPY --from=dotnet /usr/bin/dotnet /usr/bin/dotnet

# Step 11: Ensure .NET tools are available in PATH
ENV PATH="/usr/share/dotnet:/usr/bin/dotnet:/root/.dotnet:/root/.dotnet/tools:$PATH"

# Step 12: Verify .NET SDK installation
RUN dotnet --info

# Step 13: Install .NET Interactive tool and Jupyter kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" && \
    dotnet interactive jupyter install

# Step 14: Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/
COPY ./NuGet.config ${HOME}/nuget.config

# Step 15: Set file ownership and permissions
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Step 16: Install nteract
RUN pip install nteract_on_jupyter

# Step 17: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 18: Copy project files and set permissions
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
RUN chown -R ${NB_UID} ${HOME}

# Step 19: Set default user and working directory
USER ${USER}
WORKDIR ${HOME}/Notebooks/

# Step 20: Set root to Notebooks
WORKDIR ${HOME}/WindowsPowerShell
