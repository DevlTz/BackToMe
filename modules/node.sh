#!/usr/bin/env bash
 
install_node() {
    if [ ! -d "$HOME/.nvm" ]; then
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts
        npm install -g pnpm yarn
    fi
}
 
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    install_node
fi