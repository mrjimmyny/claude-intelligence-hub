# setup_new_project.ps1
# Configura um novo projeto Power BI com skills do hub

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [Parameter(Mandatory=$false)]
    [string]$HubUrl = "https://github.com/mrjimmyny/claude-intelligence-hub.git"
)

Write-Host "[SETUP] Configurando novo projeto Power BI..." -ForegroundColor Cyan
Write-Host "Project: $ProjectPath" -ForegroundColor White
Write-Host ""

# Validar que projeto existe
if (-not (Test-Path $ProjectPath)) {
    Write-Host "ERROR: Projeto nao encontrado: $ProjectPath" -ForegroundColor Red
    exit 1
}

# 1. Criar estrutura .claude/
Write-Host "[CREATE] Criando estrutura .claude/..." -ForegroundColor Yellow
$claudeDir = Join-Path $ProjectPath ".claude"
$skillsDir = Join-Path $claudeDir "skills"
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null

# 2. Clonar hub (se não existir)
$hubDir = Join-Path $claudeDir "_hub"
if (Test-Path $hubDir) {
    Write-Host "  INFO: Hub ja existe, atualizando..." -ForegroundColor DarkYellow
    Push-Location $hubDir
    git pull origin main | Out-Null
    Pop-Location
} else {
    Write-Host "[CLONE] Clonando skills do GitHub..." -ForegroundColor Yellow
    git clone $HubUrl $hubDir --quiet
}

# 3. Copiar skills (copia direta - mais confiavel que symlink)
Write-Host "[COPY] Copiando skills para o projeto..." -ForegroundColor Yellow
$hubSkillsPath = Join-Path $hubDir "pbi-claude-skills\skills"
Copy-Item "$hubSkillsPath\*" $skillsDir -Recurse -Force

# 4. Copiar templates
Write-Host "[FILES] Copiando templates..." -ForegroundColor Yellow
$templatesPath = Join-Path $hubDir "pbi-claude-skills\templates"

# .claudecode.json (vai para raiz do projeto - REGRA DE OURO)
Copy-Item "$templatesPath\.claudecode.template.json" "$ProjectPath\.claudecode.json" -Force

# settings.local.json (vai para .claude/)
Copy-Item "$templatesPath\settings.local.template.json" "$claudeDir\settings.local.json" -Force

# pbi_config.json (vai para raiz do projeto)
$configPath = Join-Path $ProjectPath "pbi_config.json"
if (-not (Test-Path $configPath)) {
    Copy-Item "$templatesPath\pbi_config.template.json" $configPath -Force

    # 5. Detectar nome do semantic model e atualizar config
    Write-Host "[DETECT] Detectando semantic model..." -ForegroundColor Yellow
    $pbipFiles = Get-ChildItem $ProjectPath -Filter "*.SemanticModel" -Directory

    if ($pbipFiles.Count -eq 1) {
        $modelName = $pbipFiles[0].Name
        Write-Host "  OK: Semantic model detectado: $modelName" -ForegroundColor Green

        # Atualizar pbi_config.json com nome correto
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        $config.project.semantic_model.name = $modelName
        $config.project.semantic_model.path = "$modelName/definition"
        $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    } else {
        Write-Host "  WARNING: Multiplos ou nenhum semantic model encontrado" -ForegroundColor DarkYellow
        Write-Host "     Edite manualmente: $configPath" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  INFO: pbi_config.json ja existe (nao sobrescrito)" -ForegroundColor DarkYellow
}

# 6. Criar POWER_BI_INDEX.md vazio (se não existir)
$indexPath = Join-Path $ProjectPath "POWER_BI_INDEX.md"
if (-not (Test-Path $indexPath)) {
    Write-Host "[CREATE] Criando POWER_BI_INDEX.md..." -ForegroundColor Yellow
    New-Item $indexPath -ItemType File -Force | Out-Null
}

Write-Host ""
Write-Host "OK: Projeto configurado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "  1. Editar pbi_config.json com informacoes do projeto" -ForegroundColor White
Write-Host "     Path: $configPath" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  2. Executar /pbi-index-update para gerar indice completo" -ForegroundColor White
Write-Host "     (Abra Claude Code no projeto e execute o comando)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  3. Testar com /pbi-query-structure tabelas" -ForegroundColor White
Write-Host ""
Write-Host "Link: Skills instaladas de: $HubUrl" -ForegroundColor DarkCyan
Write-Host "Docs: https://github.com/mrjimmyny/claude-intelligence-hub/tree/main/pbi-claude-skills" -ForegroundColor DarkCyan
