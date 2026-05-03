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
source "$DOTFILES_DIR/utils/ui.sh"

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
    run_with_spinner "Instalando ferramentas Core e Neovim..." "source '$DOTFILES_DIR/modules/core.sh' && install_core_tools"
fi

if [[ $CHOICES == *"2. Stack Node.js"* ]]; then
    run_with_spinner "Instalando ecossistema Node.js..." "source '$DOTFILES_DIR/modules/node.sh' && install_node"
fi

if [[ $CHOICES == *"3. Stack Java"* ]]; then
    run_with_spinner "Instalando ecossistema Java..." "source '$DOTFILES_DIR/modules/java.sh' && install_java"
fi

if [[ $CHOICES == *"4. Stack Python"* ]]; then
    run_with_spinner "Instalando ecossistema Python..." "source '$DOTFILES_DIR/modules/python.sh' && install_python"
fi

if [[ $CHOICES == *"5. Docker"* ]]; then
    run_with_spinner "Configurando Docker CLI..." "source '$DOTFILES_DIR/modules/core.sh' && install_docker"
fi

# 6. Aplicando as Configurações (GNU Stow)
info "Aplicando Dotfiles via GNU Stow..."
cd "$DOTFILES_DIR/confs"
for dotfile in zsh; do
    conflicts=$(stow --simulate -t "$HOME" "$dotfile" 2>&1 | grep "existing target" | awk '{print $NF}')
    if [ -n "$conflicts" ]; then
        echo ""
        warn "Os seguintes arquivos já existem e seriam sobrescritos por '$dotfile':"
        echo "$conflicts" | while read -r f; do echo "   ~/.${f}"; done
        echo ""
        if gum confirm "Deseja substituir suas configs atuais pelas do BackToMe?"; then
            echo "$conflicts" | while read -r f; do rm -f "$HOME/$f"; done
            stow -t "$HOME" "$dotfile"
            success "Dotfiles de '$dotfile' aplicados!"
        else
            warn "Mantendo suas configs atuais para '$dotfile'. Pulando..."
        fi
    else
        stow -t "$HOME" "$dotfile"
        success "Dotfiles de '$dotfile' aplicados!"
    fi
done
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
gum confirm "Deseja reiniciar o terminal agora?" && zsh -l