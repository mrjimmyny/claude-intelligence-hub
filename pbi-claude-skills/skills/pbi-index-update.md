---
skill_name: pbi-index-update
description: Regenera o índice completo do projeto Power BI (POWER_BI_INDEX.md)
match_prompt: |
  Use this skill when the user wants to:
  - Regenerate the complete Power BI index
  - Update the index after adding/removing tables or measures
  - Rebuild the project structure documentation
  - Refresh table counts and relationships
version: 1.0.0
---

# Power BI Index Update

Regenera automaticamente o arquivo POWER_BI_INDEX.md com informações atualizadas do projeto.

## 🎯 Propósito

Manter o índice do projeto sempre atualizado após modificações em tabelas, medidas ou relacionamentos, garantindo que as skills de consulta funcionem corretamente.

## 📋 Uso

```bash
/pbi-index-update
```

**Sem parâmetros** - Regenera o índice completo.

## 📍 Configuração (AUTO-CRIADA)

**Esta skill requer `pbi_config.json` na raiz do projeto.**

**✅ AUTO-CRIAÇÃO AUTOMÁTICA:**

1. **Verificar se `pbi_config.json` existe na raiz do projeto**
2. **Se NÃO existir:**
   - Detectar semantic model automaticamente (buscar pasta `*.SemanticModel`)
   - Criar `pbi_config.json` do template com valores padrão:
     ```json
     {
       "project": {
         "semantic_model": {
           "name": "[DetectedName].SemanticModel",
           "path": "[DetectedName].SemanticModel/definition"
         }
       },
       "index": {
         "file": "POWER_BI_INDEX.md"
       },
       "tables": {
         "main_dax": "DAX"
       }
     }
     ```
   - Avisar usuário: "✅ `pbi_config.json` criado automaticamente"
3. **Ler configuração do arquivo**
4. **Extrair:**
   - `semantic_model.path` → caminho do definition (ex: `MyProject.SemanticModel/definition`)
   - `index.file` → nome do arquivo de índice (ex: `POWER_BI_INDEX.md`)
5. **Usar paths parametrizados em toda a skill**

**Variáveis disponíveis após leitura:**
- `{defPath}` = `semantic_model.path` (ex: `{defPath}`)
- `{indexFile}` = `index.file` (ex: `POWER_BI_INDEX.md`)

## 🚀 Implementação

### Fluxo de Execução

```
1. Descoberta
   ├─> find: definition/tables -name "*.tmdl" (otimizado, ~50% menos tokens)
   ├─> Ler: definition/model.tmdl
   ├─> Ler: definition/relationships.tmdl
   └─> Ler: definition/database.tmdl (opcional)

2. Análise de Tabelas
   ├─> Para cada arquivo .tmdl:
   │   ├─> Identificar tipo (dimensão, fato, DAX, bridge, aux)
   │   ├─> Extrair colunas chave (isKey)
   │   ├─> Contar medidas (grep "measure ")
   │   └─> Identificar fonte (partition = m ou DAX)

3. Análise de Relacionamentos
   ├─> Parse relationships.tmdl
   ├─> Agrupar por tabela FROM
   ├─> Identificar relacionamentos bidirecionais
   └─> Mapear hierarquias (fato -> dimensões)

4. Geração do Índice
   ├─> Construir estrutura markdown
   ├─> Preencher tabelas por tipo
   ├─> Gerar árvores de relacionamentos
   ├─> Calcular totais e estatísticas
   └─> Adicionar timestamps

5. Salvamento
   ├─> Write: POWER_BI_INDEX.md
   └─> Confirmar sucesso com estatísticas
```

## 📊 Análise de Tabelas

### Identificação de Tipo

#### 1. Dimensões
**Critérios:**
- Sufixo `_dimension` no nome
- OU: Contém coluna com `isKey`
- OU: Listada em `definition/model.tmdl` no grupo `queryGroup Dim`

**Exemplos:**
- `employee_dimension`
- `company_dimension`
- `date_dimension`

#### 2. Fatos
**Critérios:**
- Sufixo `_facts` no nome
- OU: Listada em `definition/model.tmdl` no grupo `queryGroup Fac`
- OU: Tem múltiplos relacionamentos FROM (é origem de relacionamentos)

**Exemplos:**
- `payroll_facts`
- `promotions_facts`
- `ninebox_facts`

#### 3. Tabelas DAX/Medidas
**Critérios:**
- Nome começa com `DAX` ou `_DAX`
- OU: Contém apenas medidas (nenhuma coluna `sourceColumn`)
- OU: Listada em `definition/model.tmdl` no grupo `queryGroup DAX`

**Exemplos:**
- `DAX`
- `DAX_Variance_ABS`
- `_DAX_AUDIT_TEST`

#### 4. Tabelas Bridge/Ponte
**Critérios:**
- Sufixo `_bridge` no nome
- OU: Sufixo `_map` no nome
- OU: Tem relacionamento bidirecional (crossFilteringBehavior: bothDirections)

**Exemplos:**
- `client_area_bridge`
- `client_company_map`
- `client_employee_bridge`

#### 5. Tabelas Auxiliares
**Critérios:**
- Não se encaixa em nenhuma categoria acima
- OU: Nomes especiais: `LastUpdated`, `TooltipMonths`, etc.
- OU: Prefixo `_AUDIT_`

**Exemplos:**
- `LastUpdated`
- `TooltipMonths`
- `total_label_table`
- `_AUDIT_WOMAN_AGO25`

### Extração de Informações

#### Colunas Chave
```bash
# Comando
grep "isKey" {defPath}/tables/employee_dimension.tmdl

# Output esperado
column employee_id
    dataType: int64
    isKey
```

**Parse:**
- Linha anterior contém `column {nome}`
- Linha atual contém `isKey`
- Resultado: `employee_id` é chave

#### Fonte de Dados
```tmdl
# Power Query (M)
partition employee_dimension = m
    source = GoogleBigQuery.Database(...)

# DAX (calculada)
table DAX
    measure tot_employee = ...
```

**Parse:**
- Se `partition {nome} = m` → Fonte: GoogleBigQuery (ou outra)
- Se apenas `measure` → Fonte: DAX (calculada)

#### Contagem de Medidas
```bash
# Comando
grep -c "^\s*measure " {defPath}/tables/DAX.tmdl

# Output
265
```

**Parse:** Número total de medidas na tabela

## 🔗 Análise de Relacionamentos

### Parse de relationships.tmdl

**Formato:**
```tmdl
relationship {uuid}
	fromColumn: payroll_facts.employee_id
	toColumn: employee_dimension.employee_id

relationship {uuid}
	crossFilteringBehavior: bothDirections
	fromColumn: client_area_bridge.area_id
	toColumn: area_dimension.area_id
```

**Extração:**
```
1. Identificar blocos (começam com "relationship")
2. Extrair fromColumn (tabela.coluna)
3. Extrair toColumn (tabela.coluna)
4. Verificar crossFilteringBehavior (se bothDirections)
5. Agrupar por tabela FROM
```

**Estrutura de dados:**
```json
{
  "payroll_facts": [
    {"to": "employee_dimension", "on": "employee_id", "bidirectional": false},
    {"to": "date_dimension", "on": "active_payroll_period", "bidirectional": false},
    {"to": "job_dimension", "on": "job_id", "bidirectional": false},
    {"to": "area_dimension", "on": "area_id", "bidirectional": false},
    {"to": "company_dimension", "on": "company_id", "bidirectional": false}
  ],
  "client_area_bridge": [
    {"to": "area_dimension", "on": "area_id", "bidirectional": true},
    {"to": "client_dimension", "on": "client_id", "bidirectional": true}
  ]
}
```

### Geração de Árvores ASCII

**Input:**
```json
{
  "payroll_facts": [
    {"to": "employee_dimension", "on": "employee_id"},
    {"to": "date_dimension", "on": "active_payroll_period"},
    {"to": "job_dimension", "on": "job_id"},
    {"to": "area_dimension", "on": "area_id"},
    {"to": "company_dimension", "on": "company_id"}
  ]
}
```

**Output:**
```
payroll_facts (5 relacionamentos)
  ├─> employee_dimension (employee_id)
  ├─> date_dimension (active_payroll_period)
  ├─> job_dimension (job_id)
  ├─> area_dimension (area_id)
  └─> company_dimension (company_id)
```

**Caracteres:**
- `├─>` para relacionamentos intermediários
- `└─>` para último relacionamento
- `⟷` para relacionamentos bidirecionais

## 📝 Estrutura do Índice Gerado

### Seções Obrigatórias

```markdown
# 📊 Índice do Projeto Power BI: {nome_projeto}

> **Última atualização:** {timestamp}
> **Total de Tabelas:** {count}
> **Total de Medidas DAX:** {count}
> **Total de Relacionamentos:** {count}

## 🔍 Navegação Rápida
[links para seções]

## 📐 Modelo Semântico
[arquivos principais do modelo]

## 📋 Tabelas

### Dimensões ({count} tabelas)
[tabela markdown com dimensões]

### Fatos ({count} tabelas)
[tabela markdown com fatos]

### Tabelas Ponte/Bridge ({count} tabelas)
[tabela markdown com bridges]

### Tabelas DAX/Medidas ({count} tabelas)
[tabela markdown com tabelas DAX + contagem de medidas]

### Tabelas Auxiliares ({count} tabelas)
[tabela markdown com auxiliares]

## 🔗 Relacionamentos
[árvores ASCII de relacionamentos agrupados por tabela]

## 📊 Medidas DAX
[resumo de medidas por categoria]

## 🚀 Uso com Skills
[exemplos de uso das skills]

## 📁 Estrutura de Arquivos
[árvore de diretórios]

## 🔒 Arquivos Excluídos (Performance)
[lista de arquivos ignorados]

## 📝 Formato TMDL
[exemplos de sintaxe]
```

### Cálculo de Estatísticas

#### Total de Tabelas
```bash
# Comando
ls {defPath}/tables/*.tmdl | wc -l
```

#### Total de Medidas DAX
```bash
# Comando
find {defPath}/tables/ -name "*.tmdl" \
  -exec grep -c "^\s*measure " {} \; | awk '{s+=$1} END {print s}'
```

#### Total de Relacionamentos
```bash
# Comando
grep -c "^relationship " {defPath}/relationships.tmdl
```

#### Timestamp
```bash
# Comando
date +%Y-%m-%d
```

## 🎯 Otimizações de Performance

### Evitar Leituras Desnecessárias

**NÃO ler:**
- `.pbi/cache.abf` (cache binário)
- `.pbi/localSettings.json` (settings locais)
- `definition/bookmarks/*.json` (bookmarks individuais)
- `definition/pages/*/visuals/*.json` (visuais individuais)

**Ler apenas:**
- `definition/model.tmdl` (config geral)
- `definition/relationships.tmdl` (relacionamentos)
- `definition/tables/*.tmdl` (tabelas)

### Uso de find (Otimizado) em vez de Glob

**Preferir (otimizado - 50% menos tokens):**
```bash
find definition/tables -name "*.tmdl" -type f
```

**Alternativa (Glob - funciona mas consome mais):**
```
Glob: definition/tables/*.tmdl
```

**Vantagens do find:**
- ✅ Consumo: ~100 tokens (vs. ~200 do Glob)
- ✅ Mais flexível (filtros, profundidade, tipos)
- ✅ Combina com outros comandos (wc, grep, etc)
- ✅ Performance superior em projetos grandes

### Uso de Grep em vez de Read completo

**Para contagens:**
```
Grep: pattern="^\s*measure " path=tables/DAX.tmdl output_mode=count
```

**Evitar:**
```
Read: tables/DAX.tmdl (arquivo completo)
# Depois contar manualmente
```

## ⚡ Exemplo de Execução

### Comando
```bash
/pbi-index-update
```

### Output Esperado
```markdown
🔄 Atualizando índice do projeto Power BI...

📊 Análise de estrutura:
  ✓ Encontradas 37 tabelas (.tmdl)
  ✓ Identificados 21 relacionamentos
  ✓ Contadas 617 medidas DAX

📋 Categorização:
  ✓ Dimensões: 7 tabelas
  ✓ Fatos: 7 tabelas
  ✓ Bridges: 7 tabelas
  ✓ DAX/Medidas: 13 tabelas
  ✓ Auxiliares: 3 tabelas

🔗 Relacionamentos mapeados:
  ✓ payroll_facts: 5 relacionamentos
  ✓ promotions_facts: 3 relacionamentos
  ✓ ninebox_facts: 3 relacionamentos
  ✓ conversion_facts: 3 relacionamentos
  ✓ compensation_facts: 1 relacionamento
  ✓ talents_facts: 1 relacionamento
  ✓ client_area_bridge: 2 relacionamentos (bidirecional)
  ✓ client_employee_bridge: 2 relacionamentos
  ✓ client_promotions_bridge: 2 relacionamentos

✅ Índice atualizado com sucesso!

**Arquivo:** POWER_BI_INDEX.md
**Tamanho:** ~15KB
**Última atualização:** 2026-02-05

---

⚠️ **Gestão de Contexto:** Atualização de índice consome recursos.

💡 **Recomendação:** Execute `/pbi-context-check` para verificar status da janela de contexto.
```

## 🛡️ Validações

### Pré-Execução

1. **Verificar estrutura do projeto:**
   - `{semantic_model}/` existe?
   - `definition/tables/` existe?
   - `definition/relationships.tmdl` existe?

2. **Verificar permissões:**
   - POWER_BI_INDEX.md pode ser escrito?

### Pós-Execução

1. **Validar índice gerado:**
   - Arquivo não está vazio?
   - Contém todas as seções obrigatórias?
   - Markdown válido?

2. **Comparar com versão anterior:**
   - Total de tabelas mudou?
   - Total de medidas mudou?
   - Notificar usuário de mudanças significativas

## 🔍 Troubleshooting

### Problema: Tabelas não categorizadas corretamente

**Causa:** Lógica de categorização não cobriu todos os casos

**Solução:**
1. Verificar nome da tabela
2. Verificar queryGroup em model.tmdl
3. Ajustar critérios de identificação

### Problema: Contagem de medidas incorreta

**Causa:** Regex de grep não captura todos os formatos

**Solução:**
1. Verificar se todas as medidas começam com `measure `
2. Ajustar regex para incluir tabs/espaços: `^\s*measure `

### Problema: Relacionamentos não aparecendo

**Causa:** Parse de relationships.tmdl falhou

**Solução:**
1. Verificar formato do arquivo
2. Ajustar regex de extração
3. Validar UUIDs estão presentes

## 📊 Comparação com Versão Anterior

Ao regenerar índice, comparar com versão anterior:

```markdown
📈 Mudanças detectadas:

Tabelas:
  ✓ Sem mudanças (37 tabelas)

Medidas DAX:
  + DAX.tmdl: 265 → 267 (+2 medidas)
  ✓ DAX_Variance_ABS: 61 (sem mudanças)
  ✓ DAX_Variance_PCT: 72 (sem mudanças)

Relacionamentos:
  ✓ Sem mudanças (21 relacionamentos)

Total de Medidas: 617 → 619 (+2)
```

## 🧠 Gestão de Contexto

### Impacto no Contexto

Atualizar o índice é uma **operação pesada** que:
- Lê 37+ arquivos .tmdl
- Analisa relacionamentos
- Conta medidas em todas as tabelas
- Gera índice completo (~15KB)

**Consumo estimado:** 3000-5000 tokens

### Monitoramento Automático

**Após atualizar índice, Claude verifica:**
- Quantas vezes o índice foi atualizado na sessão
- Total de arquivos lidos
- Tempo decorrido da sessão

### Avisos Proativos

**Após 1ª atualização:**
```
✅ Índice atualizado.

💡 Operação pesada concluída. Contexto em bom estado.
```

**Após 2ª atualização:**
```
✅ Índice atualizado.

⚠️ **Gestão de Contexto:** 2ª atualização de índice nesta sessão.

💡 Recomendação: Execute `/pbi-context-check` para avaliar se compactação é necessária.
```

**Após 3ª+ atualização:**
```
✅ Índice atualizado.

🔴 **Alerta de Contexto:** 3+ atualizações de índice - sessão muito longa.

⚠️ Recomendo fortemente executar `/compact` após concluir tarefas atuais.

📋 Execute `/pbi-context-check` para detalhes.
```

### Regra Crítica

**NUNCA sugerir /compact DURANTE atualização:**
- ❌ Enquanto estiver lendo arquivos .tmdl
- ❌ Durante análise de relacionamentos
- ❌ Durante escrita do índice

**SEMPRE sugerir APÓS concluir:**
- ✅ Índice completamente gerado
- ✅ Arquivo POWER_BI_INDEX.md salvo
- ✅ Validação concluída
- ✅ Momento "limpo" entre tarefas

---

## 🎓 Boas Práticas

### Quando Executar

**Execute após:**
- Adicionar nova tabela ao modelo
- Adicionar múltiplas medidas DAX
- Modificar relacionamentos
- Adicionar/remover colunas chave
- Mudanças estruturais significativas

**Não é necessário após:**
- Adicionar apenas 1 medida (pbi-add-measure já atualiza)
- Modificar fórmula de medida existente
- Mudanças em visuais/relatórios

### Frequência

- **Manual:** Apenas quando solicitado pelo usuário
- **Automático:** Não - evitar execuções desnecessárias
- **Recomendado:** 1x por sessão de trabalho
- **Alerta:** 3+ vezes indica sessão muito longa - considerar `/compact`

### Backup

Antes de atualizar, considerar:
```bash
# Backup manual (opcional)
cp POWER_BI_INDEX.md POWER_BI_INDEX.md.bak
```

Git já fornece controle de versão.

## 📝 Notas de Implementação

1. **Usar Write tool** para regenerar índice completo
2. **Não usar Edit** - mais simples regenerar do zero
3. **Manter formatação** consistente (tabs, espaços)
4. **Preservar seções** fixas (Uso com Skills, Estrutura de Arquivos)
5. **Atualizar timestamp** sempre
6. **Validar markdown** gerado (syntax highlighting)

## 🔄 Versionamento do Índice

**Formato do timestamp:**
```
> **Última atualização:** 2026-02-05
```

**Opcional - Histórico de mudanças:**
```markdown
## 📜 Histórico de Mudanças

### 2026-02-05
- Adicionadas 2 medidas em DAX.tmdl
- Total de medidas: 617 → 619

### 2026-02-04
- Criação inicial do índice
- 37 tabelas, 617 medidas, 21 relacionamentos
```

**Implementação:** Opcional, apenas se usuário solicitar.

---

**Versão:** 1.1.0 (+ Gestão de Contexto)
**Compatível com:** Claude Code v2.0+, Power BI PBIP Format
**Autor:** Sistema de Skills PBIP
**Tempo estimado de execução:** 10-15 segundos
**Última atualização:** 2026-02-07
