#!/bin/bash

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║   █▀▄▀█ █▀▀ █▀█   █ █▄░█ █▀ ▀█▀ ▄▀█ █░░ █░░ █▀▀ █▀█          ║"
echo "║   █░▀░█ █▄▄ █▀▀   █ █░▀█ ▄█ ░█░ █▀█ █▄▄ █▄▄ ██▄ █▀▄          ║"
echo "║                                                               ║"
echo "║   Instalador do ambiente MCP para clientes via curl           ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar se está rodando como root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}Erro: Este script precisa ser executado como root (sudo).${NC}"
   echo -e "Por favor, execute: ${YELLOW}sudo bash $0${NC}"
   exit 1
fi

# Verificar se o curl está instalado
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}Instalando curl...${NC}"
    apt update
    apt install -y curl
fi

# Verificar se o Node.js está instalado
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js não encontrado. Instalando...${NC}"
    apt update
    apt install -y nodejs npm
fi

# Download do script de instalação
echo -e "${GREEN}Baixando script de instalação do MCP...${NC}"
curl -o install-mcp.js https://raw.githubusercontent.com/seu-usuario/mcp-installer/main/install-mcp.js

# Tornar o script executável
chmod +x install-mcp.js

# Executar o script
echo -e "${GREEN}Iniciando instalação do MCP...${NC}"
node install-mcp.js

# Remover o script após a execução
rm install-mcp.js

echo -e "${GREEN}Script de instalação finalizado!${NC}" 
