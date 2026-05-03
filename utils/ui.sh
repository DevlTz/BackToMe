#!/usr/bin/env bash

info()    { gum style --foreground 212 "ℹ️  $1"; }
success() { gum style --foreground 46  "✅ $1"; }
warn()    { gum style --foreground 226 "⚠️  $1"; }
error()   { gum style --foreground 196 "❌ $1"; }

print_header() {
    clear
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "1 2" \
        "BACK TO ME" "O setup definitivo para ambientes de desenvolvimento WSL"
}

# Variáveis de progresso globais
PROGRESS_CURRENT=0
PROGRESS_TOTAL=0

init_progress() {
    PROGRESS_TOTAL=$1
    PROGRESS_CURRENT=0
}

_render_bar() {
    local current=$1
    local total=$2
    local width=30
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    local pct=$(( current * 100 / total ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++));  do bar+="░"; done
    gum style --foreground 212 "  [${bar}] ${pct}%"
}

run_with_spinner() {
    local title="$1"
    local cmd="$2"
    PROGRESS_CURRENT=$(( PROGRESS_CURRENT + 1 ))

    echo ""
    gum style --foreground 99 --bold "[${PROGRESS_CURRENT}/${PROGRESS_TOTAL}] ${title}"
    _render_bar "$PROGRESS_CURRENT" "$PROGRESS_TOTAL"

    if gum spin --spinner dot --title " Executando..." -- bash -c "$cmd" >> "$LOG_FILE" 2>&1; then
        success "${title} concluído!"
    else
        error "Falha em: ${title}. Verifique o ${LOG_FILE}."
        cat "$LOG_FILE" >&2
        exit 1
    fi
}