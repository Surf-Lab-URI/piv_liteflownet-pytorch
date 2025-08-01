# Andy's Modifications

## Docker Container
### Getting Started
The dockerfile should allow you to build a functional container, within which you can run piv_liteflownet-pytorch. The container will have compatible versions of CUDA, CUDNN, PyTorch, CuPy, Python, Ubuntu, etc. To build the docker container image, run:
```
sudo docker build --no-cache -f Dockerfile -t piv_liteflownet-pytorch_cuda11 .
```
This will create a docker container image called piv_liteflownet-pytorch_cuda11, which you can run using:
```
sudo docker run --shm-size=8g -it --gpus all   -p 8888:8888   --name pivlfn1   -v /home/surflab/GitRepos:/home/surflab/GitRepos   piv_liteflownet-pytorch_cuda11
```
Now you have a container running called pivlfn1 which you can work inside. It also mounts the location where this repo is cloned on my host machine in the container, so that I can access the files in this repo inside and outside of the container. Replace the host directory in the above command with the location you cloned this repo. I have the dockerfile set up to create directories that mirror the host machine that I am using, but you may want to change that to mirror the machine you are using.

To access this container in another terminal window after it is running, execute:
```
sudo docker exec -it pivlfn1 bash
```
And to start this container later if you have stopped it, run:
```
docker start -ai pivlfn1
```
### Running piv_liteflownet-pytorch
cd into the top level directory for this repo in the docker container. Then run the following to make sure you have access and to see options:
```
python3 run.py --help
```

To run the demo, use 
```
python3 run.py -m piv -s 0 -n 2 -i ./images/demo/DNS_turbulence/ -o ./images/demo/DemoOutput/
```

To run on demo images from Fabrice Veron's wind-wave tank dataset, use
```
python3 run.py -m piv -s 0 -n 2 -i ./images/demo/ExpAW5R2/ -o ./images/demo/DemoOutput/
```

### Visualizing output
To visual the output, use `FloReaderDemo.ipynb` or `FloReaderDemo.m`.

### Running Jupyter Lab
The docker container should have jupyter lab installed. To run jupyter lab, execute:
```
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```
It should provide you with several links. Copy and paste the link that starts with an IP address into a browser window on your host machine. I have had issues with Firefox and jupyter lab. Opera seems to work well.

### Current State of the Project
The output for the demo images from Fabrice's dataset is very bad. The flow isn't entirely 2D, and there are weird reflections, and the timestep is quite large, all of which probably contribute. If the network were retrained on data that has these qualities, better results might be obtained. Not sure how to generate the necessary training dataset.

# PIV LiteFlowNet with PyTorch 
This is my PyTorch reimplementation of the PIV-LiteFlowNet [1] model. It's an upgraded LiteFlowNet [2] model with additional layers and trained specifically on Particle Image Velocimetry (PIV) images (please refer to the original paper [1] for the complete dataset details and sources). Also thanks to [Sniklaus](https://github.com/sniklaus/pytorch-liteflownet) [3] for the PyTorch reimplementation of the original LiteFlowNet model. If you would like to use this particular implementation, please acknowledge it appropriately [4].


## Model
The trained models for both the original LiteFlowNet and PIV-LiteFlowNet are already available in the `models/pretrain_torch/`. These originate from the original authors, I just converted them to PyTorch.

The correlation layer is implemented in CUDA using CuPy, which is why CuPy is a required dependency. It can be installed using `pip install cupy` or alternatively using one of the provided binary packages as outlined in the CuPy repository.

## Usage
To run it sequentially on 1000 images in your directory, starting from the first image, use the following command. There are 2 model options the are avaialble to run with, `piv` for the PIV-LiteFlowNet-en and `hui` for the original LiteFlowNet model. Please check on the CLI `--help` for more info.
```
python run.py --model piv -s 0 -n 1000 --input ./images/test --output ./test-output
```
If you want to visualize the flow results in sequence, or even compile it as video format, you can use the [piv-viz](https://github.com/abrosua/piv-viz) package.


## References
```
[1]  @article{piv-liteflownet,
         author = {Shengze Cai and Jiaming Liang and Qi Gao and Chao Xu and Runjie Wei},
         journal = {IEEE Transactions on Instrumentation and Measurement},
         title = {Particle Image Velocimetry Based on a Deep Learning Motion Estimator},
         year = {2020},
         volume = {69},
         number = {6},
         pages = {3538-3554},
         doi = {10.1109/TIM.2019.2932649}
}
```
```
[2]  @inproceedings{Hui_CVPR_2018,
         author = {Tak-Wai Hui and Xiaoou Tang and Chen Change Loy},
         title = {{LiteFlowNet}: A Lightweight Convolutional Neural Network for Optical Flow Estimation},
         booktitle = {IEEE Conference on Computer Vision and Pattern Recognition},
         year = {2018}
     }
```

```
[3]  @misc{pytorch-liteflownet,
         author = {Simon Niklaus},
         title = {A Reimplementation of {LiteFlowNet} Using {PyTorch}},
         year = {2019},
         howpublished = {\url{https://github.com/sniklaus/pytorch-liteflownet}}
    }
```

```
[4]  @misc{piv-liteflownet-pytorch,
         author = {Faber Silitonga},
         title = {A Reimplementation of {PIV-LiteFlowNet-en} Using {PyTorch}},
         year = {2021},
         howpublished = {\url{https://github.com/abrosua/piv_liteflownet-pytorch}}
    }
```
