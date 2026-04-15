#!/usr/bin/env bash

info() { gum style --foreground 212 "ℹ️ $1"; }
success() { gum style --foreground 46 "✅ $1"; }
warn() { gum style --foreground 226 "⚠️ $1"; }
error() { gum style --foreground 196 "❌ $1"; }

print_header() {
    clear
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "1 2" \
        "BACK TO ME" "Setup Modular v5.0"
}

run_with_spinner() {
    local title="$1"
    shift # Remove o título e pega o resto (o comando)
    
    # Agora usamos o 'bash -c' para rodar o comando perfeitamente no fundo
    if gum spin --spinner dot --title "$title" -- bash -c "$* >> $LOG_FILE 2>&1"; then
        success "$title concluído!"
    else
        error "Falha em: $title. Verifique o $LOG_FILE."
        exit 1
    fi
}