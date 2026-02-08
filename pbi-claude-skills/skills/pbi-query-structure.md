---
skill_name: pbi-query-structure
description: Consulta rápida da estrutura do projeto Power BI sem ler arquivos desnecessários
match_prompt: |
  Use this skill when the user wants to:
  - List tables by type (dimension, fact, DAX, bridge)
  - Search for DAX measures by name or keyword
  - View relationships of a specific table
  - Show column structure of a table
  - Quickly understand the project structure
version: 1.0.0
---

# Power BI Query Structure

Consulta otimizada da estrutura do projeto Power BI usando o índice POWER_BI_INDEX.md.

## 🎯 Propósito

Permitir consultas rápidas à estrutura do projeto sem consumir tokens desnecessários lendo arquivos .tmdl completos.

## 📋 Uso

```bash
/pbi-query-structure tabelas [tipo]
/pbi-query-structure medidas [keyword]
/pbi-query-structure relacionamentos [tabela]
/pbi-query-structure colunas [tabela]
```

## 📍 Configuração (AUTO-CRIADA)

**Esta skill requer `pbi_config.json` na raiz do projeto.**

**✅ AUTO-CRIAÇÃO AUTOMÁTICA:**

1. **Verificar se `pbi_config.json` existe**
2. **Se NÃO existir:** Criar automaticamente detectando semantic model
3. **Ler configuração:** Extrair `index.file` (padrão: `POWER_BI_INDEX.md`)
4. **Usar índice parametrizado:** `{config.index.file}`

**Nota:** Esta skill consome ~350 tokens (92% economia vs. ler .tmdl diretamente)

## 🔧 Comandos

### 1. Listar Tabelas

**Sintaxe:** `tabelas [tipo]`

**Tipos válidos:**
- `dimensao` ou `dimension` - Lista todas as dimensões
- `fato` ou `fact` - Lista todas as tabelas fato
- `dax` ou `medidas` - Lista tabelas de medidas DAX
- `bridge` ou `ponte` - Lista tabelas ponte/bridge
- `aux` ou `auxiliar` - Lista tabelas auxiliares
- (sem tipo) - Lista TODAS as tabelas

**Exemplos:**
```bash
/pbi-query-structure tabelas dimensao
/pbi-query-structure tabelas fato
/pbi-query-structure tabelas dax
/pbi-query-structure tabelas
```

### 2. Buscar Medidas DAX

**Sintaxe:** `medidas [keyword]`

**Exemplos:**
```bash
/pbi-query-structure medidas employee
/pbi-query-structure medidas variance
/pbi-query-structure medidas tenure
/pbi-query-structure medidas tot_
```

**Comportamento:**
- Se keyword fornecida: busca medidas que contenham a keyword
- Se sem keyword: mostra resumo de todas as tabelas de medidas

### 3. Ver Relacionamentos

**Sintaxe:** `relacionamentos [tabela]`

**Exemplos:**
```bash
/pbi-query-structure relacionamentos payroll_facts
/pbi-query-structure relacionamentos employee_dimension
/pbi-query-structure relacionamentos
```

**Comportamento:**
- Se tabela fornecida: mostra relacionamentos específicos
- Se sem tabela: mostra resumo de todos os relacionamentos

### 4. Ver Colunas de Tabela

**Sintaxe:** `colunas [tabela]`

**Exemplos:**
```bash
/pbi-query-structure colunas payroll_facts
/pbi-query-structure colunas employee_dimension
```

**Comportamento:**
- Lê o arquivo .tmdl específico da tabela
- Mostra todas as colunas com tipos de dados
- Identifica colunas chave (isKey)

## 🚀 Implementação

### Estratégia de Otimização

1. **Primeira tentativa:** Ler apenas POWER_BI_INDEX.md
2. **Se necessário:** Usar Grep para buscar no índice
3. **Apenas se detalhes forem necessários:** Ler arquivo .tmdl específico

### Respeita .claudecode.json

**Nunca ler:**
- `**/*.pbix` (binários)
- `.pbi/cache.abf` (cache)
- `.pbi/localSettings.json` (settings locais)
- Bookmarks/visuais individuais (exceto se explicitamente solicitado)

**Focar em:**
- `POWER_BI_INDEX.md` (primeira escolha)
- `definition/tables/*.tmdl` (quando necessário)
- `definition/relationships.tmdl` (quando necessário)

## 📊 Fluxo de Execução

### Comando: tabelas [tipo]

```
1. Ler POWER_BI_INDEX.md
2. Identificar seção correspondente:
   - "Dimensões" se tipo = dimensao
   - "Fatos" se tipo = fato
   - "Tabelas DAX/Medidas" se tipo = dax
   - "Tabelas Ponte/Bridge" se tipo = bridge
   - "Tabelas Auxiliares" se tipo = aux
3. Extrair e formatar tabela markdown
4. Retornar resultado
```

### Comando: medidas [keyword]

```
1. Se keyword fornecida:
   a. Identificar tabela(s) DAX mais relevante(s) via POWER_BI_INDEX.md
   b. Ler arquivo .tmdl específico
   c. Grep para "measure.*keyword"
   d. Retornar lista de medidas encontradas

2. Se sem keyword:
   a. Ler POWER_BI_INDEX.md
   b. Mostrar seção "Tabelas DAX/Medidas" com contadores
   c. Retornar resumo
```

### Comando: relacionamentos [tabela]

```
1. Se tabela fornecida:
   a. Ler POWER_BI_INDEX.md
   b. Buscar seção "Relacionamentos" -> tabela específica
   c. Retornar árvore de relacionamentos

2. Se sem tabela:
   a. Ler POWER_BI_INDEX.md
   b. Mostrar toda seção "Relacionamentos"
```

### Comando: colunas [tabela]

```
1. Validar que tabela foi fornecida (obrigatório)
2. Construir caminho: hr_kpis_board_v2.SemanticModel/definition/tables/{tabela}.tmdl
3. Ler arquivo .tmdl
4. Extrair todas as linhas começando com "column "
5. Para cada coluna:
   - Nome
   - dataType
   - isKey (se presente)
   - sourceColumn
6. Formatar e retornar tabela
```

## ⚡ Exemplo de Saída

### tabelas dimensao
```markdown
## Dimensões (7 tabelas)

| Nome | Colunas Chave | Fonte | Caminho |
|------|---------------|-------|---------|
| employee_dimension | employee_id | GoogleBigQuery | tables/employee_dimension.tmdl |
| company_dimension | company_id | GoogleBigQuery | tables/company_dimension.tmdl |
| area_dimension | area_id | GoogleBigQuery | tables/area_dimension.tmdl |
| job_dimension | job_id | GoogleBigQuery | tables/job_dimension.tmdl |
| date_dimension | Date | GoogleBigQuery | tables/date_dimension.tmdl |
| client_dimension | client_id | GoogleBigQuery | tables/client_dimension.tmdl |
| target_disabled_dimension | - | DAX | tables/target_disabled_dimension.tmdl |
```

### medidas employee
```markdown
## Medidas DAX contendo "employee"

### DAX.tmdl (15 medidas encontradas)
- tot_employee_base_raw
- tot_employee_active
- tot_employee_inactive
- employee_active_cy
- employee_inactive_cy
- employee_active_py
- employee_inactive_py
- employee_turnover_rate
...
```

### relacionamentos payroll_facts
```markdown
## Relacionamentos de payroll_facts

```
payroll_facts (5 relacionamentos)
  ├─> employee_dimension (employee_id)
  ├─> date_dimension (active_payroll_period)
  ├─> job_dimension (job_id)
  ├─> area_dimension (area_id)
  └─> company_dimension (company_id)
```
```

### colunas payroll_facts
```markdown
## Colunas de payroll_facts

| Coluna | Tipo | Chave | Source Column |
|--------|------|-------|---------------|
| employee_id | int64 | - | employee_id |
| company_id | int64 | - | company_id |
| area_id | int64 | - | area_id |
| admission_date | dateTime | - | admission_date |
| admission_period | dateTime | - | admission_period |
...
```

## 🎯 Benefícios

### Economia de Tokens

**Sem skill (abordagem tradicional):**
- Ler vários arquivos .tmdl: ~3000-5000 tokens
- Tentar encontrar informação: ~500 tokens adicionais
- **Total: ~3500-5500 tokens**

**Com skill (otimizado):**
- Ler POWER_BI_INDEX.md: ~200-400 tokens
- Grep específico (se necessário): ~100 tokens
- **Total: ~300-500 tokens**

**Economia: ~85-90% de tokens!**

## 🔍 Validações

1. **Comando inválido:** Mostrar mensagem de ajuda
2. **Tabela não encontrada:** Sugerir tabelas similares
3. **Keyword sem resultados:** Sugerir keywords relacionadas
4. **Arquivo .tmdl não encontrado:** Reportar erro com path esperado

## 📝 Notas de Implementação

- Usar Grep com `-i` (case insensitive) para keywords
- Formatar saídas em markdown para legibilidade
- Sempre incluir path relativo para facilitar navegação
- Para colunas, limitar a 50 primeiras (avisar se houver mais)
- Caching do POWER_BI_INDEX.md é automático (15 min)

---

**Versão:** 1.0.0
**Compatível com:** Claude Code v2.0+
**Autor:** Sistema de Skills PBIP
