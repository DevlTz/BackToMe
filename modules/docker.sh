#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    sudo rm -f /etc/apt/sources.list.d/docker.list
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update -y
    sudo apt-get install -y docker-ce-cli docker-compose-plugin
    sudo usermod -aG docker $USER || true
fi