# ===================================
# SCRIPT DE GERENCIAMENTO DNS CLOUDFLARE
# ===================================
# Este script facilita o gerenciamento das rotas DNS do Cloudflare Tunnel

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("add", "remove", "list", "update")]
    [string]$Action,
    
    [string]$Hostname = "",
    [string]$TunnelId = "bd4383e1-cca8-4ddf-afbf-c64cc2e2fcb1"
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

function Add-DnsRoute {
    param([string]$Hostname, [string]$TunnelId)
    
    Write-Info "Adicionando rota DNS para $Hostname..."
    try {
        $result = docker exec cloudflared cloudflared tunnel route dns $TunnelId $Hostname
        Write-Info "Rota DNS criada com sucesso para $Hostname"
        return $true
    } catch {
        Write-Error "Falha ao criar rota DNS para $Hostname : $($_.Exception.Message)"
        return $false
    }
}

function Remove-DnsRoute {
    param([string]$Hostname, [string]$TunnelId)
    
    Write-Info "Removendo rota DNS para $Hostname..."
    try {
        # Cloudflare não tem comando direto para remover via CLI, precisa ser feito no dashboard
        Write-Warning "Para remover rotas DNS, acesse o dashboard do Cloudflare em:"
        Write-Warning "https://dash.cloudflare.com/ > DNS > Records"
        Write-Warning "E remova o registro CNAME para $Hostname"
        return $true
    } catch {
        Write-Error "Falha ao processar remoção: $($_.Exception.Message)"
        return $false
    }
}

function Update-AllRoutes {
    param([string]$TunnelId)
    
    Write-Info "Atualizando todas as rotas DNS do projeto..."
    
    $routes = @(
        "n8n.roladb.com.br",
        "grafana.roladb.com.br", 
        "evolution.roladb.com.br",
        "rabbitmq.roladb.com.br"
    )
    
    $success = $true
    foreach ($route in $routes) {
        if (-not (Add-DnsRoute -Hostname $route -TunnelId $TunnelId)) {
            $success = $false
        }
    }
    
    if ($success) {
        Write-Info "Todas as rotas DNS foram atualizadas com sucesso!"
        Write-Info "Reiniciando Cloudflare Tunnel..."
        docker-compose restart cloudflared
        Write-Info "Aguarde alguns minutos para a propagação DNS..."
    } else {
        Write-Error "Algumas rotas falharam. Verifique os logs acima."
    }
}

function Show-Routes {
    Write-Info "Rotas DNS configuradas para o projeto:"
    Write-Host ""
    Write-Host "🌍 DOMÍNIOS EXTERNOS:" -ForegroundColor Cyan
    Write-Host "   ✅ Nextcloud:      https://nextcloud.roladb.com.br" -ForegroundColor White
    Write-Host "   ✅ N8N:           https://n8n.roladb.com.br" -ForegroundColor White
    Write-Host "   ✅ Grafana:       https://grafana.roladb.com.br" -ForegroundColor White
    Write-Host "   ✅ Evolution API: https://evolution.roladb.com.br" -ForegroundColor White
    Write-Host "   ✅ RabbitMQ Mgmt: https://rabbitmq.roladb.com.br" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 CONFIGURAÇÃO LOCAL:" -ForegroundColor Cyan
    Write-Host "   Arquivo: .cloudflared/config.yml" -ForegroundColor White
    Write-Host "   Tunnel ID: $TunnelId" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 GERENCIAMENTO:" -ForegroundColor Cyan
    Write-Host "   Dashboard: https://dash.cloudflare.com/" -ForegroundColor White
    Write-Host "   Zero Trust: https://one.dash.cloudflare.com/" -ForegroundColor White
}

# Verificar se estamos no diretório correto
if (!(Test-Path "docker-compose.yml")) {
    Write-Error "docker-compose.yml não encontrado. Execute este script no diretório do projeto."
    exit 1
}

# Verificar se o container cloudflared está rodando
$cloudflaredRunning = docker ps --format "{{.Names}}" | Where-Object { $_ -eq "cloudflared" }
if (-not $cloudflaredRunning) {
    Write-Error "Container cloudflared não está rodando. Execute 'docker-compose up -d' primeiro."
    exit 1
}

# Executar ação solicitada
switch ($Action) {
    "add" {
        if ([string]::IsNullOrEmpty($Hostname)) {
            Write-Error "Hostname é obrigatório para adicionar rota. Use -Hostname 'dominio.com'"
            exit 1
        }
        Add-DnsRoute -Hostname $Hostname -TunnelId $TunnelId
    }
    "remove" {
        if ([string]::IsNullOrEmpty($Hostname)) {
            Write-Error "Hostname é obrigatório para remover rota. Use -Hostname 'dominio.com'"
            exit 1
        }
        Remove-DnsRoute -Hostname $Hostname -TunnelId $TunnelId
    }
    "list" {
        Show-Routes
    }
    "update" {
        Update-AllRoutes -TunnelId $TunnelId
    }
}

Write-Info "Operação concluída!"
