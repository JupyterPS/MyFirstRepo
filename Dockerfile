# Use a base image with Ubuntu (or similar) for .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 as base

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y wget unzip curl ca-certificates apt-transport-https lsb-release

# Install .NET SDK
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0

# Install .NET Interactive Tool (for Jupyter integration)
RUN dotnet tool install -g Microsoft.dotnet-interactive

# Ensure the required kernel directory exists before installing .NET Interactive Jupyter kernels
RUN mkdir -p /root/.local/share/jupyter/kernels

# Install .NET Interactive for Jupyter (C#, PowerShell, F#)
RUN export PATH="$PATH:/root/.dotnet/tools" && \
    dotnet interactive jupyter install

# Expose port for Jupyter Notebook if necessary
EXPOSE 8888

# Set the default working directory
WORKDIR /workspace

# Optional: Copy your application or files into the Docker image (uncomment and adjust as needed)
# COPY . /workspace/

# Set the entrypoint to run Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root"]
