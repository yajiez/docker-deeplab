FROM ubuntu:18.04
LABEL maintainer = "Yajie Zhu <yajiez.me@gmail.com>"

ENV USERNAME deepai
RUN useradd -d /home/$USERNAME -ms /bin/bash -g root -G sudo $USERNAME
RUN echo "deepai:deeplab" | chpasswd

ENV TERM xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         wget \
         tree \
         htop \
         vim \
         zsh \
         tmux \
         sudo \
         locales \
         locales-all \
         openssl \
         ca-certificates \
         openssh-client \
         libjpeg-dev \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Use zsh instead of bash
RUN chsh $USERNAME -s /bin/zsh

# Oh My ZSH and Spaceship Prompt
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


# SpaceVim
RUN wget https://raw.githubusercontent.com/liuchengxu/space-vim/master/install.sh -O - | zsh || true && \
    echo let g:space_vim_dark_background = 233 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_banner = 0 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_liststyle = 3 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_browse_split = 4 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_altv = 1 >> /home/$USERNAME/.vimrc && \
    echo let g:netrw_winsize = 25 >> /home/$USERNAME/.vimrc


# Oh-my-tmux
RUN git clone https://github.com/gpakosz/.tmux.git /home/$USERNAME/.tmux && \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local . && \
    echo set -gu prefix2 >> .tmux.conf.local && \
    echo unbind C-a >> .tmux.conf.local && \
    echo unbind C-b >> .tmux.conf.local && \
    echo set -g prefix C-b >> .tmux.conf.local && \
    echo bind C-b send-prefix >> .tmux.conf.local


# Python
ARG PYTHON_VERSION=3.7

USER $USERNAME
WORKDIR /home/$USERNAME

# Conda
RUN curl -o /home/$USERNAME/miniconda.sh -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     chmod +x /home/$USERNAME/miniconda.sh && \
     /home/$USERNAME/miniconda.sh -b -p /home/$USERNAME/miniconda && \
     rm /home/$USERNAME/miniconda.sh

RUN /home/$USERNAME/miniconda/bin/conda config --set auto_update_conda False

# Use conda-forge as the default channel
RUN /home/$USERNAME/miniconda/bin/conda config --add channels conda-forge

ENV PATH /home/$USERNAME/miniconda/bin:$PATH
ENV EDITOR vim
ENV MKL_THREADING_LAYER GNU

# Install the most common used packages into the base environment
RUN /home/$USERNAME/miniconda/bin/conda install -y -c conda-forge \
     python=$PYTHON_VERSION numpy pandas scikit-learn matplotlib tqdm nodejs jupyterlab ipywidgets fastparquet pyarrow pytest


# Config the JupyterLab
RUN /home/$USERNAME/miniconda/bin/jupyter serverextension enable --py jupyterlab --user && \
    /home/$USERNAME/miniconda/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    /home/$USERNAME/miniconda/bin/jupyter labextension install @pyviz/jupyterlab_pyviz && \
    /home/$USERNAME/miniconda/bin/jupyter labextension install @jupyterlab/toc && \
    /home/$USERNAME/miniconda/bin/jupyter nbextension enable --py widgetsnbextension


# Create the deeplab conda environment
COPY --chown=deepai:root environment.yml /home/$USERNAME/
RUN /home/$USERNAME/miniconda/bin/conda env create -f environment.yml
RUN /home/$USERNAME/miniconda/bin/conda clean -ya
RUN /home/$USERNAME/miniconda/envs/deeplab/bin/python -m ipykernel install --user --name deeplab --display-name "Deep Lab"


# Config Jupyter & IPython & Matplotlib
RUN mkdir -p /home/$USERNAME/.jupyter/custom && \
    mkdir -p /home/$USERNAME/.ipython/profile_default/startup && \
    mkdir -p /home/$USERNAME/.config/matplotlib


COPY --chown=deepai:root docker/jupyter/jupyter_notebook_config.py /home/$USERNAME/.jupyter/
COPY --chown=deepai:root docker/jupyter/custom.css /home/$USERNAME/.jupyter/custom/
COPY --chown=deepai:root docker/ipython/ipython_config.py /home/$USERNAME/.ipython/profile_default/
COPY --chown=deepai:root docker/ipython/default_import.py /home/$USERNAME/.ipython/profile_default/startup/
COPY --chown=deepai:root docker/matplotlib/matplotlibrc /home/$USERNAME/.config/matplotlib/


RUN chmod +x /home/$USERNAME/.ipython/profile_default/ipython_config.py && \
    chmod +x /home/$USERNAME/.ipython/profile_default/startup/default_import.py && \
    chmod +x /home/$USERNAME/.jupyter/jupyter_notebook_config.py


# Config the shell
COPY --chown=deepai:root docker/profile /home/$USERNAME/.profile

# Add some command line tools
RUN mkdir -p /home/$USERNAME/bin
COPY --chown=deepai:root docker/jupyter/start-jupyter-lab.sh /home/$USERNAME/bin/
RUN chmod +x /home/$USERNAME/bin/start-jupyter-lab.sh

ENV PATH /home/$USERNAME/bin:$PATH

# Create a default folder for projects
RUN mkdir -p /home/$USERNAME/projects

# Create a default folder for datasets
RUN mkdir -p /home/$USERNAME/datasets

# Expose the ports for JupyterLab and SSH
EXPOSE 6669
EXPOSE 22

CMD ["zsh"]
