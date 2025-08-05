# ===================================
# SCRIPT DE GERENCIAMENTO DOS SERVIÇOS
# ===================================
# Este script facilita o gerenciamento dos serviços Docker

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("up", "down", "restart", "logs", "status", "reset")]
    [string]$Action,
    
    [string]$Service = "all"
)

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "INFO: $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Start-Services {
    Write-Info "Iniciando todos os serviços..."
    docker-compose up -d
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Serviços iniciados com sucesso!"
        Show-ServiceStatus
        Show-ServiceUrls
    } else {
        Write-Error "Falha ao iniciar os serviços."
    }
}

function Stop-Services {
    Write-Info "Parando todos os serviços..."
    docker-compose down
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Serviços parados com sucesso!"
    } else {
        Write-Error "Falha ao parar os serviços."
    }
}

function Restart-Services {
    Write-Info "Reiniciando serviços..."
    if ($Service -eq "all") {
        docker-compose restart
    } else {
        docker-compose restart $Service
    }
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Serviços reiniciados com sucesso!"
    } else {
        Write-Error "Falha ao reiniciar os serviços."
    }
}

function Show-Logs {
    Write-Info "Exibindo logs dos serviços..."
    if ($Service -eq "all") {
        docker-compose logs -f --tail=100
    } else {
        docker-compose logs -f --tail=100 $Service
    }
}

function Show-ServiceStatus {
    Write-Info "Status dos serviços:"
    docker-compose ps
}

function Show-ServiceUrls {
    Write-Info ""
    Write-Info "==============================================="
    Write-Info "URLs DOS SERVIÇOS DISPONÍVEIS"
    Write-Info "==============================================="
    Write-Host ""
    Write-Host "🌐 SERVIÇOS LOCAIS:" -ForegroundColor Cyan
    Write-Host "   Nextcloud:      http://localhost:777" -ForegroundColor White
    Write-Host "   N8N:           http://localhost:5678" -ForegroundColor White
    Write-Host "   Grafana:       http://localhost:3000" -ForegroundColor White
    Write-Host "   Evolution API: http://localhost:8080" -ForegroundColor White
    Write-Host "   RabbitMQ Mgmt: http://localhost:15672" -ForegroundColor White
    Write-Host "   PostgreSQL:    localhost:5432" -ForegroundColor White
    Write-Host "   Redis:         localhost:6379" -ForegroundColor White
    Write-Host ""
    Write-Host "🌍 SERVIÇOS EXTERNOS (Cloudflare Tunnel):" -ForegroundColor Cyan
    Write-Host "   Nextcloud:      https://nextcloud.roladb.com.br" -ForegroundColor White
    Write-Host "   N8N:           https://n8n.roladb.com.br" -ForegroundColor White
    Write-Host "   Grafana:       https://grafana.roladb.com.br" -ForegroundColor White
    Write-Host "   Evolution API: https://evolution.roladb.com.br" -ForegroundColor White
    Write-Host "   RabbitMQ Mgmt: https://rabbitmq.roladb.com.br" -ForegroundColor White
    Write-Host ""
    Write-Host "🔐 CREDENCIAIS PADRÃO:" -ForegroundColor Yellow
    Write-Host "   N8N:           admin / admin123" -ForegroundColor White
    Write-Host "   Grafana:       t6t / bDpv887pCn@YT" -ForegroundColor White
    Write-Host "   RabbitMQ:      t6t / bDpv887pCn@YT" -ForegroundColor White
    Write-Host "   PostgreSQL:    n8n / n8n_password" -ForegroundColor White
    Write-Host "   Redis:         redis_password" -ForegroundColor White
    Write-Host "   Evolution API: evolution_api_key_123456" -ForegroundColor White
    Write-Host ""
    Write-Info "==============================================="
}

function Reset-Environment {
    Write-Warning "ATENÇÃO: Esta operação irá remover TODOS os dados dos serviços!"
    $confirmation = Read-Host "Digite 'CONFIRMAR' para prosseguir"
    
    if ($confirmation -eq "CONFIRMAR") {
        Write-Info "Parando e removendo todos os containers..."
        docker-compose down -v --remove-orphans
        
        Write-Info "Removendo volumes..."
        docker volume prune -f
        
        Write-Info "Removendo imagens não utilizadas..."
        docker image prune -f
        
        Write-Info "Ambiente resetado com sucesso!"
    } else {
        Write-Info "Operação cancelada."
    }
}

# Verificar se estamos no diretório correto
if (!(Test-Path "docker-compose.yml")) {
    Write-Error "docker-compose.yml não encontrado. Execute este script no diretório do projeto."
    exit 1
}

# Executar ação solicitada
switch ($Action) {
    "up" { Start-Services }
    "down" { Stop-Services }
    "restart" { Restart-Services }
    "logs" { Show-Logs }
    "status" { 
        Show-ServiceStatus
        Show-ServiceUrls
    }
    "reset" { Reset-Environment }
}

Write-Info "Operação concluída!"
