#!/bin/bash

# Cores para feedback visual
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
   exit 1
fi

# Tentar redirecionar entrada para /dev/tty se estiver via pipe
if ! [ -t 0 ]; then
    # Estamos em um pipe, tentar redirecionar para /dev/tty
    if [ -e /dev/tty ]; then
        echo -e "${YELLOW}Redirecionando entrada para terminal interativo...${NC}"
        exec < /dev/tty || {
            echo -e "${RED}ERRO: Não foi possível redirecionar para /dev/tty${NC}"
            echo -e "${RED}Por favor, execute o script diretamente:${NC}"
            echo -e "${GREEN}curl -O https://raw.githubusercontent.com/anonimouzmkt/mcp-installer/main/install-mcp-curl.sh${NC}"
            echo -e "${GREEN}sudo bash install-mcp-curl.sh${NC}"
            exit 1
        }
    else
        echo -e "${RED}ERRO: /dev/tty não está disponível. Não é possível solicitar entrada do usuário.${NC}"
        echo -e "${RED}Por favor, execute o script diretamente:${NC}"
        echo -e "${GREEN}curl -O https://raw.githubusercontent.com/anonimouzmkt/mcp-installer/main/install-mcp-curl.sh${NC}"
        echo -e "${GREEN}sudo bash install-mcp-curl.sh${NC}"
        exit 1
    fi
fi

# Sempre perguntar o nome do cliente (ignorar qualquer argumento)
echo -e "${GREEN}Digite o nome do cliente (ex: 'integra'):${NC}"
read -r CLIENT_NAME

# Verificar nome do cliente
if [ -z "$CLIENT_NAME" ]; then
    echo -e "${RED}Nome do cliente é obrigatório. Saindo.${NC}"
    exit 1
fi

echo -e "${GREEN}Nome do cliente confirmado: ${CLIENT_NAME}${NC}"
echo -e "${YELLOW}Iniciando instalação...${NC}"
sleep 1

# Criar diretório de instalação
INSTALL_DIR="/opt/mcp_${CLIENT_NAME}"
echo -e "\n${YELLOW}[1/6] Criando diretório de instalação em ${INSTALL_DIR}...${NC}"
mkdir -p "$INSTALL_DIR"
echo -e "${GREEN}✓ Diretório criado com sucesso.${NC}"

# Entrar na pasta
cd "$INSTALL_DIR" || exit 1
echo -e "${GREEN}✓ Agora estamos no diretório: ${INSTALL_DIR}${NC}"

# Atualizar repositórios
echo -e "\n${YELLOW}[2/6] Atualizando lista de pacotes...${NC}"
apt update
echo -e "${GREEN}✓ Pacotes atualizados com sucesso.${NC}"

# Instalar curl e git
echo -e "\n${YELLOW}[3/6] Instalando dependências básicas...${NC}"
apt install -y curl git nodejs npm
echo -e "${GREEN}✓ Dependências instaladas com sucesso.${NC}"

# Instalar n para gerenciar versões do Node.js
echo -e "\n${YELLOW}[4/6] Instalando gerenciador de versões do Node.js (n)...${NC}"
npm install -g n
echo -e "${GREEN}✓ Gerenciador de versões 'n' instalado com sucesso.${NC}"

# Instalar a versão mais recente do Node.js
echo -e "\n${YELLOW}[5/6] Atualizando Node.js para a última versão estável...${NC}"
n stable
PATH="$PATH"
NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
echo -e "${GREEN}✓ Node.js ${NODE_VERSION} instalado com sucesso.${NC}"
echo -e "${GREEN}✓ npm ${NPM_VERSION} instalado com sucesso.${NC}"

# Clonar o repositório do MCP
echo -e "\n${YELLOW}[6/6] Clonando repositório MCP...${NC}"
git clone https://github.com/anonimouzmkt/mcp-repo.git .
if [ $? -ne 0 ]; then
    echo -e "${RED}Falha ao clonar o repositório. Verifique a conexão ou URL do repositório.${NC}"
    echo -e "${YELLOW}O ambiente foi parcialmente configurado em: ${INSTALL_DIR}${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Repositório clonado com sucesso.${NC}"
fi

# Instalar dependências do projeto
echo -e "\n${YELLOW}Instalando dependências do projeto...${NC}"
if [ -f "package.json" ]; then
    npm install
    echo -e "${GREEN}✓ Dependências do projeto instaladas com sucesso.${NC}"
else
    echo -e "${YELLOW}Arquivo package.json não encontrado. Pulando instalação de dependências.${NC}"
fi

# Criar arquivo de configuração
echo -e "\n${YELLOW}Criando arquivo de configuração...${NC}"
cat > "${INSTALL_DIR}/install_info.txt" << EOF
MCP ${CLIENT_NAME}
Instalação realizada em: $(date)
Node.js: ${NODE_VERSION}
npm: ${NPM_VERSION}
Diretório: ${INSTALL_DIR}
EOF
echo -e "${GREEN}✓ Arquivo de configuração criado com sucesso.${NC}"

echo -e "\n${GREEN}✅ Instalação concluída com sucesso!${NC}"
echo -e "\n${YELLOW}Resumo da instalação:${NC}"
echo -e "- Cliente: ${GREEN}${CLIENT_NAME}${NC}"
echo -e "- Diretório: ${GREEN}${INSTALL_DIR}${NC}"
echo -e "- Node.js: ${GREEN}${NODE_VERSION}${NC}"
echo -e "- npm: ${GREEN}${NPM_VERSION}${NC}"

echo -e "\n${BLUE}Próximos passos:${NC}"
echo -e "1. Configure o arquivo .env com as credenciais do cliente"
echo -e "2. Inicie o servidor MCP com: ${GREEN}cd ${INSTALL_DIR} && npm start${NC}"

exit 0 
