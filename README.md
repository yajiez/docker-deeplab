# deeplab: Deep Learning Lab based on PyTorch and Docker

This project aim to provide a pre-defined [Conda](https://docs.conda.io/en/latest/) based Python environment and a fully self-contained [docker](https://www.docker.com/) based environment for Deep Learning Research.

The deep learning framework used is [PyTorch](https://pytorch.org/). 

Tenserflow support may be added in the future. However, there is no plan for supporting Windows.

## Usage

### Step 1

Just run the command below:

```sh
docker run -it -p 8889:8889 deeplab
```

Note you need to use `nvidia-docker` if you have a CUDA enabled GPU.

### Step 2

Use  `jupyter notebook password` to set your personal password for JupyterLab and then run `start-jupyter-lab.sh` to start JupyterLab inside a tmux session.

### Step 3

Enjoy.