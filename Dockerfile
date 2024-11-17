# Step 1: Use the Jupyter base notebook image
FROM jupyter/base-notebook:latest

# Step 2: Upgrade pip
RUN python -m pip install --upgrade pip

# Step 3: Install dependencies and common libraries
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade jupyterlab jupyterlab-git numpy scipy matplotlib ipython pandas sympy nose ipywidgets jupyter_contrib_nbextensions jupyterthemes

# Step 4: Install curl, ICU, and other dependencies
USER root
RUN apt-get update && apt-get install -y curl libicu-dev libssl-dev wget apt-transport-https software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Step 5: Install .NET SDK and Interactive Tools
RUN wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel LTS && \
    # Persist the PATH changes for all layers
    echo 'export PATH="/root/.dotnet:/root/.dotnet/tools:$PATH"' >> /etc/environment && \
    echo 'export PATH="/root/.dotnet:/root/.dotnet/tools:$PATH"' >> ~/.bashrc && \
    source ~/.bashrc && \
    /root/.dotnet/dotnet --info && \
    /root/.dotnet/dotnet tool install -g Microsoft.dotnet-interactive && \
    /root/.dotnet/tools/dotnet-interactive jupyter install

# Step 6: Set the default user back to jovyan
USER jovyan

# Step 7: Set the working directory
WORKDIR /home/jovyan

# Step 8: Expose the default Jupyter port
EXPOSE 8888
