#!/usr/bin/env node

// Script de instalação automatizada do MCP
const readline = require('readline');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Cores para o console
const colors = {
  reset: "\x1b[0m",
  bright: "\x1b[1m",
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m"
};

// Banner inicial
function printBanner() {
  console.log(`${colors.blue}${colors.bright}
  ╔═══════════════════════════════════════════════════════════════╗
  ║                                                               ║
  ║   █▀▄▀█ █▀▀ █▀█   █ █▄░█ █▀ ▀█▀ ▄▀█ █░░ █░░ █▀▀ █▀█          ║
  ║   █░▀░█ █▄▄ █▀▀   █ █░▀█ ▄█ ░█░ █▀█ █▄▄ █▄▄ ██▄ █▀▄          ║
  ║                                                               ║
  ║   Automatização de instalação do ambiente MCP para clientes   ║
  ║                                                               ║
  ╚═══════════════════════════════════════════════════════════════╝
${colors.reset}`);
}

// Interface para leitura de input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Função principal
async function main() {
  printBanner();
  
  // Verificar se está rodando como root/sudo
  if (process.getuid && process.getuid() !== 0) {
    console.log(`${colors.red}Erro: Este script precisa ser executado como root (sudo).${colors.reset}`);
    console.log(`Por favor, execute: ${colors.yellow}sudo node install-mcp.js${colors.reset}\n`);
    process.exit(1);
  }

  // Pedir o nome do cliente
  rl.question(`${colors.green}Digite o nome do cliente (ex: "integra"): ${colors.reset}`, async (clientName) => {
    if (!clientName || clientName.trim() === '') {
      console.log(`${colors.red}Nome do cliente é obrigatório. Saindo.${colors.reset}`);
      rl.close();
      process.exit(1);
    }

    // Remover espaços e caracteres especiais
    const sanitizedName = clientName.trim().toLowerCase().replace(/[^a-z0-9_]/g, '_');
    const installDir = `/opt/mcp_${sanitizedName}`;

    try {
      // Criar diretório de instalação
      console.log(`\n${colors.yellow}[1/6] Criando diretório de instalação em ${installDir}...${colors.reset}`);
      if (!fs.existsSync(installDir)) {
        fs.mkdirSync(installDir, { recursive: true });
        console.log(`${colors.green}✓ Diretório criado com sucesso.${colors.reset}`);
      } else {
        console.log(`${colors.yellow}⚠ Diretório já existe, continuando...${colors.reset}`);
      }

      // Entrar na pasta
      process.chdir(installDir);
      console.log(`${colors.green}✓ Agora estamos no diretório: ${installDir}${colors.reset}`);

      // Atualizar repositórios
      console.log(`\n${colors.yellow}[2/6] Atualizando lista de pacotes...${colors.reset}`);
      execSync('apt update', { stdio: 'inherit' });
      console.log(`${colors.green}✓ Pacotes atualizados com sucesso.${colors.reset}`);

      // Instalar NPM
      console.log(`\n${colors.yellow}[3/6] Instalando npm...${colors.reset}`);
      execSync('apt install -y npm', { stdio: 'inherit' });
      console.log(`${colors.green}✓ npm instalado com sucesso.${colors.reset}`);

      // Instalar n para gerenciar versões do Node.js
      console.log(`\n${colors.yellow}[4/6] Instalando gerenciador de versões do Node.js (n)...${colors.reset}`);
      execSync('npm install -g n', { stdio: 'inherit' });
      console.log(`${colors.green}✓ Gerenciador de versões "n" instalado com sucesso.${colors.reset}`);

      // Instalar a versão mais recente do Node.js
      console.log(`\n${colors.yellow}[5/6] Atualizando Node.js para a última versão estável...${colors.reset}`);
      execSync('n stable', { stdio: 'inherit' });
      console.log(`${colors.green}✓ Node.js atualizado para a última versão estável.${colors.reset}`);

      // Verificar a versão do Node.js instalada
      console.log(`\n${colors.yellow}[6/6] Verificando versão do Node.js instalada...${colors.reset}`);
      const nodeVersion = execSync('node -v').toString().trim();
      const npmVersion = execSync('npm -v').toString().trim();
      console.log(`${colors.green}✓ Node.js ${nodeVersion} instalado com sucesso.${colors.reset}`);
      console.log(`${colors.green}✓ npm ${npmVersion} instalado.${colors.reset}`);

      // Criar README básico no diretório
      const readmeContent = `# MCP ${clientName}

Instalação do MCP para ${clientName} realizada em: ${new Date().toLocaleString()}

## Detalhes da instalação
- Node.js: ${nodeVersion}
- npm: ${npmVersion}
- Diretório: ${installDir}

## Próximos passos:
1. Configure o arquivo .env com as credenciais necessárias
2. Inicie o servidor MCP com \`npm start\`
`;

      fs.writeFileSync(path.join(installDir, 'README.md'), readmeContent);

      console.log(`\n${colors.bright}${colors.green}✅ Instalação concluída com sucesso!${colors.reset}`);
      console.log(`\n${colors.magenta}Resumo da instalação:${colors.reset}`);
      console.log(`- Cliente: ${colors.bright}${clientName}${colors.reset}`);
      console.log(`- Diretório: ${colors.bright}${installDir}${colors.reset}`);
      console.log(`- Node.js: ${colors.bright}${nodeVersion}${colors.reset}`);
      console.log(`- npm: ${colors.bright}${npmVersion}${colors.reset}`);
      console.log(`\n${colors.yellow}Para continuar a configuração do MCP, clone o repositório do cliente neste diretório.${colors.reset}`);
      console.log(`${colors.bright}cd ${installDir}${colors.reset}`);
      console.log(`${colors.bright}git clone https://github.com/seu-usuario/mcp-repo.git .${colors.reset}`);

      rl.close();
    } catch (error) {
      console.error(`\n${colors.red}Erro durante a instalação:${colors.reset}`, error.message);
      rl.close();
      process.exit(1);
    }
  });
}

// Iniciar o script
main().catch(error => {
  console.error(`${colors.red}Erro ao executar o script:${colors.reset}`, error);
  process.exit(1);
}); 
