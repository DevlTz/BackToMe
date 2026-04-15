#!/usr/bin/env bash
set -euo pipefail

export LOG_FILE="${HOME}/wsl-dev-setup.log"
export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

> "$LOG_FILE" # Limpa o log antigo a cada execução

# PREVENÇÃO DE ERRO: Pede a senha do sudo AGORA para evitar que o usuário seja pego de surpresa mais tarde, quando o script já estiver rodando e fazendo coisas importantes. Assim, garantimos que o sudo esteja ativo e pronto para ser usado quando necessário, sem interrupções no meio do processo.
echo "🔑 Precisamos de permissão de administrador para continuar..."
sudo -v
# Mantém o sudo vivo no fundo enquanto o script roda
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if ! command -v gum &> /dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
    sudo apt update > /dev/null 2>&1
    sudo apt install gum -y > /dev/null 2>&1
fi

# Carrega só a UI
# ATENÇÃO: Se você tiver funções de instalação específicas para cada módulo, é melhor colocar essas funções dentro dos arquivos de módulo correspondentes (como node.sh, java.sh, etc.) e chamá-las aqui. Assim, o install.sh fica mais limpo e organizado.
source utils/ui.sh

# 3. Inicia a Interface
print_header

# 4. O Menu Interativo
gum style --bold "O que você deseja instalar ou atualizar hoje?"
CHOICES=$(gum choose --no-limit --cursor-prefix "[ ] " --selected-prefix "[✓] " \
    "1. Core (Zsh, Neovim, Git, CLI Tools)" \
    "2. Stack Node.js (NVM, PNPM)" \
    "3. Stack Java (SDKMAN, Spring)" \
    "4. Stack Python (Pip, Venv)" \
    "5. Docker (Integração WSL)")

if [ -z "$CHOICES" ]; then
    warn "Nenhuma opção selecionada. Saindo..."
    exit 0
fi

info "Iniciando processo de instalação..."
# 5. Executando as escolhas com a barra de carregamento

if [[ $CHOICES == *"1. Core"* ]]; then
    run_with_spinner "Instalando ferramentas Core e Neovim..." "bash modules/core.sh"
fi

if [[ $CHOICES == *"2. Stack Node.js"* ]]; then
    run_with_spinner "Instalando ecossistema Node.js..." "bash modules/node.sh"
fi

if [[ $CHOICES == *"3. Stack Java"* ]]; then
    run_with_spinner "Instalando ecossistema Java..." "bash modules/java.sh"
fi

if [[ $CHOICES == *"4. Stack Python"* ]]; then
    run_with_spinner "Instalando ecossistema Python..." "bash modules/python.sh"
fi

if [[ $CHOICES == *"5. Docker"* ]]; then
    run_with_spinner "Configurando Docker CLI..." "bash modules/docker.sh"
fi

# 6. Aplicando as Configurações (GNU Stow)
info "Aplicando Dotfiles via GNU Stow..."
rm -f "$HOME/.zshrc" # Remove o padrão para não dar conflito
cd "$DOTFILES_DIR/confs"
stow -t "$HOME" zsh
# stow -t "$HOME" nvim
# stow -t "$HOME" starship

# Muda o shell padrão para Zsh
if [[ $CHOICES == *"1. Core"* ]]; then
    ZSH_PATH="$(command -v zsh || true)"
    if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
        chsh -s "$ZSH_PATH" || true
    fi
fi

echo ""
gum style --foreground 46 --bold "🎉 Setup concluído com sucesso!"
gum confirm "Deseja reiniciar o terminal agora?" && zsh