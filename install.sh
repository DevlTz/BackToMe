#!/usr/bin/env bash

# Sai imediatamente se um comando falhar, se uma variável não existir, ou se um pipe falhar
set -euo pipefail

# ==========================================================
# WSL Ubuntu ULTIMATE Dev Setup (v4.0 - Pro Edition)
# ==========================================================

LOG_FILE="${HOME}/wsl-dev-setup.log"
PROJECTS_DIR="/home/dovale/projects"
DOTFILES_DIR="${HOME}/dotfiles"

# Cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem cor

exec > >(tee -a "$LOG_FILE") 2>&1

info() { echo -e "\n${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCESSO]${NC} $1"; }
warn() { echo -e "${YELLOW}[AVISO]${NC} $1"; }

export DEBIAN_FRONTEND=noninteractive

info "Iniciando a instalação do ambiente Pro..."

# 1. REPOSITÓRIOS EXTRAS (Eza, Fastfetch, GitHub CLI)
info "Configurando chaves e repositórios externos..."
sudo mkdir -p /etc/apt/keyrings

# Eza Repo
if [ ! -f /etc/apt/sources.list.d/gierens.list ]; then
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
fi

# GitHub CLI Repo
if [ ! -f /etc/apt/sources.list.d/github-cli.list ]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
fi

# Fastfetch Repo
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
sudo add-apt-repository -y ppa:neovim-ppa/stable

# 2. ATUALIZAÇÃO E INSTALAÇÃO BASE
info "Atualizando sistema e instalando dependências core..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Adicionei 'stow' e 'fastfetch' na lista
sudo apt-get install -y \
  build-essential curl wget git unzip zip ca-certificates gnupg lsb-release \
  software-properties-common apt-transport-https zsh tmux fzf ripgrep \
  fd-find bat eza htop btop tree jq direnv xclip shellcheck make cmake \
  ninja-build gdb clang lldb neovim gh stow fastfetch

success "Pacotes base instalados."

# 3. DIRETÓRIOS E DOTFILES
info "Preparando estrutura de diretórios..."
mkdir -p "$PROJECTS_DIR"
mkdir -p "$DOTFILES_DIR/.config"

# 4. FERRAMENTAS DE CLI (Zoxide & Lazygit)
info "Instalando ferramentas auxiliares..."
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

if ! command -v lazygit &> /dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin && rm lazygit lazygit.tar.gz
fi

# 4.5 INSTALANDO NEOVIM ATUALIZADO (>= 0.9)
info "Instalando Neovim atualizado..."
if ! command -v nvim &> /dev/null || [[ $(nvim -v | head -n 1) == *"0.6"* ]]; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz
    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
    rm nvim-linux64.tar.gz
    success "Neovim atualizado instalado."
fi

# 5. NEOVIM (LAZYVIM SETUP)
info "Configurando Neovim (LazyVim)..."
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    success "LazyVim instalado."
else
    warn "A pasta ~/.config/nvim já existe. Pulando a instalação do LazyVim."
fi

# 6. ZSH & OH MY ZSH
info "Configurando Zsh e Plugins..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions 2>/dev/null || true
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 2>/dev/null || true

if ! command -v starship &> /dev/null; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

# 7. LINGUAGENS (Node, Java, Python)
info "Instalando stacks de desenvolvimento..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts && npm install -g pnpm yarn
fi

if [ ! -d "$HOME/.sdkman" ]; then
    curl -s "https://get.sdkman.io" | bash
fi

sudo apt-get install -y python3 python3-pip python3-venv

# 8. DOCKER CLI (WSL INTEGRATION)
info "Configurando Docker CLI..."
if ! command -v docker &> /dev/null; then
    sudo rm -f /etc/apt/sources.list.d/docker.list
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update && sudo apt-get install -y docker-ce-cli docker-compose-plugin
    sudo usermod -aG docker $USER || true
fi

# 9. GERAÇÃO DO .ZSHRC
info "Gerando arquivo .zshrc..."
cat > "$HOME/.zshrc" <<EOF
# Inicialização base
export ZSH="\$HOME/.oh-my-zsh"
plugins=(git sudo docker zsh-autosuggestions zsh-syntax-highlighting extract)
source \$ZSH/oh-my-zsh.sh

# Ferramentas visuais
eval "\$(starship init zsh)"
eval "\$(zoxide init zsh)"
fastfetch # Mostra as informações do sistema ao abrir o terminal

# Exportações
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"

export SDKMAN_DIR="\$HOME/.sdkman"
[[ -s "\$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "\$SDKMAN_DIR/bin/sdkman-init.sh"

# PATHs customizados
export PATH="\$HOME/.local/bin:\$PATH"

# Aliases de Produtividade
alias p="cd $PROJECTS_DIR"
alias ll="eza -lah --icons"
alias ls="eza --icons"
alias v="nvim"
alias lg="lazygit"
alias gs="git status"
alias d="docker"
alias dc="docker compose"
alias open="explorer.exe ."
alias clear="clear && fastfetch" # Limpa a tela e mostra o fastfetch de novo
alias compile="g++ -Wall -Wextra -O2"

# Funções
function n-vite() {
  p
  npm create vite@latest \$1 -- --template react-ts
  cd \$1 && npm install
}
EOF

# Define o ZSH como padrão se não for
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh) || true
fi

success "Setup Pro concluído com sucesso!"
info "Por favor, reinicie seu terminal ou rode 'zsh' para carregar todas as configurações."