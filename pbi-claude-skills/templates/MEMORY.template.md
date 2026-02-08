# Power BI PBIP Project - Memory Template

> **Instruções:** Copie este arquivo para `.claude/projects/[seu-projeto]/memory/MEMORY.md` e customize com informações do seu projeto.

## 🎯 Projeto

**Nome:** [Nome do seu projeto]
**Tipo:** Power BI Project (PBIP)
**Formato:** Tabular Model Definition Language (TMDL)

## 📊 Estrutura do Projeto

### Modelo Semântico
- **Localização:** `[SeuProjeto].SemanticModel/`
- **Total de Tabelas:** [número]
- **Total de Medidas DAX:** [número]
- **Total de Relacionamentos:** [número]
- **Fonte de Dados:** [tipo]

### Categorias de Tabelas
1. **Dimensões:** [listar tabelas]
2. **Fatos:** [listar tabelas]
3. **Bridges:** [listar tabelas, se houver]
4. **DAX/Medidas:** [listar tabelas de medidas]
5. **Auxiliares:** [listar tabelas, se houver]

## 🛠️ Skills Hub Configurado

### Repositório
- **URL:** https://github.com/mrjimmyny/claude-intelligence-hub
- **Versão:** v1.0.0
- **Última atualização:** [data]

### Skills Ativas
- ✅ pbi-add-measure
- ✅ pbi-query-structure
- ✅ pbi-discover
- ✅ pbi-index-update
- ✅ pbi-context-check

## 📁 Arquivos Críticos

### Para Leitura
- `POWER_BI_INDEX.md` - Sempre consultar primeiro
- `pbi_config.json` - Configuração do projeto
- `definition/model.tmdl` - Config do modelo
- `definition/relationships.tmdl` - Todos os relacionamentos
- `definition/tables/*.tmdl` - Tabelas individuais (apenas quando necessário)

### Para Modificação
- `definition/tables/DAX.tmdl` - Medidas DAX principais
- Outras tabelas DAX conforme necessário

### Para Evitar (Performance)
- `.pbi/cache.abf` - Cache binário
- `.pbi/localSettings.json` - Settings locais
- Bookmarks/visuais individuais (exceto se necessário)

## 🔑 Formato TMDL

### Estrutura de Medida
```tmdl
measure nome_medida = ```
    [formula DAX]
    ```
    formatString: #,0
    lineageTag: [uuid]
```

### Relacionamento
```tmdl
relationship [uuid]
    fromColumn: tabela_from.coluna
    toColumn: tabela_to.coluna
    [crossFilteringBehavior: bothDirections]  # opcional
```

## 💡 Boas Práticas

1. Sempre consultar POWER_BI_INDEX.md antes de ler arquivos .tmdl
2. Usar skills para operações comuns (consulta, adicionar medida)
3. Atualizar índice após mudanças estruturais significativas
4. Respeitar .claudecode.json (nunca ler .pbix, cache, etc)
5. Usar pbi_config.json para parametrizar paths

## 🚀 Workflows Otimizados

### Adicionar Medida DAX
```bash
/pbi-add-measure nome_medida "formula DAX" "formato"
# Automático: validação + formatação + atualização de índice
```

### Consultar Estrutura
```bash
/pbi-query-structure tabelas [tipo]
/pbi-query-structure medidas [keyword]
/pbi-query-structure relacionamentos [tabela]
/pbi-query-structure colunas [tabela]
```

### Atualizar Índice
```bash
/pbi-index-update
# Após: adicionar tabelas, mudanças estruturais
```

## 🔒 Regras de Segurança

### Nunca Ler
- `**/*.pbix`
- `.pbi/cache.abf`
- `.pbi/localSettings.json`
- Arquivos binários ou cache

### Sempre Validar
- Nome de medida (sem espaços, snake_case)
- Fórmula DAX não vazia
- lineageTag único (UUID)
- Format string apropriado

## 🧠 Gestão de Contexto

### Regras de Compactação

**NUNCA** executar `/compact` durante operações críticas:
- Escrita de arquivos (.tmdl, índices)
- Edição de medidas DAX
- Atualização de relacionamentos
- Operações Git em andamento

**SEMPRE** sugerir `/compact` após concluir tarefas quando detectar:

1. **Sinais de Contexto Alto:**
   - Sessão > 30 interações
   - Leitura de 20+ arquivos .tmdl
   - Adição de 10+ medidas

2. **Checkpoints Automáticos:**
   - Após `/pbi-index-update` completo
   - Após criar 5+ medidas consecutivas
   - Após exploração extensa (10+ consultas)

### Comunicação ao Usuário

**SEMPRE dizer:**
- "Recomendo executar `/compact`"
- "Sugiro que você execute `/compact`"

**NUNCA dizer:**
- "Executando /compact..." (você não pode executar)
- "Compactei o contexto" (apenas o usuário pode)

## 📸 Protocolo de Snapshot

### Quando Criar Snapshot

**SEMPRE criar snapshot antes de:**
- Sugerir `/compact`
- Usuário indicar que vai encerrar sessão
- Concluir tarefa grande (10+ medidas, refatoração completa)

### Template do Snapshot

```markdown
### 📸 Last Session Snapshot

**Data:** [data hora]
**Sessão:** #[número]

#### Status Atual
[O que estava sendo feito no exato momento]

#### Pendências Imediatas
[Próximo passo exato que seria dado]

#### Arquivos Quentes
[Caminhos de arquivos sendo editados]

#### Variáveis/Medidas em Foco
[Nomes específicos no centro da discussão]

#### Contexto Técnico
[Decisões, descobertas, padrões identificados]

#### Próxima Tarefa
[O que fazer ao retomar]
```

---

**Última atualização:** [data]
**Status:** Skills Hub Configurado
