# Use official JupyterLab base image
FROM jupyter/base-notebook:latest

# Install PowerShell for Ubuntu (for base images like `jupyter/base-notebook`)
RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    software-properties-common \
    && wget -q "https://packages.microsoft.com/config/ubuntu/20.04/prod.list" -O /etc/apt/sources.list.d/microsoft-prod.list \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y powershell

# Install JupyterLab and PowerShell Kernel
RUN pip install jupyterlab powershell_kernel

# Install other required Python packages (if any)
# RUN pip install nteract_on_jupyter

# Register PowerShell Kernel
RUN python -m powershell_kernel.install

# Expose the Jupyter port
EXPOSE 8888

# Set the default command to launch JupyterLab
CMD ["start-notebook.sh"]
