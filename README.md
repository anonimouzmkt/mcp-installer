# MCP Installer

Script de instalação automatizada para configurar ambientes MCP (Model Context Protocol) para clientes em servidores Linux.

![MCP Banner](https://raw.githubusercontent.com/seu-usuario/mcp-installer/main/banner.png)

## 🚀 Instalação Rápida (Para funcionários)

Execute o comando abaixo no terminal do servidor do cliente como root:

```bash
curl -sSL https://raw.githubusercontent.com/seu-usuario/mcp-installer/main/install-mcp-curl.sh | sudo bash
```

O script irá:
1. Solicitar o nome do cliente
2. Criar o diretório `/opt/mcp_NOME_DO_CLIENTE`
3. Instalar e atualizar o Node.js para a versão mais recente
4. Configurar o ambiente básico

## 📋 Requisitos

- Sistema operacional: Ubuntu 20.04+ ou Debian 10+
- Permissão de root/sudo
- Conexão com a Internet

## 📦 O que o script faz?

1. Cria um diretório dedicado para o MCP do cliente (`/opt/mcp_nome_do_cliente`)
2. Executa `apt update` para atualizar lista de pacotes
3. Instala o npm
4. Instala o gerenciador de versões 'n' para o Node.js
5. Atualiza o Node.js para a versão estável mais recente
6. Gera um README.md básico com as informações da instalação

## 🔍 Opções Avançadas

Se você precisar mais controle sobre a instalação, você pode baixar o script principal e executá-lo manualmente:

```bash
# Baixar o script
wget https://raw.githubusercontent.com/seu-usuario/mcp-installer/main/install-mcp.js

# Dar permissão de execução
chmod +x install-mcp.js

# Executar o script
sudo node install-mcp.js
```

## 🔧 Solução de Problemas

Se encontrar algum erro durante a instalação:

1. Verifique se você está executando como root/sudo
2. Verifique a conexão com a internet
3. Certifique-se de que o sistema operacional é compatível

## 📝 Próximos Passos Após a Instalação

Após a instalação bem-sucedida:

1. Navegue até o diretório criado: `cd /opt/mcp_nome_do_cliente`
2. Clone o repositório MCP específico do cliente
3. Configure o arquivo `.env` com as credenciais apropriadas
4. Inicie o servidor MCP com `npm start`

## ⚖️ Licença

Copyright © 2024. Todos os direitos reservados. 
