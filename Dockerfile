FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# =============================================================================
# System Setup
# =============================================================================
RUN apt update && apt install -y --no-install-recommends \
    build-essential \
    cmake \
    make \
    git \
    curl \
    wget \
    unzip \
    zip \
    locales \
    apt-transport-https \
    ca-certificates \
    ucf \
    gpg \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# R & DEPENDENCIES
# =============================================================================

# Install R system dependencies
RUN apt update && apt install -y --no-install-recommends \
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
    && rm -rf /var/lib/apt/lists/*

# Install R 4.4.1 from Posit's pre-built deb for Ubuntu 24.04
RUN wget -q https://cdn.rstudio.com/r/ubuntu-2404/pkgs/r-4.4.1_1_amd64.deb \
        -O /tmp/r-4.4.1.deb && \
    apt install -y /tmp/r-4.4.1.deb && \
    rm /tmp/r-4.4.1.deb && \
    ln -s /opt/R/4.4.1/bin/R /usr/local/bin/R && \
    ln -s /opt/R/4.4.1/bin/Rscript /usr/local/bin/Rscript && \
    rm -rf /var/lib/apt/lists/*

# Set CRAN mirror
RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"))' >> /opt/R/4.4.1/lib/R/etc/Rprofile.site

# Install Quarto
RUN wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.27/quarto-1.8.27-linux-amd64.deb \
        -O /tmp/quarto.deb && \
    apt install -y /tmp/quarto.deb && \
    rm /tmp/quarto.deb && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

# Install general development dependencies
RUN apt update && apt install -y --no-install-recommends \
    python3 \
    python3-pip \
    nodejs \
    npm \
    ripgrep \
    fd-find \
    zsh \
    lua5.1 \
    liblua5.1-dev \
    && rm -rf /var/lib/apt/lists/*

# FIMXE: Install NEOVIM FROM SOURCE
# FIXME: Install Neovim dependecies as listed on website
# Install Neovim (AppImage for latest stable)
RUN wget -q https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage \
        -O /usr/local/bin/nvim-appimage && \
    chmod +x /usr/local/bin/nvim-appimage && \
    /usr/local/bin/nvim-appimage --appimage-extract > /dev/null && \
    mv squashfs-root /opt/nvim && \
    ln -s /opt/nvim/usr/bin/nvim /usr/local/bin/nvim && \
    rm /usr/local/bin/nvim-appimage

# fd is installed as `fdfind` on Ubuntu — add a `fd` symlink
RUN ln -s $(which fdfind) /usr/local/bin/fd

# Install Rust / Cargo via rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
ENV PATH="/root/.cargo/bin:${PATH}"

# Install lazygit
RUN curl -sL https://github.com/jesseduffield/lazygit/releases/download/v0.59.0/lazygit_0.59.0_Linux_x86_64.tar.gz \
        | tar -xz -C /usr/local/bin lazygit

# Install oh-my-zsh and Powerlevel10k
RUN sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /root/.zshrc && \
    cp /root/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-lean.zsh /root/.p10k.zsh && \
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /root/.zshrc

# Set zsh as default shell
SHELL ["/bin/zsh", "-c"]

# =============================================================================

WORKDIR /CAdir_results

CMD ["/bin/zsh"]
