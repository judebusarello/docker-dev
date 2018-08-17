FROM ubuntu:18.10
# pass in when building the image
ARG PROXY=''

ENV TERM screen-256color

ENV USER dev
ENV HOME /home/$USER
ENV XDG_CONFIG_HOME $HOME/.config
WORKDIR /home/$USER

# Disable http cache and pipeline, fixes some download bugs
RUN echo 'Acquire::http::No-Cache true;\nAcquire::http::Pipeline-Depth 0;' \
    >> /etc/apt/apt.conf.d/no-pipeline

# A lot of this was copied from AGhost-7/docker-dev
RUN apt-get update && \
    apt-get install sudo locales -y && \
    adduser --disabled-password --gecos '' $USER && \
    adduser $USER sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Locale (unicode characters broken if not set!!!)
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Add PPA repositories
RUN apt-get update
RUN apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository ppa:git-core/ppa

# Update package list
RUN apt-get update
RUN apt-get upgrade -y

# Install from standard repos
RUN apt-get install -y --no-install-recommends mc bash automake pkg-config libpcre3-dev \
    tmux build-essential make tree curl man-db sudo software-properties-common \
    zlib1g-dev liblzma-dev libssl-dev xsel exuberant-ctags silversearcher-ag

# Install from PPAs
RUN apt-get install -y git vim

# For some reason the user folder is not owned by the user
RUN chown -R "$USER":"$USER" /home/$USER

# User-specific part follows
USER $USER

# Install vim plug
RUN curl -fLo /home/$USER/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Put in my vim dotfiles
RUN git clone https://github.com/judebusarello/dotfiles ~/dotfiles
RUN cp ~/dotfiles/work-dotfiles/.vimrc ~/.vimrc
RUN cp ~/dotfiles/work-dotfiles/.tmux.config ~/.tmux.config

CMD ["/usr/bin/tmux"]
