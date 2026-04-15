#!/usr/bin/env bash
install_python() {
    sudo apt-get install -y python3 python3-pip python3-venv
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    install_python
fi