FROM ubuntu:16.04
LABEL maintainer = "Yajie Zhu <yajiez.me@gmail.com>"

ENV TERM xterm-256color
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV USERNAME ubuntu

ARG DEBIAN_FRONTEND=noninteractive

RUN useradd -d /home/$USERNAME -ms /bin/bash -g root -G sudo -p ubuntu $USERNAME
RUN echo "ubuntu:ubuntu" | chpasswd

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         wget \
         vim \
         zsh \
         tmux \
         sudo \
         locales \
         locales-all \
         fonts-powerline \
         ca-certificates \
         libjpeg-dev \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN chsh $USERNAME -s /bin/zsh

# Oh My ZSH and Spaceship Prompt & Vim
USER $USERNAME
WORKDIR /home/$USERNAME

ENV ZSH_CUSTOM /home/$USERNAME/.oh-my-zsh/custom

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

RUN git clone https://github.com/denysdovhan/spaceship-prompt.git $ZSH_CUSTOM/themes/spaceship-prompt && \
    ln -s $ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme $ZSH_CUSTOM/themes/spaceship.zsh-theme && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="spaceship"/' /home/$USERNAME/.zshrc  && \
    echo SPACESHIP_HOST_SHOW=always >> /home/$USERNAME/.zshrc && \
    echo SPACESHIP_USER_SHOW=always >> /home/$USERNAME/.zshrc && \
    echo source /home/$USERNAME/.profile >> /home/$USERNAME/.zshrc


RUN wget https://raw.githubusercontent.com/liuchengxu/space-vim/master/install.sh -O - | zsh || true && \
    echo let g:space_vim_dark_background = 233 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_banner = 0 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_liststyle = 3 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_browse_split = 4 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_altv = 1 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_winsize = 25 >> /home/$USERNAME/.vimrc


RUN git clone https://github.com/gpakosz/.tmux.git /home/$USERNAME/.tmux && \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local . && \
    echo set -gu prefix2 >> .tmux.conf.local && \
    echo unbind C-a >> .tmux.conf.local && \
    echo unbind C-b >> .tmux.conf.local && \
    echo set -g prefix C-b >> .tmux.conf.local && \
    echo bind C-b send-prefix >> .tmux.conf.local


# CUDA Configuration
USER root

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https gnupg-curl && \
    rm -rf /var/lib/apt/lists/* && \
    NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDA_VERSION 9.2.148

ENV CUDA_PKG_VERSION 9-2=$CUDA_VERSION-1
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-9.2 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=9.2"


# NCCL
ENV NCCL_VERSION 2.3.7

RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda9.2 && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*


# CUDNN
ENV CUDNN_VERSION 7.4.1.5
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda9.2 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*


# Python
ARG PYTHON_VERSION=3.6

USER $USERNAME
WORKDIR /home/$USERNAME

RUN curl -o /home/$USERNAME/miniconda.sh -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     chmod +x /home/$USERNAME/miniconda.sh && \
     /home/$USERNAME/miniconda.sh -b -p /home/$USERNAME/miniconda && \
     rm /home/$USERNAME/miniconda.sh && \
     /home/$USERNAME/miniconda/bin/conda install -y \
        python=$PYTHON_VERSION mkl mkl-include cython typing numpy pyyaml scipy ipython tqdm matplotlib seaborn scikit-learn && \
     /home/$USERNAME/miniconda/bin/conda install -y nodejs jupyterlab scikit-image scikit-optimize geopandas iris xesmf -c conda-forge && \
     /home/$USERNAME/miniconda/bin/conda install -y -c pyviz holoviews geoviews bokeh && \
     /home/$USERNAME/miniconda/bin/conda install -y tensorflow tensorflow-gpu keras keras-gpu -c anaconda && \
     /home/$USERNAME/miniconda/bin/conda install -y pytorch torchvision cuda92 -c pytorch && \
     /home/$USERNAME/miniconda/bin/conda install -y -c pytorch -c fastai fastai && \
     /home/$USERNAME/miniconda/bin/conda clean -ya && \
     /home/$USERNAME/miniconda/bin/jupyter serverextension enable --py jupyterlab --user && \
     /home/$USERNAME/miniconda/bin/jupyter labextension install @pyviz/jupyterlab_pyviz


RUN mkdir -p /home/$USERNAME/.jupyter/custom && \
    mkdir -p /home/$USERNAME/.ipython/profile_default/startup && \
    mkdir -p /home/$USERNAME/.config/matplotlib

COPY --chown=ubuntu:root jupyter/jupyter_notebook_config.py /home/$USERNAME/.jupyter/
COPY --chown=ubuntu:root jupyter/custom.css /home/$USERNAME/.jupyter/custom/
COPY --chown=ubuntu:root ipython/ipython_config.py /home/$USERNAME/.ipython/profile_default/
COPY --chown=ubuntu:root ipython/default_import.py /home/$USERNAME/.ipython/profile_default/startup/
COPY --chown=ubuntu:root matplotlib/matplotlibrc /home/$USERNAME/.config/matplotlib/

RUN chmod +x /home/$USERNAME/.ipython/profile_default/ipython_config.py && \
    chmod +x /home/$USERNAME/.ipython/profile_default/startup/default_import.py && \
    chmod +x /home/$USERNAME/.jupyter/jupyter_notebook_config.py

ENV PATH /home/$USERNAME/miniconda/bin:$PATH
ENV EDITOR vim

RUN mkdir -p /home/$USERNAME/projects
RUN mkdir -p /home/$USERNAME/bin
EXPOSE 8889

COPY --chown=ubuntu:root jupyter/start-jupyter-lab.sh /home/$USERNAME/bin/
RUN chmod +x /home/$USERNAME/bin/start-jupyter-lab.sh

CMD ["zsh"]
