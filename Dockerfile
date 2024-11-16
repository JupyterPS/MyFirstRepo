# Step 1: Use the official Jupyter base notebook image
FROM jupyter/base-notebook:latest

# Step 2: Upgrade pip to the latest version
RUN python -m pip install --upgrade pip

# Step 3: Copy requirements.txt into the container
COPY requirements.txt ./requirements.txt

# Step 4: Install Python dependencies from the requirements.txt file
RUN python -m pip install -r requirements.txt

# Step 5: Upgrade JupyterLab to the latest version
RUN python -m pip install --upgrade jupyterlab

# Step 6: Install jupyterlab-git extension for Git integration
RUN python -m pip install jupyterlab-git

# Step 7: Install additional Python libraries (numpy, spotipy, etc.)
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython pandas sympy nose

# Step 8: Install Jupyter extensions and themes
RUN python -m pip install jupyter_contrib_nbextensions ipywidgets jupyterthemes

# Step 9: Update Jupyter configuration to disable build minimization and dev mode
RUN echo "c.LabBuildApp.minimize = False" >> /etc/jupyter/jupyter_config.py && \
    echo "c.LabBuildApp.dev_build = False" >> /etc/jupyter/jupyter_config.py

# Step 10: Build JupyterLab
RUN jupyter lab build

# Step 11: Set the working directory to the user's home directory
WORKDIR $HOME

# Step 12: Install curl and ICU dependencies (with fallback)
RUN apt-get update && apt-get install -y curl libicu-dev || apt-get install -y libicu65

# Step 13: Set environment variables for user and UID
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 14: Set working directory again to HOME
WORKDIR ${HOME}

# Step 15: Switch to root user to perform system-level tasks
USER root

# Additional steps can go here if needed...

# Set the default user to `jovyan` (the Jupyter user)
USER ${NB_USER}

# Expose the default Jupyter port
EXPOSE 8888


# Command to start JupyterLab (default entrypoint)
CMD ["start-notebook.sh"]


