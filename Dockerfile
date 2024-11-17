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

# Step 9: Install curl, ICU dependencies, and dotnet interactive
USER root
RUN apt-get update && apt-get install -y wget apt-transport-https software-properties-common curl libicu-dev || apt-get install -y libicu65

# Install .NET SDK and dotnet-interactive
RUN wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel LTS && \
    export PATH="/root/.dotnet:/root/.dotnet/tools:$PATH" && \
    dotnet --info && \
    dotnet tool install -g Microsoft.dotnet-interactive && \
    dotnet interactive jupyter install

# Step 10: Set the correct user and home directory
USER jovyan
ENV HOME /home/${NB_USER}

# Step 11: Set the default working directory to home directory
WORKDIR ${HOME}
