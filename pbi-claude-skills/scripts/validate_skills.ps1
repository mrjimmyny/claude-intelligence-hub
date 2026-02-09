# validate_skills.ps1
# Valida integridade das skills e templates do hub

param(
    [Parameter(Mandatory=$false)]
    [string]$HubPath = ".."
)

Write-Host "Validando skills do hub..." -ForegroundColor Cyan
Write-Host ""

$skillsDir = Join-Path $HubPath "skills"
$templatesDir = Join-Path $HubPath "templates"
$errors = @()
$warnings = @()

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. Validar Skills
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Host "Validando skills (.md)..." -ForegroundColor Yellow

if (-not (Test-Path $skillsDir)) {
    $errors += "Skills directory not found: $skillsDir"
} else {
    $skillFiles = Get-ChildItem $skillsDir -Filter "*.md" | Where-Object { $_.Name -ne "README.md" -and $_.Name -ne "TESTING.md" }

    Write-Host "   Found: $($skillFiles.Count) skills" -ForegroundColor DarkGray

    foreach ($skill in $skillFiles) {
        $skillName = $skill.Name
        $content = Get-Content $skill.FullName -Raw

        # Verificar frontmatter (aceitar \r\n do Windows)
        if ($content -notmatch '(?s)^---\s*[\r\n]+.*?[\r\n]+---') {
            $errors += "$skillName - Frontmatter missing or invalid"
        } else {
            # Verificar campos obrigatórios no frontmatter
            $frontmatterFields = @("skill_name", "description", "match_prompt", "version")

            foreach ($field in $frontmatterFields) {
                if ($content -notmatch "$field\s*:") {
                    $errors += "$skillName - Field '$field' missing in frontmatter"
                }
            }
        }

        # Verificar seção de configuração (pbi-config)
        if ($skillName -match "^pbi-" -and $content -notmatch "pbi_config\.json") {
            $warnings += "$skillName - Does not mention pbi_config.json (may not be adapted)"
        }

        # Verificar se tem hard-coded paths (hr_kpis_board_v2)
        if ($content -match "hr_kpis_board_v2\.SemanticModel") {
            $errors += "$skillName - Contains hard-coded path (hr_kpis_board_v2.SemanticModel)"
        }
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. Validar Templates
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Host "Validating templates..." -ForegroundColor Yellow

$requiredTemplates = @(
    "pbi_config.template.json",
    ".claudecode.template.json",
    "settings.local.template.json",
    "MEMORY.template.md"
)

if (-not (Test-Path $templatesDir)) {
    $errors += "Templates directory not found: $templatesDir"
} else {
    foreach ($template in $requiredTemplates) {
        $templatePath = Join-Path $templatesDir $template

        if (-not (Test-Path $templatePath)) {
            $errors += "Template missing: $template"
        } else {
            # Validar JSON templates
            if ($template -match "\.json$") {
                try {
                    $json = Get-Content $templatePath -Raw | ConvertFrom-Json
                    Write-Host "   OK: $template (valid JSON)" -ForegroundColor DarkGreen
                } catch {
                    $errorMsg = $_.Exception.Message
                    $errors += "$template - Invalid JSON: $errorMsg"
                }
            } else {
                Write-Host "   OK: $template (exists)" -ForegroundColor DarkGreen
            }
        }
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. Validar pbi_config.template.json (estrutura)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Host "Validating pbi_config.template.json structure..." -ForegroundColor Yellow

$configTemplatePath = Join-Path $templatesDir "pbi_config.template.json"
if (Test-Path $configTemplatePath) {
    try {
        $config = Get-Content $configTemplatePath -Raw | ConvertFrom-Json

        $requiredFields = @{
            "project.semantic_model.name" = $config.project.semantic_model.name
            "project.semantic_model.path" = $config.project.semantic_model.path
            "tables.main_dax" = $config.tables.main_dax
            "index.file" = $config.index.file
        }

        foreach ($field in $requiredFields.Keys) {
            $value = $requiredFields[$field]
            if ([string]::IsNullOrEmpty($value)) {
                $errors += "pbi_config.template.json - Field '$field' is empty or missing"
            }
        }

        Write-Host "   OK: Structure valid" -ForegroundColor DarkGreen
    } catch {
        $errorMsg = $_.Exception.Message
        $errors += "pbi_config.template.json - Error validating structure: $errorMsg"
    }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. Resumo
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Write-Host ""
Write-Host "============================================" -ForegroundColor DarkGray
Write-Host ""

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "SUCCESS: Validation passed - No errors found" -ForegroundColor Green
    exit 0
} else {
    if ($errors.Count -gt 0) {
        Write-Host "ERRORS: Validation failed with $($errors.Count) error(s):" -ForegroundColor Red
        foreach ($err in $errors) {
            Write-Host "  - $err" -ForegroundColor DarkRed
        }
        Write-Host ""
    }

    if ($warnings.Count -gt 0) {
        Write-Host "WARNINGS: $($warnings.Count) warning(s):" -ForegroundColor Yellow
        foreach ($warn in $warnings) {
            Write-Host "  - $warn" -ForegroundColor DarkYellow
        }
        Write-Host ""
    }

    if ($errors.Count -gt 0) {
        exit 1
    } else {
        exit 0
    }
}
