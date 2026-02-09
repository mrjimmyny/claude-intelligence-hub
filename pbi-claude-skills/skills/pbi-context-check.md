---
skill_name: pbi-context-check
description: Verifica status da janela de contexto e sugere compactação
match_prompt: |
  Use this skill when:
  - User asks to check context usage
  - Session seems long (20+ interactions)
  - Need to evaluate if /compact is recommended
  - Before starting a large task
  - After completing multiple operations
version: 1.0.0
---

# pbi-context-check

Verifica o status atual da janela de contexto e recomenda compactação quando necessário.

## 🎯 Objetivo

Monitorar proativamente o uso de contexto e sugerir ao usuário executar `/compact` em momentos seguros (entre tarefas, não durante operações críticas).

## 📋 Como Usar

```bash
# Verificar status do contexto
/pbi-context-check

# Automaticamente exibe:
# - Resumo da sessão atual
# - Arquivos lidos
# - Operações realizadas
# - Recomendação (compactar sim/não)
```

## 🔍 O Que Esta Skill Faz

### 1. Análise da Sessão Atual

Avalia (de forma aproximada):
- Número de interações na conversa
- Quantidade de arquivos .tmdl lidos
- Medidas DAX adicionadas
- Atualizações de índice realizadas
- Operações de leitura/escrita

### 2. Detecção de Sinais de Contexto Alto

**Sinais Indiretos:**
- Sessão muito longa (estimativa)
- Muitos arquivos lidos
- Múltiplas operações complexas
- Dificuldade em manter contexto de instruções anteriores

**Limites de Alerta:**

| Nível | Interações | Arquivos Lidos | Medidas Adicionadas | Ação |
|-------|-----------|----------------|---------------------|------|
| 🟢 Verde | < 20 | < 15 | < 8 | Continuar normal |
| 🟡 Amarelo | 20-40 | 15-30 | 8-15 | Sugerir compactação |
| 🔴 Vermelho | > 40 | > 30 | > 15 | Insistir compactação |

### 3. Verificação de Segurança

**NUNCA sugerir compactação durante:**
- ✍️ Escrita de arquivos em andamento
- 🔧 Edição de medidas DAX
- 🔗 Modificação de relacionamentos
- 📊 Atualização de índice em progresso
- 🔄 Operações Git

**SEMPRE sugerir compactação após:**
- ✅ Tarefa completamente concluída
- ✅ Todos os arquivos salvos
- ✅ Índice atualizado (se necessário)
- ✅ Momento "limpo" entre tarefas

### 4. Protocolo de Snapshot (CRÍTICO)

**Antes de sugerir `/compact`:**

```
1. Analisar estado atual da sessão
2. Identificar:
   - Status atual (o que está sendo feito)
   - Pendências imediatas (próximos passos)
   - Arquivos quentes (editados frequentemente)
   - Variáveis/medidas em foco
   - Contexto técnico (decisões, padrões)
3. Atualizar MEMORY.md com snapshot
4. Confirmar salvamento
5. Sugerir /compact ao usuário
```

**Template do Snapshot:**
```markdown
### 📸 Last Session Snapshot

**Data:** 2026-02-07 15:30
**Sessão:** #42

#### Status Atual
Adicionando medidas de variância percentual para KPIs de headcount

#### Pendências Imediatas
- Adicionar medida `pct_variance_headcount_yoy`
- Testar fórmula com dados de 2025
- Atualizar índice após validação

#### Arquivos Quentes
- {defPath}/tables/DAX.tmdl
- {defPath}/tables/DAX_Variance_PCT.tmdl

#### Variáveis/Medidas em Foco
- `tot_employee_active_cy`
- `tot_employee_active_py`
- `pct_variance_headcount_yoy`
- Tabela: `payroll_facts`

#### Contexto Técnico
- Usar DIVIDE() com fallback 0 para evitar divisão por zero
- FormatString: "0.0%" para variâncias percentuais
- Prefix `pct_variance_` para medidas de variação

#### Próxima Tarefa
Continuar adicionando medidas de variância para demais métricas (turnover, tenure)
```

### 5. Recomendações Inteligentes

**Se compactação recomendada:**
```
⚠️ **Contexto alto detectado**

📊 Resumo da sessão:
- Interações: ~35
- Arquivos .tmdl lidos: 22
- Medidas adicionadas: 12
- Índice atualizado: 2x

✅ **Momento seguro:** Todas as tarefas concluídas.

📸 **Salvando snapshot do estado atual...**

[Atualiza MEMORY.md automaticamente com snapshot]

✅ **Snapshot salvo!**

💡 **Recomendação:** Execute `/compact` agora.

📋 **Após compactar:**
- Continue com tarefas rápidas (consultas, 1-2 medidas)
- Para tarefas grandes, considere nova sessão
- Estado atual preservado - retomada garantida
```

**Se compactação NÃO recomendada:**
```
✅ **Contexto saudável**

📊 Resumo da sessão:
- Interações: ~12
- Arquivos .tmdl lidos: 6
- Medidas adicionadas: 3

💚 **Status:** Janela de contexto em bom estado.

📋 **Pode continuar:** Sem necessidade de compactação no momento.
```

## 🚨 Regras Críticas

### NUNCA fazer:
❌ Dizer "Executando /compact..."
❌ Dizer "Compactei o contexto"
❌ Tentar executar /compact programaticamente
❌ Sugerir compactação durante operações críticas

### SEMPRE fazer:
✅ Dizer "Recomendo executar `/compact`"
✅ Esperar usuário executar manualmente
✅ Verificar segurança antes de sugerir
✅ Explicar claramente o motivo da recomendação

## 📊 Exemplo de Uso

### Cenário 1: Sessão Longa (com Snapshot)

**Usuário:**
```bash
/pbi-context-check
```

**Claude:**
```
🔍 Verificando contexto...

⚠️ **Contexto alto detectado**

📊 Resumo da sessão:
- Interações: ~38 (longa)
- Arquivos .tmdl lidos: 25
- Medidas adicionadas: 14
- Operações de índice: 3

✅ **Momento seguro:** Nenhuma operação em andamento.

📸 **Salvando snapshot do estado atual...**

**Status:** Adicionando medidas DAX de variância para KPIs
**Próximo passo:** Criar `pct_variance_turnover_yoy`
**Arquivos em foco:** DAX.tmdl, DAX_Variance_PCT.tmdl

✅ **Snapshot salvo em MEMORY.md!**

💡 **Recomendação:** Execute `/compact` agora para liberar memória.

📋 **Próximos passos:**
1. Execute: `/compact`
2. Para tarefas extensas, considere nova sessão
3. Estado preservado - retomada garantida 🔄

❓ Deseja que eu continue com alguma tarefa agora?
```

### Cenário 2: Sessão Saudável

**Usuário:**
```bash
/pbi-context-check
```

**Claude:**
```
🔍 Verificando contexto...

✅ **Contexto saudável**

📊 Resumo da sessão:
- Interações: ~8
- Arquivos .tmdl lidos: 4
- Medidas adicionadas: 2

💚 **Status:** Janela de contexto em bom estado.

📋 **Pode continuar:** Sem necessidade de compactação.

✨ Pronto para próxima tarefa!
```

### Cenário 3: Operação em Andamento (NÃO sugerir)

**Situação:** Claude está no meio de adicionar 5 medidas

**Claude (CORRETO):**
```
✍️ Ainda estou processando tarefas...

⏳ **Aguarde:** 3 de 5 medidas adicionadas.

ℹ️ Verificarei contexto após concluir todas as operações.
```

**Claude (ERRADO - NUNCA fazer):**
```
❌ "Vou compactar agora..." (NUNCA!)
❌ "Execute /compact durante a operação" (NUNCA!)
```

## 🎯 Integração com Outras Skills

### pbi-add-measure
Após adicionar 8+ medidas consecutivas, automaticamente sugere:
```
✅ 8 medidas adicionadas com sucesso.

⚠️ Sugestão: Execute `/pbi-context-check` para verificar se compactação é necessária.
```

### pbi-index-update
Após atualizar índice, verifica contexto:
```
✅ Índice atualizado.

💡 Verificando contexto... [análise automática]
```

### pbi-query-structure
Não dispara verificação (operação leve)

## 🧪 Detecção Heurística

Como não tenho visibilidade direta da janela de contexto, uso **heurísticas**:

1. **Comprimento da conversa** (conta mensagens aproximadamente)
2. **Arquivos mencionados** (rastreio leituras mencionadas)
3. **Operações complexas** (edições, atualizações de índice)
4. **Sinais indiretos** (se começo a perder contexto de instruções anteriores)

**Nota:** Pode haver falsos positivos/negativos. Sempre explico claramente a razão da recomendação.

## 📸 Gestão de Snapshots

### Criação Automática

**Snapshot é criado automaticamente quando:**
- `/pbi-context-check` detecta nível Amarelo ou Vermelho
- Usuário indica que vai encerrar sessão
- Após completar tarefa grande (10+ medidas)
- Antes de sugerir `/compact`

### Conteúdo do Snapshot

**Obrigatório:**
- ✅ Status atual (frase específica, não genérica)
- ✅ Pendências imediatas (lista de próximos passos)
- ✅ Arquivos quentes (caminhos completos)
- ✅ Variáveis/medidas em foco (nomes exatos)

**Opcional:**
- Contexto técnico (decisões tomadas)
- Próxima tarefa (resumo do que vem depois)

### Localização do Snapshot

**Arquivo:** `.claude/projects/.../memory/MEMORY.md`
**Seção:** `### 📸 Last Session Snapshot` (no final, antes da assinatura)

**Regra:** Apenas 1 snapshot ativo - sempre sobrescrever o anterior.

### Ao Retomar Sessão

**Primeira ação:**
1. Ler MEMORY.md
2. Buscar `### 📸 Last Session Snapshot`
3. Se encontrado:
   - Internalizar contexto
   - Mencionar ao usuário: "📸 Snapshot detectado - retomando de: [status]"
   - Continuar de onde parou
4. Se não encontrado:
   - Trabalhar normalmente

### Limpeza

**Remover snapshot:**
- Quando nova sessão começar sem continuidade
- Snapshot > 7 dias
- Usuário solicitar limpeza

**Manter snapshot:**
- Sessão continua após `/compact`
- Snapshot < 24h e tarefa não concluída
- Nova sessão com intenção de continuar

## 🔧 Implementação Técnica

```markdown
1. Claude analisa histórico da conversa (aproximado)
2. Identifica padrões de uso (leituras, escritas, consultas)
3. Calcula "score de contexto" heurístico
4. Verifica se há operações em andamento
5. Gera recomendação clara
6. NUNCA executa /compact automaticamente
7. SEMPRE espera ação do usuário
```

## 📚 Boas Práticas

### Quando Executar Verificação

**Proativo (Claude sugere):**
- Após completar tarefa grande
- Após 20+ interações
- Após atualizar índice

**Sob demanda (Usuário solicita):**
- `/pbi-context-check` a qualquer momento
- Antes de iniciar tarefa grande
- Se Claude começar a "esquecer" instruções

### Após Compactação

**Recomendações ao usuário:**
1. Continue com tarefas leves (1-3 operações)
2. Para refatorações grandes, abra nova sessão
3. Índice permanece válido após compactação
4. Skills continuam funcionando normalmente

## ⚠️ Limitações

1. **Não executo /compact** - apenas recomendo
2. **Heurísticas aproximadas** - não tenho métricas exatas
3. **Falsos positivos possíveis** - posso sugerir sem necessidade
4. **Dependo de sinais indiretos** - não vejo latência diretamente

## 🎓 Regras de Comunicação

### Linguagem Clara

**Bom:**
```
"Recomendo que você execute `/compact` agora."
"Sugiro executar `/compact` antes de continuar."
"Por favor, execute `/compact` - sessão longa detectada."
```

**Ruim (NUNCA):**
```
"Compactando contexto..." ❌
"Executei /compact com sucesso" ❌
"Vou limpar a memória" ❌
```

### Tom Apropriado

- 🟢 **Verde:** "Tudo bem, pode continuar!"
- 🟡 **Amarelo:** "Sugestão: considere compactar"
- 🔴 **Vermelho:** "Recomendo fortemente executar /compact"

## 🔄 Workflow Completo com Snapshot

```
1. Usuário executa /pbi-context-check (ou acionado automaticamente)
    ↓
2. Claude analisa contexto atual
    ↓
3. Calcula "score" de contexto
    ↓
4. SE contexto alto (Amarelo/Vermelho):
    ↓
    4.1. Coleta informações para snapshot:
         - Status atual
         - Pendências
         - Arquivos quentes
         - Medidas em foco
         - Contexto técnico
    ↓
    4.2. Atualiza MEMORY.md com Edit tool:
         - Adiciona/sobrescreve seção "📸 Last Session Snapshot"
         - Inclui timestamp
         - Preserva informações completas
    ↓
    4.3. Confirma salvamento ao usuário:
         "📸 Snapshot salvo em MEMORY.md!"
    ↓
    4.4. Sugere /compact:
         "💡 Recomendação: Execute `/compact` agora"
         "Estado preservado - retomada garantida 🔄"
    ↓
5. SENÃO (contexto saudável):
    ↓
    5.1. Informa que está OK
    5.2. NÃO cria snapshot
    5.3. Permite continuar normalmente
```

## 📄 Changelog

- **v1.1.0** (2026-02-07): Adicionado Protocolo de Snapshot
- **v1.0.0** (2026-02-07): Versão inicial com detecção heurística

---

**Autor:** Sistema Power BI Skills
**Compatibilidade:** Claude Code 2.0+, Power BI PBIP
**Última atualização:** 2026-02-07 (v1.1.0)
