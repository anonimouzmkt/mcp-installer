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

# Solução para entrada interativa quando executado via pipe (curl | bash)
exec < /dev/tty || true

# Pedir nome do cliente diretamente aqui
echo -e "${GREEN}Digite o nome do cliente (ex: 'integra'):${NC}"
read -r clientName

# Se /dev/tty não estiver disponível e nenhum nome for fornecido, use um padrão
if [ -z "$clientName" ]; then
    # Verifica se estamos sendo executados por pipe
    if [ ! -t 0 ]; then
        echo -e "${YELLOW}Detectado uso via pipe (curl | bash). Solicitando entrada manual...${NC}"
        echo -e "${YELLOW}Execute o script novamente diretamente:${NC}"
        echo -e "${GREEN}1. Baixe o script: curl -O https://raw.githubusercontent.com/anonimouzmkt/mcp-installer/main/install-mcp-curl.sh${NC}"
        echo -e "${GREEN}2. Execute: sudo bash install-mcp-curl.sh${NC}"
        exit 1
    else
        echo -e "${RED}Nome do cliente é obrigatório. Saindo.${NC}"
        exit 1
    fi
fi

# Sanitizar o nome (remover espaços e caracteres especiais)
sanitizedName=$(echo "$clientName" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g')
installDir="/opt/mcp_${sanitizedName}"

# Criar diretório de instalação
echo -e "\n${YELLOW}[1/6] Criando diretório de instalação em ${installDir}...${NC}"
mkdir -p "$installDir"
echo -e "${GREEN}✓ Diretório criado com sucesso.${NC}"

# Entrar na pasta
cd "$installDir"
echo -e "${GREEN}✓ Agora estamos no diretório: ${installDir}${NC}"

# Atualizar repositórios
echo -e "\n${YELLOW}[2/6] Atualizando lista de pacotes...${NC}"
apt update
echo -e "${GREEN}✓ Pacotes atualizados com sucesso.${NC}"

# Instalar NPM
echo -e "\n${YELLOW}[3/6] Instalando npm...${NC}"
apt install -y npm
echo -e "${GREEN}✓ npm instalado com sucesso.${NC}"

# Instalar n para gerenciar versões do Node.js
echo -e "\n${YELLOW}[4/6] Instalando gerenciador de versões do Node.js (n)...${NC}"
npm install -g n
echo -e "${GREEN}✓ Gerenciador de versões 'n' instalado com sucesso.${NC}"

# Instalar a versão mais recente do Node.js
echo -e "\n${YELLOW}[5/6] Atualizando Node.js para a última versão estável...${NC}"
n stable
echo -e "${GREEN}✓ Node.js atualizado para a última versão estável.${NC}"

# Verificar a versão do Node.js instalada
echo -e "\n${YELLOW}[6/6] Verificando versão do Node.js instalada...${NC}"
nodeVersion=$(node -v)
npmVersion=$(npm -v)
echo -e "${GREEN}✓ Node.js ${nodeVersion} instalado com sucesso.${NC}"
echo -e "${GREEN}✓ npm ${npmVersion} instalado.${NC}"

# Criar README básico no diretório
cat > "$installDir/README.md" << EOF
# MCP ${clientName}

Instalação do MCP para ${clientName} realizada em: $(date)

## Detalhes da instalação
- Node.js: ${nodeVersion}
- npm: ${npmVersion}
- Diretório: ${installDir}

## Próximos passos:
1. Configure o arquivo .env com as credenciais necessárias
2. Inicie o servidor MCP com \`npm start\`
EOF

echo -e "\n${GREEN}✅ Instalação concluída com sucesso!${NC}"
echo -e "\n${YELLOW}Resumo da instalação:${NC}"
echo -e "- Cliente: ${GREEN}${clientName}${NC}"
echo -e "- Diretório: ${GREEN}${installDir}${NC}"
echo -e "- Node.js: ${GREEN}${nodeVersion}${NC}"
echo -e "- npm: ${GREEN}${npmVersion}${NC}"

echo -e "\n${YELLOW}Para continuar a configuração do MCP, clone o repositório do cliente neste diretório.${NC}"
echo -e "${GREEN}cd ${installDir}${NC}"
echo -e "${GREEN}git clone https://github.com/seu-usuario/mcp-repo.git .${NC}"

echo -e "${GREEN}Script de instalação finalizado!${NC}" 
