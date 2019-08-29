# deeplab: Docker based Deep Learning Environment

This project aim to provide a pre-defined [Conda](https://docs.conda.io/en/latest/) based Python environment and a fully self-contained [docker](https://www.docker.com/) based environment for Deep Learning Research.

## Conda Environment

Conda environments are defined by conda environment file `environment.yml` and it's used by the docker environments.

The default deep learning framework is [PyTorch](https://pytorch.org/). 

Tenserflow support may be added in the future. However, there is no plan for supporting Windows.

## Docker Environment

### CPU Only

The Dockerfile of cpu-only environment is under the `cpu` folder.

### CUDA Support

The Dockerfile of CUDA enabled environment is under the `cuda` folder.
