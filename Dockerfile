# Step 1: Use the Jupyter base notebook image
FROM jupyter/base-notebook:latest

# Step 2: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 3: Copy the requirements.txt file
COPY requirements.txt ./requirements.txt

# Step 4: Install dependencies from requirements.txt
RUN python -m pip install -r requirements.txt

# Step 5: Install JupyterLab and JupyterLab extensions
RUN python -m pip install --upgrade jupyterlab
RUN python -m pip install jupyterlab-git

# Step 6: Install other common libraries for data science
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython pandas sympy nose
RUN python -m pip install jupyter_contrib_nbextensions ipywidgets jupyterthemes

# Step 7: Configure JupyterLab settings
RUN echo "c.LabBuildApp.minimize = False" >> /etc/jupyter/jupyter_config.py && \
    echo "c.LabBuildApp.dev_build = False" >> /etc/jupyter/jupyter_config.py

# Step 8: Build JupyterLab extensions
RUN jupyter lab build

# Step 9: Set working directory to $HOME
WORKDIR $HOME

# Step 10: Install curl and ICU dependencies as root user (fix permissions issue)
USER root
RUN apt-get update && apt-get install -y curl libicu-dev || apt-get install -y libicu65

# Step 11: Install PowerShell and the PowerShell Kernel
RUN apt-get update && apt-get install -y wget apt-transport-https software-properties-common \
    && wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y powershell \
    && pwsh -Command "Install-Module -Name PowerShellJupyterKernel -Force -Scope CurrentUser" \
    && pwsh -Command "Import-Module -Name PowerShellJupyterKernel; Install-PowerShellKernel" \
    && rm packages-microsoft-prod.deb

# Step 12: Set the correct user and home directory
USER jovyan
ENV HOME /home/${NB_USER}

# Step 13: Set the default working directory to home directory
WORKDIR ${HOME}


