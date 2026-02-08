# 🚀 Power BI Skills para Claude Code

Sistema otimizado de Skills para trabalhar eficientemente com projetos Power BI no formato PBIP (Power BI Project).

## 📋 Skills Disponíveis

### 1. pbi-context-check ⭐ **NOVO**
**Verifica janela de contexto e sugere compactação**

```bash
# Verificar status do contexto
/pbi-context-check

# Retorna:
# - Resumo da sessão (interações, arquivos lidos)
# - Recomendação de compactação (sim/não)
# - Sugestões de próximos passos
```

**Benefícios:**
- Previne perda de contexto
- Sugere `/compact` em momentos seguros
- Monitora uso de memória proativamente
- Evita compactação durante operações críticas

**Quando usar:**
- Após 20+ interações
- Antes de tarefas grandes
- Se Claude "esquecer" instruções
- Após completar tarefa complexa

---

### 2. pbi-query-structure
**Consulta rápida da estrutura do projeto**

```bash
# Listar tabelas por tipo
/pbi-query-structure tabelas dimensao
/pbi-query-structure tabelas fato
/pbi-query-structure tabelas dax

# Buscar medidas DAX
/pbi-query-structure medidas employee
/pbi-query-structure medidas variance

# Ver relacionamentos
/pbi-query-structure relacionamentos payroll_facts

# Ver colunas de tabela
/pbi-query-structure colunas employee_dimension
```

**Benefícios:**
- Economia de 85-90% de tokens
- Respostas instantâneas
- Não lê arquivos desnecessários

---

### 3. pbi-discover
**Discovery ultra-rápido da estrutura completa**

```bash
# Discovery completo
/pbi-discover full

# Apenas tabelas
/pbi-discover tables

# Apenas arquivos do modelo
/pbi-discover model

# Apenas relatório
/pbi-discover report
```

**Benefícios:**
- Economia de 50-70% vs. Glob
- Consumo: apenas 50-150 tokens
- Mapeamento instantâneo da estrutura
- Ideal para exploração inicial

---

### 4. pbi-add-measure
**Adiciona medidas DAX à tabela principal**

```bash
# Sintaxe
/pbi-add-measure <nome> <formula> [formatString]

# Exemplos
/pbi-add-measure tot_revenue "SUM(payroll_facts[salary])"
/pbi-add-measure avg_tenure "AVERAGE(employee_dimension[tenure_years])" "0.00"
/pbi-add-measure pct_growth "DIVIDE([tot_cy], [tot_py], 0) - 1" "0.0%"
```

**Benefícios:**
- Validação automática de nomes
- Formatação correta (TMDL)
- Geração de lineageTag único
- Atualização automática do índice

---

### 5. pbi-index-update
**Regenera o índice completo do projeto**

```bash
/pbi-index-update
```

**Benefícios:**
- Mantém POWER_BI_INDEX.md atualizado
- Detecta mudanças automaticamente
- Reconta tabelas, medidas e relacionamentos
- Estatísticas completas do projeto

---

## 🎯 Como Funciona

### Arquitetura

```
┌─────────────────────────────────────────┐
│  POWER_BI_INDEX.md (Raiz do Projeto)    │
│  - Índice principal                     │
│  - 200-400 tokens                       │
│  - Sempre consultado primeiro           │
└─────────────────────────────────────────┘
                  │
                  ├── Leitura otimizada
                  ↓
┌─────────────────────────────────────────┐
│  Skills (.claude/skills/)               │
│  - pbi-query-structure.md               │
│  - pbi-add-measure.md                   │
│  - pbi-index-update.md                  │
└─────────────────────────────────────────┘
                  │
                  ├── Quando necessário
                  ↓
┌─────────────────────────────────────────┐
│  Arquivos .tmdl (definition/tables/)    │
│  - Lidos apenas quando indispensável    │
│  - 1500-3000 tokens cada                │
└─────────────────────────────────────────┘
```

### Fluxo de Trabalho

```
Usuário solicita informação
        ↓
Skill consulta POWER_BI_INDEX.md (rápido)
        ↓
    ┌────────────────┐
    │ Encontrou?     │
    └────────────────┘
         │
    ┌────┴────┐
    │         │
   SIM       NÃO
    │         │
    ↓         ↓
Retorna   Lê arquivo .tmdl específico
           (apenas 1-2 arquivos)
                ↓
            Retorna
```

## 📊 Economia de Tokens

### Exemplo: Listar tabelas de dimensão

**Sem Skills (tradicional):**
```
1. Glob: definition/tables/*.tmdl → 500 tokens
2. Read: model.tmdl → 800 tokens
3. Read: 3-5 arquivos .tmdl → 3000 tokens
Total: ~4300 tokens
```

**Com Skills (otimizado):**
```
1. Skill: pbi-query-structure tabelas dimensao
2. Read: POWER_BI_INDEX.md → 300 tokens
3. Grep: seção específica → 50 tokens
Total: ~350 tokens
```

**Economia: 92%** 🎉

---

### Exemplo: Adicionar medida DAX

**Sem Skills (tradicional):**
```
1. Glob: tables/*.tmdl → 500 tokens
2. Read: vários arquivos para encontrar DAX.tmdl → 2000 tokens
3. Edit: DAX.tmdl → 1500 tokens
4. Atualizar índice manualmente → 500 tokens
Total: ~4500 tokens
```

**Com Skills (otimizado):**
```
1. Skill: pbi-add-measure
2. Read: POWER_BI_INDEX.md → 200 tokens
3. Read: DAX.tmdl (direto) → 1500 tokens
4. Edit: DAX.tmdl → 1500 tokens
5. Auto-update índice → 100 tokens
Total: ~3300 tokens
```

**Economia: 27%** 🎉

---

## 🔒 Segurança e Performance

### Arquivos NUNCA Lidos

Conforme `.claudecode.json`:
- `**/*.pbix` - Binários
- `.pbi/cache.abf` - Cache binário
- `.pbi/localSettings.json` - Settings locais
- `definition/bookmarks/*.json` - Bookmarks individuais (exceto quando necessário)
- `definition/pages/*/visuals/*.json` - Visuais (exceto quando necessário)

### Arquivos Prioritários

1. **POWER_BI_INDEX.md** - Sempre primeiro
2. **definition/model.tmdl** - Config geral
3. **definition/relationships.tmdl** - Relacionamentos
4. **definition/tables/*.tmdl** - Tabelas individuais (apenas quando necessário)

---

## 🛠️ Instalação

### Automática (já feito)

```
✅ .claude/skills/ criado
✅ POWER_BI_INDEX.md gerado
✅ 5 skills instaladas:
   - pbi-context-check.md (⭐ NOVO - gestão de contexto)
   - pbi-query-structure.md
   - pbi-discover.md
   - pbi-add-measure.md
   - pbi-index-update.md
```

### Manual (se necessário)

```bash
# 1. Criar pasta de skills
mkdir .claude/skills

# 2. Copiar arquivos .md das skills
cp pbi-*.md .claude/skills/

# 3. Gerar índice inicial
/pbi-index-update
```

---

## 📚 Casos de Uso

### 1. Gestão de Contexto (Novo Workflow)

```bash
# Antes de iniciar tarefa grande
/pbi-context-check

# Durante sessão longa (>20 interações)
# Claude sugere automaticamente se necessário

# Após completar tarefa complexa
/pbi-context-check
# Se recomendado: execute /compact

# Após compactar, continue normalmente
/pbi-query-structure tabelas
```

### 2. Exploração Inicial do Projeto

```bash
# Entender estrutura
/pbi-query-structure tabelas

# Ver todas as dimensões
/pbi-query-structure tabelas dimensao

# Ver todos os fatos
/pbi-query-structure tabelas fato

# Ver medidas principais
/pbi-query-structure medidas
```

### 3. Desenvolvimento de Medidas

```bash
# Buscar medidas existentes
/pbi-query-structure medidas employee

# Ver detalhes de uma tabela
/pbi-query-structure colunas payroll_facts

# Adicionar nova medida
/pbi-add-measure tot_active_employees "COUNTROWS(FILTER(payroll_facts, [termination_date] = BLANK()))" "#,0"

# Atualizar índice (se muitas mudanças)
/pbi-index-update
```

### 4. Análise de Relacionamentos

```bash
# Ver relacionamentos de fato
/pbi-query-structure relacionamentos payroll_facts

# Ver relacionamentos de dimensão
/pbi-query-structure relacionamentos employee_dimension

# Ver todos os relacionamentos
/pbi-query-structure relacionamentos
```

### 5. Documentação

```bash
# Gerar documentação atualizada
/pbi-index-update

# O POWER_BI_INDEX.md pode ser:
# - Commitado no Git
# - Compartilhado com time
# - Usado como referência
```

---

## 🧠 Gestão de Contexto (CRÍTICO)

### Por Que É Importante

Projetos Power BI com centenas de medidas DAX podem consumir rapidamente a janela de contexto. Sem gestão adequada:
- ❌ Claude "esquece" instruções anteriores
- ❌ Respostas ficam genéricas/imprecisas
- ❌ Performance degrada
- ❌ Risco de perda de contexto crítico

### Regras de Ouro

**NUNCA compactar durante:**
- ✍️ Escrita de arquivos
- 🔧 Edição de medidas
- 🔗 Modificação de relacionamentos
- 📊 Atualização de índice

**SEMPRE compactar após:**
- ✅ Tarefa completamente concluída
- ✅ Todos os arquivos salvos
- ✅ Entre tarefas (não durante)

### Protocolo Automático

Claude monitora proativamente e sugere `/compact` quando detecta:
- 🟡 **20+ interações** - Alerta amarelo
- 🔴 **40+ interações** - Alerta vermelho
- 📁 **15+ arquivos .tmdl lidos**
- 📝 **8+ medidas adicionadas**
- 🔄 **3+ atualizações de índice**

### Comunicação Clara

**Claude NUNCA dirá:**
```
❌ "Executando /compact..."
❌ "Compactei o contexto"
❌ "Vou limpar a memória"
```

**Claude SEMPRE dirá:**
```
✅ "Recomendo executar `/compact`"
✅ "Sugiro que você execute `/compact`"
✅ "Por favor, execute `/compact` antes de continuar"
```

### Uso da Skill

```bash
# Verificar status do contexto
/pbi-context-check

# Claude analisa e retorna:
# - Resumo da sessão
# - Arquivos lidos
# - Recomendação (sim/não)
# - Próximos passos
```

### Protocolo de Snapshot 📸

**Antes de sugerir `/compact`, Claude cria snapshot automático:**

```markdown
### 📸 Last Session Snapshot

**Status Atual:** Adicionando medidas de variância para KPIs
**Pendências:** Criar `pct_variance_turnover_yoy`
**Arquivos Quentes:** DAX.tmdl, DAX_Variance_PCT.tmdl
**Medidas em Foco:** tot_employee_cy, tot_employee_py
**Próxima Tarefa:** Continuar variâncias para turnover e tenure
```

**Benefícios:**
- 🔄 **Continuidade total** entre sessões
- 🧠 **Sem perda de contexto** após `/compact`
- 📋 **Retomada precisa** - nenhuma pergunta repetitiva
- 💾 **Estado preservado** - exatamente de onde parou

### Após Compactação

```
✅ Contexto compactado com sucesso (pelo usuário)
    ↓
📸 Snapshot detectado em MEMORY.md
    ↓
🔄 Claude retoma exatamente de onde parou:
    - Lê snapshot automaticamente
    - Internaliza contexto completo
    - Continua próxima tarefa sem perguntas
    ↓
💡 Skills e índice continuam funcionando normalmente
```

**Ao abrir nova sessão:**
```
👋 Olá!

📸 Snapshot detectado (2026-02-07 15:30)
Retomando de: Adicionando medidas de variância para KPIs

Próximo passo: Criar `pct_variance_turnover_yoy`

Pronto para continuar! 🚀
```

---

## 🎓 Boas Práticas

### Nomenclatura de Medidas

**Recomendado:**
```bash
# Snake_case
/pbi-add-measure tot_employee_active "..."
/pbi-add-measure avg_tenure_years "..."
/pbi-add-measure pct_turnover_rate "..."

# Prefixos comuns
tot_    # Total/Count
avg_    # Média
pct_    # Percentual
sum_    # Soma
max_    # Máximo
min_    # Mínimo
```

**Sufixos comuns:**
```
_cy     # Current Year
_py     # Previous Year
_yoy    # Year over Year
_mom    # Month over Month
_abs    # Absolute (variance)
_pct    # Percent (variance)
```

### Format Strings

```bash
# Inteiros
formatString: "#,0"

# Decimais
formatString: "#,0.00"

# Percentuais
formatString: "0.0%"
formatString: "0.00%"

# Moeda
formatString: "$#,0.00"
formatString: "R$ #,0.00"
```

### Quando Atualizar o Índice

**Execute /pbi-index-update após:**
- Adicionar nova tabela
- Remover tabela
- Adicionar 5+ medidas
- Modificar relacionamentos
- Mudanças estruturais significativas

**Não é necessário após:**
- Adicionar 1-2 medidas (pbi-add-measure já atualiza)
- Modificar fórmulas existentes
- Mudanças em visuais/relatórios

---

## 🔧 Troubleshooting

### Skill não encontrada

**Sintoma:**
```
Erro: Skill 'pbi-query-structure' não encontrada
```

**Solução:**
```bash
# Verificar se skills existem
ls .claude/skills/

# Se não existir, criar pasta
mkdir .claude/skills

# Copiar arquivos novamente
```

### Índice desatualizado

**Sintoma:**
```
Tabela 'nova_tabela' não aparece no índice
```

**Solução:**
```bash
/pbi-index-update
```

### Medida não foi adicionada

**Sintoma:**
```
Erro ao adicionar medida
```

**Soluções:**
1. Verificar nome (sem espaços, sem caracteres especiais)
2. Verificar fórmula (sintaxe DAX válida)
3. Verificar se DAX.tmdl existe e tem permissão de escrita

---

## 📊 Estatísticas do Projeto

### Projeto Atual: hr_kpis_board_v2

```
📊 Total de Tabelas: 37
   ├─ Dimensões: 7
   ├─ Fatos: 7
   ├─ Bridges: 7
   ├─ DAX/Medidas: 13
   └─ Auxiliares: 3

📐 Total de Medidas DAX: 617
   ├─ DAX: 265
   ├─ DAX_Variance_PCT: 72
   ├─ DAX_Variance_ABS: 61
   ├─ DAX_Texts: 44
   └─ [outras]: 175

🔗 Total de Relacionamentos: 21
   ├─ payroll_facts: 5
   ├─ promotions_facts: 3
   ├─ ninebox_facts: 3
   └─ [outros]: 10
```

---

## 🚀 Roadmap (Skills Futuras)

### pbi-add-table (Planejada)
```bash
/pbi-add-table <nome> <tipo> [colunas]
```
Criar nova tabela no modelo semântico.

### pbi-add-relationship (Planejada)
```bash
/pbi-add-relationship <from_table.column> <to_table.column> [bidirectional]
```
Adicionar relacionamento entre tabelas.

### pbi-validate (Planejada)
```bash
/pbi-validate
```
Validar integridade do modelo (relacionamentos órfãos, medidas inválidas, etc).

### pbi-search (Planejada)
```bash
/pbi-search <keyword>
```
Busca global em medidas, colunas, tabelas e relacionamentos.

---

## 📝 Formato TMDL

### Estrutura de Arquivo

**Dimensão:**
```tmdl
table employee_dimension
    lineageTag: {uuid}

    column employee_id
        dataType: int64
        isKey
        sourceColumn: employee_id

    column name
        dataType: string
        sourceColumn: name

    partition employee_dimension = m
        source = GoogleBigQuery.Database(...)
```

**Medida DAX:**
```tmdl
table DAX
    measure tot_employee_active = ```
        CALCULATE([tot_employee_base],
                  payroll_facts[termination_period] = BLANK())
        ```
        formatString: #,0
        lineageTag: {uuid}
```

**Relacionamento:**
```tmdl
relationship {uuid}
    fromColumn: payroll_facts.employee_id
    toColumn: employee_dimension.employee_id

relationship {uuid}
    crossFilteringBehavior: bothDirections
    fromColumn: client_area_bridge.area_id
    toColumn: area_dimension.area_id
```

---

## 🤝 Contribuindo

### Adicionar Nova Skill

1. Criar arquivo `.md` na pasta `.claude/skills/`
2. Seguir formato:
   ```markdown
   ---
   skill_name: nova-skill
   description: Descrição breve
   match_prompt: |
     Quando usar esta skill...
   version: 1.0.0
   ---

   # Nova Skill

   [Documentação completa]
   ```
3. Testar skill
4. Atualizar este README

### Reportar Problemas

- Criar issue no repositório
- Incluir comando executado
- Incluir erro recebido
- Incluir versão do Claude Code

---

## 📄 Licença

MIT License - Livre para uso e modificação

---

## 👥 Autores

- Sistema de Skills PBIP
- Claude Code v2.0+
- Power BI PBIP Format

---

**Última atualização:** 2026-02-07
**Versão do sistema:** 1.2.0 (+ Gestão de Contexto + Protocolo de Snapshot)
**Compatibilidade:** Power BI PBIP, Claude Code 2.0+

## 🎯 Resumo de Recursos

### ✅ Implementado
- [x] 5 Skills otimizadas (query, discover, add-measure, index-update, context-check)
- [x] Índice centralizado (POWER_BI_INDEX.md)
- [x] Gestão proativa de contexto
- [x] Protocolo de Snapshot automático
- [x] Economia de 85-90% de tokens
- [x] Integração completa com PBIP

### 🚀 Features Principais
- **Consultas rápidas** sem ler arquivos desnecessários
- **Adição segura de medidas** com validação automática
- **Monitoramento de contexto** com alertas proativos
- **Continuidade garantida** entre sessões (snapshots)
- **Retomada inteligente** sem perguntas repetitivas
