FROM jupyter/base-notebook:latest

# Step 1: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 2: Copy the requirements.txt into the image
COPY requirements.txt ./requirements.txt

# Step 3: Install dependencies from requirements.txt
RUN python -m pip install -r requirements.txt

# Step 4: Install JupyterLab and Git extension via pip (Recommended approach)
RUN python -m pip install --upgrade jupyterlab
RUN python -m pip install jupyterlab-git

# Step 5: Install other dependencies
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython pandas sympy nose

# Step 6: Install other JupyterLab extensions (if needed)
RUN python -m pip install jupyter_contrib_nbextensions ipywidgets jupyterthemes

# Step 7: Create a custom Jupyter config file to disable minimize and dev-build options
RUN echo "c.LabBuildApp.minimize = False" >> /etc/jupyter/jupyter_config.py && \
    echo "c.LabBuildApp.dev_build = False" >> /etc/jupyter/jupyter_config.py

# Step 8: Build JupyterLab assets (now with minimized build disabled)
RUN jupyter lab build

# Step 9: Working Directory
WORKDIR $HOME

# Step 10: Set environment variables for user configuration
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 11: Set user permissions and working directory
WORKDIR ${HOME}

USER root

# Step 12: Install curl and other apt-get dependencies
RUN apt-get update && apt-get install -y curl libicu66

# Step 13: Install .NET Core SDK and dependencies (if necessary for your repo)
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libssl1.1 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Step 14: Install .NET Core SDK (if needed)
RUN dotnet_sdk_version=3.1.301 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet help

# Step 15: Copy configuration files and notebooks
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Step 16: Copy package sources
COPY ./NuGet.config ${HOME}/nuget.config

# Step 17: Ensure ownership of files for the user
RUN chown -R ${NB_UID} ${HOME}

# Step 18: Set the user back to the non-root user
USER ${USER}

# Step 19: Install curl and other apt-get dependencies
RUN apt-get update && apt-get install -y curl libicu-dev

# Final Step: Set working directory to Notebooks
WORKDIR ${HOME}/Notebooks/

# Expose port (optional, depending on whether you want to use JupyterLab remotely)
EXPOSE 8888

# Command to start JupyterLab (default entrypoint)
CMD ["start-notebook.sh"]


