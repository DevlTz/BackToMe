<div align="center">

## BackToMe

> *"Trazendo meu ambiente de volta para mim, em qualquer lugar."*

**BackToMe** é o meu repositório pessoal de *dotfiles* e automação de setup. Ele transforma uma instalação "crua" do Ubuntu — seja no **WSL2** ou nativo — em uma máquina de desenvolvimento de alta performance, focada em **React, Java, Python e C++**, em questão de minutos.

![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge\&logo=ubuntu\&logoColor=white)
![Zsh](https://img.shields.io/badge/Zsh-1E2431?style=for-the-badge\&logo=zsh\&logoColor=white)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?\&style=for-the-badge\&logo=neovim\&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge\&logo=docker\&logoColor=white)

</div>

## Preview


---

## O que tem na caixa?

Este setup instala e configura automaticamente:

* **Core e navegação:** Zsh, Oh My Zsh, Zoxide (*cd inteligente*), Eza (*ls moderno*), FZF, Bat e Fastfetch.
* **Dev Stack:** Node.js via NVM, Java/Spring via SDKMAN!, Python 3 e C++ com GCC, CMake e Ninja.
* **Docker:** CLI nativa integrada com o Docker Desktop do Windows.
* **Editor e Git:** Neovim com LazyVim, Lazygit e GitHub CLI (`gh`).
* **Gerenciamento:** GNU Stow para organizar e aplicar os dotfiles com links simbólicos.

---

## Como instalar

1. No seu Ubuntu limpo, instale o Git:

   ```bash
   sudo apt update && sudo apt install git -y
   ```

2. Clone o BackToMe:

   ```bash
   git clone https://github.com/SEU-USUARIO/BackToMe.git ~/BackToMe
   cd ~/BackToMe
   ```

3. Execute o script de instalação:

   ```bash
   chmod +x install.sh
   ./install.sh
   ```

---

## Arquitetura com GNU Stow

A estrutura de pastas foi desenhada para funcionar com o **GNU Stow**. Para aplicar ou atualizar uma configuração, basta usar o pacote desejado:

```bash
cd ~/BackToMe
stow zsh      # Linka o .zshrc
stow nvim     # Linka as configs do Neovim
stow tmux     # Linka as configs do Tmux
```

---

## Aliases principais

| Comando         | O que faz                                          |
| --------------- | -------------------------------------------------- |
| `p`             | Vai direto para a pasta de projetos (`~/projects`) |
| `v`             | Abre o Neovim                                      |
| `lg`            | Abre o Lazygit                                     |
| `n-vite <nome>` | Scaffold rápido de React + Vite + TypeScript       |
| `ll`            | Lista arquivos com ícones modernos                 |

---

## O que já vem pronto

* Prompt mais bonito e útil com **Starship**.
* Navegação mais rápida com **Zoxide**.
* Busca de arquivos e histórico com **FZF**.
* Ferramentas modernas de terminal como **Eza**, **Bat** e **Fastfetch**.
* Ambiente pronto para **React, Vite, Python, Java, Spring Boot e C++**.
* Integração com **Docker Desktop + WSL2**.

---

## Ideia central

O objetivo do BackToMe é simples: deixar qualquer máquina com a mesma sensação de ambiente pessoal, rápido, limpo e pronto para estudar e programar.

---

## Contribuição

Este projeto é pessoal, mas ideias e melhorias são bem-vindas.

---

Feito para produtividade por **| Kauã do Vale Ferreira | [@DevlTz](https://github.com/DevlTz) |.**
