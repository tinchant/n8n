# ===================================
# SCRIPT DE VALIDAÇÃO DOS SERVIÇOS
# ===================================
# Este script verifica se todos os serviços estão funcionando corretamente

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

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-ServiceHealth {
    param(
        [string]$ServiceName,
        [string]$Url,
        [int]$ExpectedStatus = 200,
        [int]$Timeout = 10
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec $Timeout -UseBasicParsing
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Success "$ServiceName está funcionando (Status: $($response.StatusCode))"
            return $true
        } else {
            Write-Fail "$ServiceName retornou status inesperado: $($response.StatusCode)"
            return $false
        }
    } catch {
        Write-Fail "$ServiceName não está acessível: $($_.Exception.Message)"
        return $false
    }
}

function Test-DatabaseConnection {
    param(
        [string]$ServiceName,
        [string]$ContainerName,
        [string]$Command
    )
    
    try {
        $result = docker exec $ContainerName bash -c $Command 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$ServiceName - Conexão com banco de dados OK"
            return $true
        } else {
            Write-Fail "$ServiceName - Falha na conexão com banco: $result"
            return $false
        }
    } catch {
        Write-Fail "$ServiceName - Erro ao testar conexão: $($_.Exception.Message)"
        return $false
    }
}

function Test-ContainerHealth {
    param([string]$ContainerName)
    
    try {
        $health = docker inspect --format='{{.State.Health.Status}}' $ContainerName 2>$null
        if ($health -eq "healthy") {
            Write-Success "Container $ContainerName está saudável"
            return $true
        } elseif ($health -eq "starting") {
            Write-Warning "Container $ContainerName ainda está iniciando"
            return $false
        } elseif ($health -eq "unhealthy") {
            Write-Fail "Container $ContainerName não está saudável"
            return $false
        } else {
            Write-Warning "Container $ContainerName não possui health check configurado"
            return $true
        }
    } catch {
        Write-Fail "Container $ContainerName não encontrado ou não está rodando"
        return $false
    }
}

Write-Info "=================================================="
Write-Info "INICIANDO VALIDAÇÃO DOS SERVIÇOS"
Write-Info "=================================================="
Write-Host ""

# Verificar se o Docker Compose está rodando
Write-Info "Verificando status dos containers..."
$containers = docker-compose ps -q 2>$null
if ($containers.Count -eq 0) {
    Write-Fail "Nenhum container está rodando. Execute 'docker-compose up -d' primeiro."
    exit 1
}

$allServicesHealthy = $true

Write-Info "Testando health checks dos containers..."
Write-Host ""

# Testar health checks
$healthChecks = @(
    "nextcloud-docker-postgres-1",
    "nextcloud-docker-redis-1", 
    "n8n_rabbitmq",
    "n8n_grafana",
    "nextcloud-docker-n8n-1",
    "nextcloud-docker-evolution-api-1"
)

foreach ($container in $healthChecks) {
    $isHealthy = Test-ContainerHealth -ContainerName $container
    if (-not $isHealthy) { $allServicesHealthy = $false }
}

Write-Host ""
Write-Info "Testando conectividade HTTP dos serviços..."
Write-Host ""

# Testar conectividade HTTP
$httpTests = @(
    @{ Name = "Nextcloud"; Url = "http://localhost:777"; Status = 200 },
    @{ Name = "N8N"; Url = "http://localhost:5678"; Status = 200 },
    @{ Name = "Grafana"; Url = "http://localhost:3000"; Status = 200 },
    @{ Name = "Evolution API"; Url = "http://localhost:8080"; Status = 200 },
    @{ Name = "RabbitMQ Management"; Url = "http://localhost:15672"; Status = 200 }
)

foreach ($test in $httpTests) {
    $isHealthy = Test-ServiceHealth -ServiceName $test.Name -Url $test.Url -ExpectedStatus $test.Status
    if (-not $isHealthy) { $allServicesHealthy = $false }
}

Write-Host ""
Write-Info "Testando conectividade com bancos de dados..."
Write-Host ""

# Testar conexões de banco
$dbTests = @(
    @{ 
        Name = "PostgreSQL - N8N"; 
        Container = "n8n_postgres"; 
        Command = "pg_isready -h localhost -U n8n -d n8n" 
    },
    @{ 
        Name = "PostgreSQL - Evolution"; 
        Container = "n8n_postgres"; 
        Command = "pg_isready -h localhost -U n8n -d evolution" 
    },
    @{ 
        Name = "MariaDB - Nextcloud"; 
        Container = "nextcloud-docker-db-1"; 
        Command = "mysql -u nextcloud -pnextcloud -e 'SELECT 1;'" 
    }
)

foreach ($test in $dbTests) {
    $isHealthy = Test-DatabaseConnection -ServiceName $test.Name -ContainerName $test.Container -Command $test.Command
    if (-not $isHealthy) { $allServicesHealthy = $false }
}

Write-Host ""
Write-Info "Testando conectividade Redis..."
Write-Host ""

# Testar Redis
try {
    $redisTest = docker exec n8n_redis redis-cli -a redis_password ping 2>&1
    if ($redisTest -eq "PONG") {
        Write-Success "Redis está respondendo corretamente"
    } else {
        Write-Fail "Redis não está respondendo: $redisTest"
        $allServicesHealthy = $false
    }
} catch {
    Write-Fail "Erro ao testar Redis: $($_.Exception.Message)"
    $allServicesHealthy = $false
}

Write-Host ""
Write-Info "=================================================="

if ($allServicesHealthy) {
    Write-Success "TODOS OS SERVIÇOS ESTÃO FUNCIONANDO CORRETAMENTE! ✅"
    Write-Host ""
    Write-Info "URLs para acesso:"
    Write-Host "  🌐 Nextcloud:      http://localhost:777" -ForegroundColor Cyan
    Write-Host "  🔄 N8N:           http://localhost:5678" -ForegroundColor Cyan
    Write-Host "  📊 Grafana:       http://localhost:3000" -ForegroundColor Cyan
    Write-Host "  💬 Evolution API: http://localhost:8080" -ForegroundColor Cyan
    Write-Host "  🐰 RabbitMQ:      http://localhost:15672" -ForegroundColor Cyan
} else {
    Write-Fail "ALGUNS SERVIÇOS APRESENTARAM PROBLEMAS! ❌"
    Write-Warning "Verifique os logs com: docker-compose logs -f"
}

Write-Info "=================================================="
