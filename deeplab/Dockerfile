FROM nvidia/cuda:9.2-cudnn7-devel
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


# Python
ARG PYTHON_VERSION=3.6

USER $USERNAME
WORKDIR /home/$USERNAME

RUN curl -o /home/$USERNAME/miniconda.sh -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     chmod +x /home/$USERNAME/miniconda.sh && \
     /home/$USERNAME/miniconda.sh -b -p /home/$USERNAME/miniconda && \
     rm /home/$USERNAME/miniconda.sh


RUN /home/$USERNAME/miniconda/bin/conda install -y \
        python=$PYTHON_VERSION mkl mkl-include cython typing numpy pyyaml scipy ipython tqdm matplotlib seaborn scikit-learn


RUN /home/$USERNAME/miniconda/bin/conda install -y -c conda-forge -c pyviz -c pytorch -c fastai -c anaconda \
    nodejs jupyterlab scikit-image scikit-optimize geopandas iris xesmf holoviews geoviews bokeh \
    fiona shapely pyproj rtree tensorflow tensorflow-gpu keras keras-gpu pytorch torchvision cuda92 fastai && \
    /home/$USERNAME/miniconda/bin/conda clean -ya

RUN /home/$USERNAME/miniconda/bin/jupyter serverextension enable --py jupyterlab --user && \
    /home/$USERNAME/miniconda/bin/jupyter labextension install @pyviz/jupyterlab_pyviz


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

ENV PATH /home/$USERNAME/miniconda/bin:$PATH
ENV EDITOR vim

RUN mkdir -p /home/$USERNAME/projects
RUN mkdir -p /home/$USERNAME/bin
EXPOSE 8889
EXPOSE 22

COPY --chown=deepai:root jupyter/start-jupyter-lab.sh /home/$USERNAME/bin/
RUN chmod +x /home/$USERNAME/bin/start-jupyter-lab.sh

CMD ["zsh"]
