# Step 1: Use the Jupyter base notebook image
FROM jupyter/base-notebook:latest

# Step 2: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 3: Install Python dependencies
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade jupyterlab jupyterlab-git numpy scipy matplotlib ipython pandas sympy nose ipywidgets jupyter_contrib_nbextensions jupyterthemes

# Step 4: Install system dependencies
USER root
RUN apt-get update && apt-get install -y curl libicu-dev libssl-dev wget apt-transport-https software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Step 5: Install .NET SDK and Configure PATH
RUN wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel LTS --install-dir /usr/share/dotnet && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet && \
    dotnet --info

# Step 6: Install .NET Interactive and Jupyter Integration
RUN dotnet tool install -g Microsoft.dotnet-interactive && \
    dotnet interactive jupyter install

# Step 7: Set permissions for the jovyan user
RUN chown -R jovyan:users /usr/share/dotnet /usr/share/dotnet-tools

# Step 8: Reset to jovyan user and working directory
USER jovyan
WORKDIR /home/jovyan

# Step 9: Expose the Jupyter port
EXPOSE 8888
