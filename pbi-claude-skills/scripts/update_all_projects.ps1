# update_all_projects.ps1
# Atualiza skills em todos os projetos Power BI configurados

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectsRoot = "C:\Users\$env:USERNAME\Downloads\_pbi_projs",

    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false
)

Write-Host "🔄 Atualizando skills em todos os projetos..." -ForegroundColor Cyan
Write-Host "📂 Root: $ProjectsRoot" -ForegroundColor White
Write-Host ""

# Verificar se root existe
if (-not (Test-Path $ProjectsRoot)) {
    Write-Host "❌ ERRO: Diretório não encontrado: $ProjectsRoot" -ForegroundColor Red
    Write-Host "   Use: .\update_all_projects.ps1 -ProjectsRoot 'C:\seu\path'" -ForegroundColor Yellow
    exit 1
}

# Buscar projetos (padrão: _project_pbip_*)
$projects = Get-ChildItem $ProjectsRoot -Filter "_project_pbip_*" -Directory

if ($projects.Count -eq 0) {
    Write-Host "⚠️  Nenhum projeto encontrado em $ProjectsRoot" -ForegroundColor Yellow
    Write-Host "   Padrão de busca: _project_pbip_*" -ForegroundColor DarkYellow
    exit 0
}

Write-Host "📊 Encontrados: $($projects.Count) projeto(s)" -ForegroundColor Green
Write-Host ""

$updated = 0
$skipped = 0
$errors = 0

foreach ($project in $projects) {
    $projectName = $project.Name
    $hubPath = Join-Path $project.FullName ".claude\_hub"
    $skillsPath = Join-Path $project.FullName ".claude\skills"

    Write-Host "📦 $projectName..." -ForegroundColor Cyan

    if (-not (Test-Path $hubPath)) {
        Write-Host "  ⚠️  Hub não encontrado (não configurado)" -ForegroundColor DarkYellow
        Write-Host "     Execute: .\setup_new_project.ps1 -ProjectPath '$($project.FullName)'" -ForegroundColor DarkGray
        $skipped++
        Write-Host ""
        continue
    }

    try {
        # Git pull no hub
        if ($DryRun) {
            Write-Host "  🔍 [DRY RUN] git pull origin main" -ForegroundColor DarkCyan
        } else {
            Push-Location $hubPath
            $gitOutput = git pull origin main 2>&1
            Pop-Location

            if ($gitOutput -match "Already up to date") {
                Write-Host "  ✅ Já atualizado" -ForegroundColor Green
            } elseif ($gitOutput -match "Updating") {
                Write-Host "  ✅ Atualizado com sucesso" -ForegroundColor Green

                # Re-copiar skills após update
                $hubSkillsPath = Join-Path $hubPath "pbi-claude-skills\skills"
                Copy-Item "$hubSkillsPath\*" $skillsPath -Recurse -Force
                Write-Host "     Skills copiadas" -ForegroundColor DarkGreen
            } else {
                Write-Host "  ℹ️  $gitOutput" -ForegroundColor White
            }

            $updated++
        }
    } catch {
        Write-Host "  ❌ ERRO: $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }

    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "📊 Resumo:" -ForegroundColor Cyan
Write-Host "  ✅ Atualizados: $updated" -ForegroundColor Green
Write-Host "  ⚠️  Ignorados: $skipped" -ForegroundColor Yellow

if ($errors -gt 0) {
    Write-Host "  ❌ Erros: $errors" -ForegroundColor Red
}

Write-Host ""

if ($skipped -gt 0) {
    Write-Host "💡 Dica: Configure projetos ignorados com setup_new_project.ps1" -ForegroundColor DarkCyan
}

if ($DryRun) {
    Write-Host "ℹ️  Modo DRY RUN - nenhuma alteração foi feita" -ForegroundColor DarkYellow
    Write-Host "   Execute sem -DryRun para aplicar atualizações" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "✅ Atualização concluída!" -ForegroundColor Green
