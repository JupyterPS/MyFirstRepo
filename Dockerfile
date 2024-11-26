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
RUN apt-get update && apt-get install -y libicu-dev curl && apt-get clean

# Step 11: Install .NET SDK using the official Microsoft script
RUN curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 3.1

# Step 12: Add .dotnet/tools to PATH for the installation session
ENV PATH="/root/.dotnet:/root/.dotnet/tools:$PATH"

# Step 13: Install .NET Interactive tool
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Step 14: Verify dotnet and dotnet-interactive installations
RUN echo $PATH && ls -la /root/.dotnet/tools && dotnet --info && dotnet-interactive --version

# Step 15: Install .NET Interactive Jupyter kernel
RUN dotnet interactive jupyter install

# Step 16: Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/WindowsPowerShell/
COPY ./NuGet.config ${HOME}/nuget.config

# Step 17: Set file ownership and permissions
RUN chown -R ${NB_UID} ${HOME}

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

# Step 22: Set root to Notebooks
WORKDIR ${HOME}/WindowsPowerShell
