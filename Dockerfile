# sudo docker build --no-cache -f Dockerfile -t piv_liteflownet-pytorch_cuda11 .

# docker run -it --gpus all -p 8888:8888 -v /home/surflab/GitRepos/piv_liteflownet-pytorch:/home/surflab/GitRepos/piv_liteflownet-pytorch piv_liteflownet-pytorch_cuda11

# sudo docker run -it --gpus all   -p 8888:8888   --name pivlfn1   -v /home/surflab/GitRepos:/home/surflab/GitRepos   piv_liteflownet-pytorch_cuda11:V2

#docker start -ai pivlfn1

#jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
# Then copy and paste the url it spits out that has an ip address at the front into a browser on the host machine

# python3 run.py -m piv -s 0 -n 2 -i ./images/demo/test_input1/ -o ./images/demo/test_output/

#sudo docker run --shm-size=8g -it --gpus all   -p 8888:8888   --name pivlfn1   -v /home/surflab/GitRepos:/home/surflab/GitRepos   piv_liteflownet-pytorch_cuda11:V2


# Base image with CUDA 11.7 and cuDNN 8, Ubuntu 20.04
FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

# Prevent prompts during install
ENV DEBIAN_FRONTEND=noninteractive


# Install system dependenciescd 
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    git \
    curl 
    wget \
    unzip \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    python3.8 \
    python3.8-dev \
    python3.8-distutils \
    python3-pip \
    && apt-get clean

# Make python3 point to python3.8
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

RUN mkdir /home/surflab
RUN mkdir /home/surflab/GitRepos

# Upgrade pip and install Python packages
RUN pip install --upgrade pip

# Install PyTorch 1.13.1 with CUDA 11.7
RUN pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 -f https://download.pytorch.org/whl/torch_stable.html

# Install CuPy 11.5.0 for CUDA 11
RUN pip install cupy-cuda11x==11.5.0

# Install JupyterLab and common Python tools
RUN pip install jupyterlab matplotlib opencv-python tqdm ipywidgets scikit-image colorama \
	setproctitle imutils scikit-learn pandas lmdb pyarrow h5py

# Create a working directory and expose the Jupyter port
EXPOSE 8888



