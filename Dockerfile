FROM --platform="amd64" ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# =============================================================================
# System Setup
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    cmake \
    make \
    git \
    curl \
    wget \
    unzip \
    zip \
    ninja-build \
    gettext \
    locales \
    openssh-server \
    apt-transport-https \
    ca-certificates \
    stow \
    ucf \
    gpg \
    xclip

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
  locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# =============================================================================
# R DEPENDENCIES
# =============================================================================

# Install R system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran \
    libatlas-base-dev \
    libbz2-dev \
    libicu-dev \
    libcurl4-openssl-dev \
    liblzma-dev \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-6 \
    tzdata \
    libopenblas-dev \
    pandoc \
    libpaper-utils \
    libtcl8.6 \
    libtirpc-dev \
    libtk8.6 \
    libxt6t64 \
    libxml2-dev \
    libssl-dev \
    libcairo2 \
    libcairo2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libreadline-dev \
    liblapack-dev \
    libpcre2-dev \
    zlib1g-dev \
    libgmp3-dev \
    libudunits2-dev \
    libgdal-dev

# Install R 4.4.1 from Posit's pre-built deb for Ubuntu 24.04
RUN wget -q https://cdn.rstudio.com/r/ubuntu-2404/pkgs/r-4.4.1_1_amd64.deb \
        -O /tmp/r-4.4.1.deb && \
    apt-get install -y /tmp/r-4.4.1.deb && \
    rm /tmp/r-4.4.1.deb && \
    ln -s /opt/R/4.4.1/bin/R /usr/local/bin/R && \
    ln -s /opt/R/4.4.1/bin/Rscript /usr/local/bin/Rscript

# Set CRAN mirror
RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"))' >> /opt/R/4.4.1/lib/R/etc/Rprofile.site

# Install Quarto
RUN wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.27/quarto-1.8.27-linux-amd64.deb \
        -O /tmp/quarto.deb && \
    apt-get install -y /tmp/quarto.deb && \
    rm /tmp/quarto.deb

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

# Install general development dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    python3 \
    python3-pip \
    python-is-python3 \
    python3-venv \
    nodejs \
    npm \
    ripgrep \
    fd-find \
    fzf \
    zsh \
    lua5.1 \
    liblua5.1-dev \
    luarocks \
    imagemagick


# fd is installed as `fdfind` on Ubuntu — add a `fd` symlink
RUN ln -s $(which fdfind) /usr/local/bin/fd

# NOTE: INSGTALL NEOVIM FROM BINARY
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    rm -rf /opt/nvim-linux-x86_64 && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    ln -s /opt/nvim-linux-x86_64/bin/nvim /bin/nvim && \
    rm nvim-linux-x86_64.tar.gz

# Install Neovim (AppImage for latest stable)
# RUN wget -q https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage \
#         -O /usr/local/bin/nvim-appimage && \
#     chmod +x /usr/local/bin/nvim-appimage && \
#     /usr/local/bin/nvim-appimage --appimage-extract > /dev/null && \
#     mv squashfs-root /opt/nvim && \
#     ln -s /opt/nvim/usr/bin/nvim /usr/local/bin/nvim && \
#     rm /usr/local/bin/nvim-appimage

# Install Neovim from source.
# RUN mkdir -p /root/TMP
# RUN cd /root/TMP && git clone https://github.com/neovim/neovim
# RUN cd /root/TMP/neovim && git checkout stable && make -j4 && make install
# RUN rm -rf /root/TMP

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install Rust / Cargo via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup update

#install yazi
RUN cargo install --force yazi-build

# Install lazygit
RUN curl -sL https://github.com/jesseduffield/lazygit/releases/download/v0.59.0/lazygit_0.59.0_Linux_x86_64.tar.gz \
        | tar -xz -C /usr/local/bin lazygit

# Install oh-my-zsh and Powerlevel10k
# RUN sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
#     git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k && \
#     sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /root/.zshrc && \
#     cp /root/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-lean.zsh /root/.p10k.zsh && \
#     echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /root/.zshrc

# Install uv
ADD https://astral.sh/uv/0.10.4/install.sh /uv-installer.sh
# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh
# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

# RUN pip install jupytext --break-system-packages
RUN uv tool install --upgrade pynvim
RUN uv tool install --upgrade jupytext


# install ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN rm -rf /root/.oh-my-zsh/custom

###################
# Setup DOTFILES ##
###################

RUN mkdir -p "/root/gits/ClemensKohl/"
RUN git clone https://github.com/ClemensKohl/dotfiles.git "/root/gits/ClemensKohl/dotfiles"
WORKDIR "/root/gits/ClemensKohl/dotfiles"
RUN git submodule init && git submodule update
RUN stow --target=/root --adopt */
RUN git restore .
WORKDIR /root

# Update Neovim
RUN nvim --headless "+Lazy! sync" +qa

# Setup RENV
# ENV RENV_CONFIG_PAK_ENABLED=TRUE
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
WORKDIR /root/renv_library
RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json
RUN R -s -e "renv::restore()"
WORKDIR /root
RUN rm -rf /root/renv_library


# Set zsh as default shell
SHELL ["/bin/zsh", "-c"]

# =============================================================================

WORKDIR /root

CMD ["/bin/zsh"]
