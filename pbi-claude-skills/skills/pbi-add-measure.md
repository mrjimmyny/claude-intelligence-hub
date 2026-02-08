---
skill_name: pbi-add-measure
description: Adiciona uma nova medida DAX à tabela DAX principal do modelo Power BI
match_prompt: |
  Use this skill when the user wants to:
  - Add a new DAX measure to the model
  - Create a calculated measure
  - Insert a measure into the DAX table
version: 1.0.0
---

# Power BI Add Measure

Adiciona novas medidas DAX à tabela DAX principal de forma segura e estruturada.

## 🎯 Propósito

Facilitar a adição de medidas DAX ao modelo Power BI sem precisar editar manualmente o arquivo .tmdl, garantindo sintaxe correta e formatação adequada.

## 📋 Uso

```bash
/pbi-add-measure <nome> <formula> [formatString]
```

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| nome | string | Sim | Nome da medida (sem espaços, snake_case recomendado) |
| formula | string | Sim | Fórmula DAX (pode ser multilinha) |
| formatString | string | Não | Formato de exibição (padrão: `#,0`) |

## 🔧 Exemplos

### Exemplo 1: Medida Simples
```bash
/pbi-add-measure tot_revenue "SUM(payroll_facts[salary])"
```

**Resultado:**
```tmdl
measure tot_revenue = ```
    SUM(payroll_facts[salary])
    ```
    formatString: #,0
    lineageTag: [auto-generated]
```

### Exemplo 2: Medida com Formato Customizado
```bash
/pbi-add-measure avg_tenure_years "AVERAGE(employee_dimension[tenure_years])" "0.00"
```

**Resultado:**
```tmdl
measure avg_tenure_years = ```
    AVERAGE(employee_dimension[tenure_years])
    ```
    formatString: 0.00
    lineageTag: [auto-generated]
```

### Exemplo 3: Medida Complexa (Multilinha)
```bash
/pbi-add-measure employee_retention_rate "VAR total = [tot_employee_active]
VAR terminated = [tot_employee_inactive]
RETURN DIVIDE(total - terminated, total, 0)" "0.0%"
```

**Resultado:**
```tmdl
measure employee_retention_rate = ```
    VAR total = [tot_employee_active]
    VAR terminated = [tot_employee_inactive]
    RETURN DIVIDE(total - terminated, total, 0)
    ```
    formatString: 0.0%
    lineageTag: [auto-generated]
```

## 🚀 Implementação

### Fluxo de Execução

```
1. Validação de Parâmetros
   ├─> Verificar se nome foi fornecido
   ├─> Verificar se formula foi fornecida
   ├─> Validar nome (sem espaços, sem caracteres especiais)
   └─> Definir formatString padrão se não fornecido

2. Preparação
   ├─> Ler arquivo DAX.tmdl
   ├─> Verificar se medida já existe (evitar duplicatas)
   └─> Gerar lineageTag único (UUID v4)

3. Construção da Medida
   ├─> Formatar fórmula (indentação, tabs)
   ├─> Construir bloco completo da medida
   └─> Adicionar ao final do arquivo (antes da última linha)

4. Atualização
   ├─> Editar arquivo DAX.tmdl
   ├─> Salvar mudanças
   └─> Confirmar sucesso

5. (Opcional) Atualizar Índice
   └─> Incrementar contador de medidas no POWER_BI_INDEX.md
```

### Validações

#### 1. Nome da Medida

**Regras:**
- Não pode conter espaços
- Deve começar com letra ou underscore
- Pode conter letras, números, underscores
- Recomendado: snake_case (ex: `tot_employee_active`)

**Validação:**
```regex
^[a-zA-Z_][a-zA-Z0-9_]*$
```

**Exemplos válidos:**
- `tot_revenue`
- `employee_active_cy`
- `_test_measure`
- `KPI_Target_2024`

**Exemplos inválidos:**
- `total revenue` (espaço)
- `2024_revenue` (começa com número)
- `revenue-total` (hífen)

#### 2. Fórmula DAX

**Validações básicas:**
- Não pode ser vazia
- Caracteres especiais permitidos: `[]`, `()`, `{}`, `=`, `+`, `-`, `*`, `/`, etc.
- Suporta multilinha
- Suporta comentários (`//` e `/* */`)

**Limpeza automática:**
- Remove espaços em branco excessivos no início/fim
- Preserva indentação interna
- Converte para formato de template string (triple backticks)

#### 3. Format String

**Valores comuns:**
- `#,0` - Inteiro com separador de milhares (padrão)
- `#,0.00` - Decimal com 2 casas
- `0.0%` - Percentual com 1 casa decimal
- `0.00%` - Percentual com 2 casas decimais
- `$#,0.00` - Moeda com 2 casas decimais
- `"R$ "#,0.00` - Real brasileiro

**Padrão:** Se não fornecido, usa `#,0`

### Geração de lineageTag

**Formato:** UUID v4 (exemplo: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)

**Comando bash:**
```bash
uuidgen | tr '[:upper:]' '[:lower:]'
```

**Fallback:** Se uuidgen não disponível, usar timestamp:
```bash
echo "$(date +%s)-$(shuf -i 1000-9999 -n 1)"
```

## 📝 Template da Medida

```tmdl
	measure {nome} = ```
		{formula_indentada}
		```
		formatString: {formatString}
		lineageTag: {uuid}

```

**Notas de formatação:**
- Tab antes de `measure` (para manter consistência com arquivo)
- Fórmula indentada com 2 tabs
- Linha em branco após cada medida
- Triple backticks para fórmula multilinha

## 📍 Configuração (AUTO-CRIADA)

**Esta skill requer `pbi_config.json` na raiz do projeto.**

**✅ AUTO-CRIAÇÃO AUTOMÁTICA:**

1. **Verificar se `pbi_config.json` existe na raiz do projeto**
2. **Se NÃO existir:**
   - Detectar semantic model automaticamente (buscar pasta `*.SemanticModel`)
   - Criar `pbi_config.json` do template
   - Popular com valores detectados
   - Avisar usuário: "✅ `pbi_config.json` criado automaticamente"
3. **Ler configuração do arquivo**
4. **Extrair:**
   - `semantic_model.path` → caminho do definition
   - `tables.main_dax` → nome da tabela DAX principal
5. **Construir path final:** `{semantic_model.path}/tables/{main_dax}.tmdl`

**Exemplo de detecção automática:**

```powershell
# Buscar semantic model
$semanticModels = Get-ChildItem -Directory -Filter "*.SemanticModel"

# Se encontrou exatamente 1
if ($semanticModels.Count -eq 1) {
    $modelName = $semanticModels[0].Name
    # Criar config com:
    # - semantic_model.name = $modelName
    # - semantic_model.path = "$modelName/definition"
    # - tables.main_dax = "DAX" (padrão)
}
```

## 🔍 Localização da Inserção

**Arquivo alvo:** `{config.semantic_model.path}/tables/{config.tables.main_dax}.tmdl`

**Estratégia de inserção:**

1. **Final do arquivo (recomendado):**
   - Adicionar antes da última linha vazia
   - Preserva ordem cronológica de adição

2. **Alfabético (alternativa):**
   - Inserir em ordem alfabética
   - Facilita busca manual

**Implementação padrão:** Final do arquivo

## ⚡ Exemplo Completo

### Comando
```bash
/pbi-add-measure employee_growth_rate "VAR current = [employee_active_cy]
VAR previous = [employee_active_py]
RETURN DIVIDE(current - previous, previous, 0)" "0.0%"
```

### Arquivo DAX.tmdl (antes)
```tmdl
table DAX
	lineageTag: b8ced3b0-f8b0-433c-b0b1-8a2212a9fd6b

	measure tot_employee_base_raw = ```
		COUNTROWS( payroll_facts )
		```
		formatString: #,0
		lineageTag: ac82235d-8284-4872-b5f3-8cc71ca33daa

	measure tot_employee_active = ```
		CALCULATE ( [tot_employee_base], payroll_facts[termination_period] = BLANK () )
		```
		formatString: #,0
		lineageTag: f71b4c2e-9e97-4da2-aa16-ae8389d08180

	annotation PBI_Id = ...
```

### Arquivo DAX.tmdl (depois)
```tmdl
table DAX
	lineageTag: b8ced3b0-f8b0-433c-b0b1-8a2212a9fd6b

	measure tot_employee_base_raw = ```
		COUNTROWS( payroll_facts )
		```
		formatString: #,0
		lineageTag: ac82235d-8284-4872-b5f3-8cc71ca33daa

	measure tot_employee_active = ```
		CALCULATE ( [tot_employee_base], payroll_facts[termination_period] = BLANK () )
		```
		formatString: #,0
		lineageTag: f71b4c2e-9e97-4da2-aa16-ae8389d08180

	measure employee_growth_rate = ```
		VAR current = [employee_active_cy]
		VAR previous = [employee_active_py]
		RETURN DIVIDE(current - previous, previous, 0)
		```
		formatString: 0.0%
		lineageTag: 3fa7b8c9-1d2e-4f5a-9b6c-7d8e9f0a1b2c

	annotation PBI_Id = ...
```

## 🛡️ Proteções e Segurança

### Verificação de Duplicatas

```
1. Ler arquivo DAX.tmdl
2. Grep para "measure {nome} ="
3. Se encontrado:
   a. Avisar usuário
   b. Perguntar se deseja substituir ou usar nome diferente
   c. Aguardar confirmação
4. Se não encontrado:
   a. Prosseguir com inserção
```

### Backup (Opcional)

**Não implementado por padrão** - Git já funciona como backup.

Usuário pode criar backup manual antes:
```bash
cp hr_kpis_board_v2.SemanticModel/definition/tables/DAX.tmdl \
   hr_kpis_board_v2.SemanticModel/definition/tables/DAX.tmdl.bak
```

### Validação Pós-Inserção

```
1. Ler arquivo novamente
2. Verificar que nova medida foi adicionada
3. Confirmar sintaxe (parênteses balanceados, backticks fechados)
4. Reportar sucesso ou erro
```

## 📊 Atualização do Índice

Após adicionar medida, atualizar POWER_BI_INDEX.md:

```
1. Ler POWER_BI_INDEX.md
2. Localizar linha: "| DAX | 265 | **Medidas DAX principais** - Base de cálculos |"
3. Incrementar contador: 265 → 266
4. Atualizar "Total de Medidas DAX: 617" → 618
5. Salvar mudanças
```

**Automático:** Sim, sempre que medida for adicionada com sucesso.

## 🎯 Mensagens de Retorno

### Sucesso
```markdown
✅ Medida adicionada com sucesso!

**Nome:** employee_growth_rate
**Localização:** hr_kpis_board_v2.SemanticModel/definition/tables/DAX.tmdl
**Formato:** 0.0%
**lineageTag:** 3fa7b8c9-1d2e-4f5a-9b6c-7d8e9f0a1b2c

Total de medidas em DAX.tmdl: 266
```

### Sucesso + Alerta de Contexto
```markdown
✅ Medida adicionada com sucesso!

**Nome:** employee_growth_rate
**Total de medidas em DAX.tmdl:** 266

⚠️ **Gestão de Contexto:** Esta é a 8ª medida adicionada nesta sessão.

💡 **Sugestão:** Execute `/pbi-context-check` para verificar se compactação é recomendada.
```

### Erro - Nome Inválido
```markdown
❌ Erro: Nome de medida inválido

**Nome fornecido:** "total revenue"
**Problema:** Contém espaços

Use snake_case (ex: `total_revenue`) ou PascalCase (ex: `TotalRevenue`)
```

### Aviso - Duplicata
```markdown
⚠️ Aviso: Medida já existe

**Nome:** tot_employee_active
**Localização:** hr_kpis_board_v2.SemanticModel/definition/tables/DAX.tmdl (linha 14)

Deseja:
1. Substituir medida existente
2. Usar nome diferente
3. Cancelar
```

## 🔧 Troubleshooting

### Problema: Arquivo não encontrado
**Causa:** Caminho incorreto ou estrutura de projeto diferente
**Solução:** Verificar se `hr_kpis_board_v2.SemanticModel/definition/tables/DAX.tmdl` existe

### Problema: Permissão negada
**Causa:** Arquivo readonly ou sem permissões
**Solução:** Verificar permissões do arquivo, executar com privilégios adequados

### Problema: Sintaxe DAX inválida
**Causa:** Fórmula DAX mal formatada
**Solução:** Skill não valida sintaxe DAX completa - apenas formata. Usuário deve garantir que fórmula está correta.

## 📝 Notas de Implementação

1. **Usar Edit tool**, não Write (arquivo já existe)
2. **Preservar encoding** do arquivo (UTF-8 sem BOM)
3. **Manter tabs**, não converter para espaços
4. **Não modificar** outras medidas ou anotações
5. **Inserir apenas no final**, antes de annotations

## 🧠 Gestão de Contexto

### Monitoramento Automático

Claude monitora quantas medidas foram adicionadas na sessão atual:

- **1-7 medidas:** ✅ Contexto saudável
- **8-14 medidas:** 🟡 Sugestão de verificação (`/pbi-context-check`)
- **15+ medidas:** 🔴 Recomendação forte de compactação (`/compact`)

### Avisos Proativos

**Após 8ª medida:**
```
⚠️ **Gestão de Contexto:** 8 medidas adicionadas nesta sessão.

💡 Sugestão: Execute `/pbi-context-check` para verificar se compactação é recomendada.
```

**Após 15ª medida:**
```
🔴 **Alerta de Contexto:** 15 medidas adicionadas - sessão longa.

⚠️ Recomendo fortemente executar `/compact` após concluir esta tarefa.

📋 Execute `/pbi-context-check` para detalhes.
```

### Regra Crítica

**NUNCA sugerir /compact DURANTE operações:**
- ❌ Enquanto estiver adicionando medidas
- ❌ Durante escrita de arquivo .tmdl
- ❌ Durante atualização de índice

**SEMPRE sugerir APÓS concluir:**
- ✅ Todas as medidas adicionadas
- ✅ Arquivo salvo com sucesso
- ✅ Índice atualizado (se aplicável)
- ✅ Momento "limpo" entre tarefas

---

## 🎓 Boas Práticas

### Nomenclatura
- Use snake_case: `tot_employee_active`
- Prefixos comuns: `tot_`, `avg_`, `pct_`, `count_`
- Sufixos comuns: `_cy` (current year), `_py` (previous year), `_yoy` (year over year)

### Formatação
- Sempre forneça formatString apropriado
- Use `#,0` para contadores
- Use `0.0%` para percentuais
- Use `#,0.00` para valores monetários

### Documentação
- Adicione comentários DAX na fórmula (`//` ou `/* */`)
- Explique lógica complexa
- Referencie outras medidas quando aplicável

---

**Versão:** 1.1.0 (+ Gestão de Contexto)
**Compatível com:** Claude Code v2.0+, Power BI PBIP Format
**Autor:** Sistema de Skills PBIP
**Última atualização:** 2026-02-07
