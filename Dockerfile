# Use a base image with Ubuntu or a suitable version of Linux for .NET
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites for .NET and Jupyter
RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    software-properties-common \
    curl \
    lsb-release \
    ca-certificates \
    gnupg \
    unzip \
    python3-pip \
    python3-dev \
    build-essential \
    git \
    && apt-get clean

# Add Microsoft package repository for .NET SDK
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update

# Install .NET SDK
RUN apt-get install -y dotnet-sdk-8.0

# Install the .NET Interactive tool
RUN dotnet tool install -g Microsoft.dotnet-interactive

# Add the .NET tools directory to the PATH in the current session
RUN echo 'export PATH="$PATH:/root/.dotnet/tools"' >> /etc/profile

# Ensure the path is available during the build process
RUN export PATH="$PATH:/root/.dotnet/tools" && dotnet interactive jupyter install

# Install Jupyter and necessary Python dependencies
RUN pip3 install --upgrade pip
RUN pip3 install jupyter jupyterlab ipywidgets

# Install additional JupyterLab extensions
RUN jupyter labextension install @jupyterlab/git
RUN jupyter serverextension enable --py jupyterlab_git


CMD ["jupyter", "lab", "--ip='*'", "--port=8888", "--no-browser", "--allow-root"]
