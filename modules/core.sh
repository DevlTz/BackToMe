#!/usr/bin/env bash

install_core_tools() {
    export DEBIAN_FRONTEND=noninteractive
 
    # Repositórios Extras
    sudo mkdir -p /etc/apt/keyrings || return 1
    if [ ! -f /etc/apt/sources.list.d/gierens.list ]; then
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg || return 1
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null || return 1
    fi
 
    if [ ! -f /etc/apt/sources.list.d/github-cli.list ]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg || return 1
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null || return 1
    fi
 
    # Garantir add-apt-repository antes de usar o comando
    sudo apt-get update -y || return 1
    sudo apt-get install -y software-properties-common || return 1
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch > /dev/null || return 1
 
    # Atualização e Pacotes Base (Sem o Neovim velho)
    sudo apt-get update -y || return 1
    sudo apt-get upgrade -y || return 1
    sudo apt-get install -y \
      build-essential curl wget git unzip zip ca-certificates gnupg lsb-release \
      software-properties-common apt-transport-https zsh tmux fzf ripgrep \
      fd-find bat eza htop btop tree jq direnv xclip shellcheck make cmake \
      ninja-build gdb clang lldb gh stow fastfetch || return 1
 
    # Ferramentas CLI
    if ! command -v zoxide &> /dev/null; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
 
    if ! command -v lazygit &> /dev/null; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin && rm lazygit lazygit.tar.gz
    fi
 
    # Neovim Atualizado CORRETO
    if ! command -v nvim &> /dev/null || [[ $(nvim -v | head -n 1) == *"0.7"* ]] || [[ $(nvim -v | head -n 1) == *"0.6"* ]]; then
        curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        rm -f nvim-linux-x86_64.tar.gz
    fi
 
    # LazyVim
    if [ ! -d "$HOME/.config/nvim" ]; then
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
    fi
 
    # Zsh Plugins & Starship
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
      RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions 2>/dev/null || true
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 2>/dev/null || true
    # Powerlevel10k
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    fi
}

install_docker() {
    if ! command -v docker &> /dev/null; then
        sudo rm -f /etc/apt/sources.list.d/docker.list
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update && sudo apt-get install -y docker-ce-cli docker-compose-plugin
        sudo usermod -aG docker $USER || true
    fi
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    install_core_tools
fi