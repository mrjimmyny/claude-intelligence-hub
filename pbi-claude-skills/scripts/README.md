# Power BI Skills - Scripts de Automação

Scripts PowerShell para facilitar setup e manutenção de projetos usando o hub de skills.

## 📜 Scripts Disponíveis

### 1. setup_new_project.ps1

**Propósito:** Configurar um novo projeto Power BI com skills do hub.

**Uso:**
```powershell
.\setup_new_project.ps1 -ProjectPath "C:\path\to\your\pbi\project"
```

**O que faz:**
1. Cria estrutura `.claude/` no projeto
2. Clona hub do GitHub (ou atualiza se já existir)
3. **Copia skills** (cópia direta, não symlink - 100% confiável)
4. Copia templates (.claudecode, settings.local, pbi_config)
5. Detecta semantic model automaticamente
6. Atualiza pbi_config.json com valores detectados
7. Cria POWER_BI_INDEX.md vazio

**Parâmetros:**
- `-ProjectPath` (obrigatório): Caminho completo do projeto
- `-HubUrl` (opcional): URL do hub (padrão: https://github.com/mrjimmyny/claude-intelligence-hub.git)

**Exemplo:**
```powershell
cd C:\temp\claude-intelligence-hub\pbi-claude-skills\scripts
.\setup_new_project.ps1 -ProjectPath "C:\Users\jimmy\Downloads\_pbi_projs\_project_pbip_sales_dashboard"
```

---

### 2. update_all_projects.ps1

**Propósito:** Atualizar skills em TODOS os projetos configurados.

**Uso:**
```powershell
.\update_all_projects.ps1
```

**O que faz:**
1. Busca todos os projetos em `ProjectsRoot` (padrão: `C:\Users\[user]\Downloads\_pbi_projs`)
2. Para cada projeto com hub configurado:
   - Executa `git pull` no `.claude\_hub`
   - Re-copia skills atualizadas para `.claude\skills`
3. Exibe resumo de projetos atualizados/ignorados/com erro

**Parâmetros:**
- `-ProjectsRoot` (opcional): Diretório raiz dos projetos (padrão: `C:\Users\$env:USERNAME\Downloads\_pbi_projs`)
- `-DryRun` (opcional): Modo teste - mostra o que seria feito sem executar

**Exemplo:**
```powershell
# Atualizar todos (padrão)
.\update_all_projects.ps1

# Atualizar todos em diretório customizado
.\update_all_projects.ps1 -ProjectsRoot "D:\my_pbi_projects"

# Modo teste (dry run)
.\update_all_projects.ps1 -DryRun
```

**Padrão de busca:** `_project_pbip_*` (pode ser customizado editando o script)

---

### 3. validate_skills.ps1

**Propósito:** Validar integridade das skills e templates do hub.

**Uso:**
```powershell
.\validate_skills.ps1
```

**O que valida:**

**Skills (.md):**
- ✅ Frontmatter presente e bem formatado
- ✅ Campos obrigatórios: `skill_name`, `description`, `match_prompt`, `version`
- ✅ Não contém hard-coded paths (ex: `hr_kpis_board_v2.SemanticModel`)
- ⚠️ Menciona `pbi_config.json` (para skills parametrizadas)

**Templates:**
- ✅ Arquivos obrigatórios existem
- ✅ JSON válido (para templates .json)
- ✅ Estrutura de pbi_config.template.json correta

**Parâmetros:**
- `-HubPath` (opcional): Caminho do hub (padrão: `..` - assume que está em `scripts/`)

**Exemplo:**
```powershell
# Validar do diretório scripts/
cd C:\temp\claude-intelligence-hub\pbi-claude-skills\scripts
.\validate_skills.ps1

# Validar de outro local
.\validate_skills.ps1 -HubPath "C:\temp\claude-intelligence-hub\pbi-claude-skills"
```

**Exit codes:**
- `0` = Sucesso (nenhum erro)
- `1` = Falha (erros encontrados)

---

## 🔧 Uso em CI/CD

### GitHub Actions (validação automática)

```yaml
name: Validate Skills

on: [push, pull_request]

jobs:
  validate:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate Skills
        run: |
          cd pbi-claude-skills/scripts
          .\validate_skills.ps1
        shell: powershell
```

---

## 📋 Workflow Completo

### Setup de Novo Projeto

```powershell
# 1. Clone o hub (se ainda não tiver)
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git
cd claude-intelligence-hub/pbi-claude-skills/scripts

# 2. Configure o projeto
.\setup_new_project.ps1 -ProjectPath "C:\path\to\your\project"

# 3. Edite pbi_config.json (se necessário)
code "C:\path\to\your\project\pbi_config.json"

# 4. Gere o índice
cd "C:\path\to\your\project"
claude
/pbi-index-update

# 5. Teste
/pbi-query-structure tabelas
```

### Atualização Regular

```powershell
# A cada semana (ou quando houver updates no hub)
cd claude-intelligence-hub/pbi-claude-skills/scripts
.\update_all_projects.ps1

# Verificar log de atualizações
# Se algum projeto falhar, investigar manualmente
```

### Validação Antes de Commit (no hub)

```powershell
# Antes de fazer commit de novas skills ou edições
cd claude-intelligence-hub/pbi-claude-skills/scripts
.\validate_skills.ps1

# Se passar (exit code 0), commit é seguro
git add ..
git commit -m "feat: Add new skill X"
```

---

## 🚨 Troubleshooting

### Problema: "Git não reconhecido"

**Solução:**
```powershell
# Instalar Git
winget install Git.Git

# Ou baixar de: https://git-scm.com/download/win
```

### Problema: "Execution policy restringe scripts"

**Solução:**
```powershell
# Permitir execução de scripts (admin)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ou executar com bypass
powershell -ExecutionPolicy Bypass -File .\setup_new_project.ps1 -ProjectPath "..."
```

### Problema: "Symlinks não funcionam"

**Solução:** Scripts já usam **cópia direta** (não symlinks). Se algo falhar:
```powershell
# Verificar se .claude\skills existe
Test-Path "C:\path\to\project\.claude\skills"

# Listar conteúdo
Get-ChildItem "C:\path\to\project\.claude\skills"
```

### Problema: "Multiple semantic models encontrados"

**Solução:**
```powershell
# Script não consegue detectar automaticamente
# Edite manualmente pbi_config.json
code "C:\path\to\project\pbi_config.json"

# Defina:
# - project.semantic_model.name = "YourProject.SemanticModel"
# - project.semantic_model.path = "YourProject.SemanticModel/definition"
```

---

## 💡 Dicas

**Cópia vs Symlink:**
- Scripts usam **cópia direta** por padrão (mais confiável)
- Symlinks no Windows requerem permissões de admin
- Cópia sempre funciona, zero problemas de TI
- Update via `update_all_projects.ps1` é automático

**Performance:**
- `setup_new_project.ps1` executa em ~30 segundos
- `update_all_projects.ps1` executa em ~5 segundos por projeto
- `validate_skills.ps1` executa em ~2 segundos

**Automação:**
- Adicione `update_all_projects.ps1` ao Task Scheduler (semanal)
- Use `validate_skills.ps1` em pre-commit hooks (git)
- Combine com GitHub Actions para CI/CD

---

**Documentação completa:** https://github.com/mrjimmyny/claude-intelligence-hub/tree/main/pbi-claude-skills
