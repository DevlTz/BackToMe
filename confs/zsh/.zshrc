# Inicialização base
export ZSH="$HOME/.oh-my-zsh"
plugins=(git sudo docker zsh-autosuggestions zsh-syntax-highlighting extract)
source $ZSH/oh-my-zsh.sh

# Ferramentas visuais
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
fastfetch

# Exportações
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# PATHs customizados
export PATH="$HOME/.local/bin:$PATH"

# Aliases de Produtividade
alias p="cd \"$HOME/projects\""
alias ll="eza -lah --icons"
alias ls="eza --icons"
alias v="nvim"
alias lg="lazygit"
alias gs="git status"
alias d="docker"
alias dc="docker compose"
alias open="explorer.exe ."
alias clear="clear && fastfetch"
alias compile="g++ -Wall -Wextra -O2"

# Funções
function n-vite() {
  p
  npm create vite@latest $1 -- --template react-ts
  cd $1 && npm install
}