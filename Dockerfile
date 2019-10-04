FROM pytorch/pytorch:1.2-cuda10.0-cudnn7-runtime
LABEL maintainer = "Yajie Zhu <yajiez.me@gmail.com>"

# Create new user
ENV USERNAME deepai
RUN useradd -d /home/$USERNAME -ms /bin/bash -g root -G sudo $USERNAME
RUN echo "deepai:deeplab" | chpasswd

RUN chown -R deepai:root /workspace
RUN chown -R deepai:root /opt/conda


# Set up the OS
ENV TERM xterm-256color
ENV MKL_THREADING_LAYER GNU
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         wget \
         less \
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


# Set up the shell for user deepai
RUN chsh $USERNAME -s /bin/zsh
USER $USERNAME
WORKDIR /home/$USERNAME

COPY --chown=deepai:root profile /home/$USERNAME/.profile

# Oh My ZSH and Spaceship Prompt
ENV ZSH_CUSTOM /home/$USERNAME/.oh-my-zsh/custom
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/denysdovhan/spaceship-prompt.git $ZSH_CUSTOM/themes/spaceship-prompt && \
    ln -s $ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme $ZSH_CUSTOM/themes/spaceship.zsh-theme && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="spaceship"/' /home/$USERNAME/.zshrc  && \
    echo SPACESHIP_HOST_SHOW=always >> /home/$USERNAME/.zshrc && \
    echo SPACESHIP_USER_SHOW=always >> /home/$USERNAME/.zshrc && \
    echo source /home/$USERNAME/.profile >> /home/$USERNAME/.zshrc

# SpaceVim
ENV EDITOR vim
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


# Python version
ENV PYTHON_VERSION=3.6

# Config Conda
RUN conda update -n base conda
RUN conda config --set auto_update_conda False
RUN conda config --add channels conda-forge

# Install the common used packages into the base environment
RUN conda install -y -n base -c conda-forge \
     python=$PYTHON_VERSION numpy pandas scikit-learn matplotlib tqdm nodejs jupyterlab ipykernel ipywidgets fastparquet pyarrow

# Config the JupyterLab
RUN jupyter serverextension enable --py jupyterlab --user && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install @pyviz/jupyterlab_pyviz && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter nbextension enable --py widgetsnbextension


# Create new conda environment with JupyterLab support
COPY --chown=deepai:root environment.yml /home/$USERNAME/
RUN conda env create -f environment.yml && conda clean -ya
RUN conda install -y -n deeplab pytorch torchvision cudatoolkit=10.0 -c pytorch
RUN /opt/conda/envs/deeplab/bin/python -m ipykernel install --user --name deeplab --display-name "Deep Lab"


# Config Jupyter & IPython & Matplotlib
RUN mkdir -p /home/$USERNAME/.jupyter/custom && \
    mkdir -p /home/$USERNAME/.ipython/profile_default/startup && \
    mkdir -p /home/$USERNAME/.config/matplotlib

COPY --chown=deepai:root jupyter/jupyter_notebook_config.py /home/$USERNAME/.jupyter/
COPY --chown=deepai:root jupyter/custom.css /home/$USERNAME/.jupyter/custom/
COPY --chown=deepai:root ipython/ipython_config.py /home/$USERNAME/.ipython/profile_default/
COPY --chown=deepai:root ipython/default_import.py /home/$USERNAME/.ipython/profile_default/startup/
COPY --chown=deepai:root matplotlib/matplotlibrc /home/$USERNAME/.config/matplotlib/

RUN chmod +x /home/$USERNAME/.ipython/profile_default/ipython_config.py && \
    chmod +x /home/$USERNAME/.ipython/profile_default/startup/default_import.py && \
    chmod +x /home/$USERNAME/.jupyter/jupyter_notebook_config.py


# Add JupyterLab startup script with tmux support
RUN mkdir -p /home/$USERNAME/bin
ENV PATH /home/$USERNAME/bin:$PATH

COPY --chown=deepai:root jupyter/start-jupyter-lab.sh /home/$USERNAME/bin/
RUN chmod +x /home/$USERNAME/bin/start-jupyter-lab.sh


# Create default folders for projects and datasets
RUN mkdir -p /home/$USERNAME/projects
RUN mkdir -p /home/$USERNAME/datasets

WORKDIR /home/$USERNAME/projects

# Expose the ports for JupyterLab and SSH
EXPOSE 8889
EXPOSE 22

CMD ["/bin/zsh"]
