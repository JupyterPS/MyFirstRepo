# Step 1: Use the official Jupyter base-notebook as the base image
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

# Step 4: Upgrade pip and install Python dependencies
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install notebook numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Step 5: Install JupyterLab Git and related extensions
RUN python -m pip install jupyterlab-git jupyterlab_github

# Step 6: Install Jupyter themes and additional Python packages
RUN python -m pip install jupyterthemes numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose ipywidgets

# Step 7: Install Tornado
RUN python -m pip install tornado==5.1.1

# Step 8: Install .NET SDK using the official Microsoft script and update PATH
RUN curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 3.1 && \
    echo 'export PATH=/root/.dotnet:/root/.dotnet/tools:$PATH' >> /root/.bashrc

# Step 9: Source the bashrc to update PATH and verify .NET SDK installation
RUN /bin/bash -c "source /root/.bashrc && dotnet --info"

# Step 10: Install .NET Interactive tool
RUN /bin/bash -c "source /root/.bashrc && dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source 'https://dotnet.myget.org/F/dotnet-try/api/v3/index.json'"

# Step 11: Install .NET Interactive Jupyter kernel
RUN /bin/bash -c "source /root/.bashrc && dotnet interactive jupyter install"

# Step 12: Set up the working directory
WORKDIR /home/jovyan

# Step 13: Set up user and home environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

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
WORKDIR ${HOME}/WindowsPowerShell
