# Start with an Ubuntu base image
FROM ubuntu:22.04 as base

# Install required dependencies and .NET SDK
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    lsb-release \
    apt-transport-https
    
# Download the Microsoft package for Ubuntu and install it
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb && \
    ls -l packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0 || tail -n 20 /var/log/apt/term.log

# Install .NET Interactive tools
RUN dotnet tool install -g Microsoft.dotnet-interactive

# Ensure the required Jupyter kernel directory exists
RUN mkdir -p /root/.local/share/jupyter/kernels

# Install .NET Interactive for Jupyter (C#, PowerShell, F#)
RUN export PATH="$PATH:/root/.dotnet/tools" && \
    dotnet interactive jupyter install

# Expose port for Jupyter Lab if necessary
EXPOSE 8888

# Set the default working directory
WORKDIR /workspace

# Set entrypoint for running Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root"]

