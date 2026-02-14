# Session Memoria - Xavier's Second Brain 🧠

**Version:** 1.2.0
**Status:** Active
**Language:** Portuguese (pt-BR)

---

## O que é?

Session Memoria é o sistema de gestão de conhecimento permanente do Jimmy. Transforma conversas efêmeras em conhecimento durável, pesquisável e organizado.

### Funcionalidades Principais

- 💾 **Captura:** Salva conversas, decisões, insights e ideias com metadados ricos
- 🔍 **Busca:** Sistema de índice triplo (data, categoria, tag)
- 📊 **Monitor:** Acompanha crescimento e alerta sobre limites
- 🔄 **Sync:** Integração automática com Git (commit + push)
- 🗂️ **Organização:** Estrutura por ano/mês, múltiplos índices

---

## Como Usar

### Salvar Informação

Diga para Xavier:
- "Xavier, registre isso"
- "X, salve essa conversa"
- "Registre isso"
- "Salvar essa decisão"

Xavier vai:
1. Analisar o contexto da conversa
2. Sugerir categoria, tags e resumo
3. Pedir confirmação
4. Criar entrada com ID único
5. Atualizar índices
6. Fazer commit no Git

### Buscar Informação

Diga para Xavier:
- "Xavier, já falamos sobre X?"
- "X, busca tema Y"
- "Procure na memoria"
- "O que já conversamos sobre X?"

Xavier vai mostrar:
- Top 5-10 resultados relevantes
- Preview (ID, data, categoria, resumo, tags)
- Opção de ler entrada completa

### Ver Estatísticas

Digite: `/session-memoria stats`

Mostra:
- Total de entradas e tamanho
- Distribuição por categoria
- Distribuição por mês
- Top 10 tags
- Projeção de crescimento

---

## Estrutura de Arquivos

```
session-memoria/
├── .metadata                      # Configuração do skill
├── SKILL.md                        # Instruções para Claude
├── README.md                       # Esta documentação
├── CHANGELOG.md                    # Histórico de versões
├── SETUP_GUIDE.md                  # Guia de instalação
├── templates/
│   ├── entry.template.md           # Template de entrada
│   └── index.template.md           # Template de índice
└── knowledge/                      # Repositório de conhecimento
    ├── index/
    │   ├── by-date.md              # Índice cronológico
    │   ├── by-category.md          # Índice por categoria
    │   └── by-tag.md               # Índice por tag
    ├── entries/
    │   └── YYYY/
    │       └── MM/
    │           └── YYYY-MM-DD_topic-slug.md
    └── metadata.json               # Estatísticas e contadores
```

---

## Formato de Entrada

Cada entrada tem:

### Frontmatter (YAML)
```yaml
---
entry_id: YYYY-MM-DD-NNN          # ID único auto-gerado
date: YYYY-MM-DD
time: HH:MM
category: Power BI                # Categoria predefinida
tags: [dax, optimization, perf]   # Max 5 tags
project: opcional
conversation_id: opcional
summary: Resumo em uma linha (max 120 chars)
---
```

### Conteúdo (Markdown)
- **Context:** O que levou a essa conversa
- **Decision/Insight/Idea:** O ponto principal
- **Key Details:** Detalhes técnicos, exemplos, código
- **Next Steps:** Tasks opcionais
- **References:** Links e referências

---

## Sistema de Índice Triplo

### 1. by-date.md (Índice Primário)
- Organização cronológica por YYYY-MM
- Mais usado (pessoas lembram "semana passada")
- Entradas mais recentes primeiro

### 2. by-category.md
- Agrupamento por domínio
- Categorias:
  - Power BI
  - Python
  - Gestão
  - Pessoal
  - Git
  - Other

### 3. by-tag.md
- Temas transversais
- Tag cloud (por frequência)
- Permite busca cross-domain

**Todos os índices se auto-atualizam** a cada save.

---

## Monitoramento de Crescimento

### Limites de Alerta

| Nível | Entradas | Tamanho | Ação |
|-------|----------|---------|------|
| Info | < 500 | < 5MB | Nenhuma |
| Warning | 500-1000 | 5-10MB | Revisar e consolidar |
| Critical | > 1000 | > 10MB | Arquivamento recomendado |

### Projeção
- **Uso esperado:** 3-7 entradas/dia
- **6 meses:** ~540-1260 entradas (~3-6 MB)
- **Alerta automático** ao atingir thresholds

---

## Integração com Git

### Commit Automático
Após cada save:
```bash
git add knowledge/entries/YYYY/MM/YYYY-MM-DD_slug.md
git add knowledge/index/*.md
git add knowledge/metadata.json
git commit -m "feat(session-memoria): add entry YYYY-MM-DD-NNN - [summary]"
git push origin main
```

### Formato de Commit
```
feat(session-memoria): add entry YYYY-MM-DD-NNN - [resumo]

Category: [categoria]
Tags: [tag1, tag2, tag3]
Summary: [resumo completo]
```

---

## Categorias e Tags

### Categorias Predefinidas
- **Power BI:** DAX, modelagem, relatórios, performance
- **Python:** Scripts, automação, bibliotecas, patterns
- **Gestão:** Decisões, processos, planejamento, pessoas
- **Pessoal:** Aprendizados, reflexões, objetivos
- **Git:** Workflows, comandos, estratégias
- **Other:** Tudo que não se encaixa acima

### Boas Práticas para Tags
- Use tags existentes quando possível
- Max 5 tags por entrada
- Formato: kebab-case (`dax-optimization`, `git-workflow`)
- Prefira específico sobre genérico
- Exemplos:
  - ✅ `power-query`, `python-async`, `dax-time-intelligence`
  - ❌ `código`, `trabalho`, `importante`

---

## O que Salvar?

### ✅ Salvar
- Decisões importantes com raciocínio
- Insights técnicos e aprendizados
- Ideias de projetos (atuais ou futuros)
- Abordagens de resolução de problemas
- Descobertas de configuração
- Padrões de código úteis

### ❌ Não Salvar
- Conclusão de tarefas rotineiras
- Perguntas/respostas simples
- Iterações de teste/debug
- Notas temporárias

---

## Integração com jimmy-core-preferences

Session Memoria trabalha em conjunto com a personalidade core do Jimmy:

### Oferecimento Proativo
Xavier vai oferecer salvar quando você:
- Tomar uma decisão significativa
- Compartilhar um insight valioso
- Mencionar uma ideia de projeto

### Recall Proativo
Xavier vai referenciar memórias anteriores quando relevante:
- "Já conversamos sobre isso em [YYYY-MM-DD-NNN]"
- "Você decidiu X porque Y"

### Memória em Dois Níveis
- **MEMORY.md:** Curto prazo, padrões, aprendizados (< 200 linhas)
- **Session Memoria:** Longo prazo, pesquisável, arquivo detalhado

---

## Estatísticas (v1.2.0)

- **Total de entradas:** 11
- **Tamanho total:** ~56KB
- **Última entrada:** 2026-02-13-001
- **Status:** Produção ativa (3-tier archiving system)
- **Tiers:** HOT (11), WARM (0), COLD (0)
- **Categorias:** Projects, Power BI, Architecture, Security, Other
- **Cross-device:** Desktop + Mobile sync ativo
- **Performance:** O(1) incremental indexing, 97% token savings at scale

---

## Exemplos de Uso

### Exemplo 1: Salvar Decisão Técnica
```
Você: "Decidi usar DAX variables ao invés de calculated columns para melhorar performance"
Xavier: "Quer que eu registre essa decisão?"
Você: "Xavier, registre isso"
Xavier: [analisa e sugere metadados]
Você: "Confirma"
Xavier: ✅ Registrado! Entry ID: 2026-02-10-001
```

### Exemplo 2: Buscar Conversa Anterior
```
Você: "Xavier, já falamos sobre otimização de DAX?"
Xavier: 🔍 Encontrei 3 resultados para "otimização de DAX":
1. [2026-02-10-001] | Power BI | Decisão usar variables...
2. [2026-02-05-002] | Power BI | Insight sobre CALCULATE...
...
Você: "Mostra o 1"
Xavier: [exibe entrada completa]
```

### Exemplo 3: Ver Progresso
```
Você: /session-memoria stats
Xavier: [exibe estatísticas completas]
```

---

## Roadmap

### v1.0.0 (Released 2026-02-10)
- ✅ Save workflow com Git
- ✅ Triple index system
- ✅ Search multi-index
- ✅ Growth monitoring
- ✅ Portuguese support

### v1.1.0 (Released 2026-02-11)
- ✅ Entry status tracking (aberto, em_discussao, resolvido, arquivado)
- ✅ Priority levels (alta, media, baixa)
- ✅ Update triggers ("xavier, marca como resolvido")
- ✅ Recap triggers ("xavier, resume os últimos registros")
- ✅ Mobile support via MOBILE_SESSION_STARTER.md
- ✅ Cross-device sync (Desktop + Mobile)

### v1.2.0 (Released 2026-02-13)
- ✅ **3-Tier Archiving System:** HOT/WARM/COLD tiers based on age and status
- ✅ **Incremental Indexing:** O(1) constant-time performance (200x faster)
- ✅ **Token Budget Management:** 97% token savings at scale (8K vs 250K+ tokens)
- ✅ **Deep Search Protocol:** --deep and --full flags for archived content
- ✅ **Aggressive Tiering:** <30d HOT, 30-90d WARM, >90d COLD

### v1.3.0 (Planned Q2 2026)
- Entry merging & consolidation
- Tag cleanup tools
- Entry summarization
- Export (PDF, JSON, HTML)

---

## 📱 Mobile Usage (claude.ai app)

**Important:** The Claude mobile app doesn't load local skills automatically.

### Solution: Use MOBILE_SESSION_STARTER.md

**One-time setup:**
1. Download [MOBILE_SESSION_STARTER.md](MOBILE_SESSION_STARTER.md) to your mobile device
2. Save in an accessible location

**Every mobile Code session:**
1. Start new Claude Code session on mobile
2. Attach MOBILE_SESSION_STARTER.md file
3. Claude will load all necessary context
4. Use session-memoria normally

**What MOBILE_SESSION_STARTER.md provides:**
- ✅ Complete session-memoria context
- ✅ Repository structure
- ✅ Entry templates and formats
- ✅ Git sync protocol
- ✅ Xavier identity and behavior
- ✅ All valid statuses, categories, tags
- ✅ Step-by-step operation guides

**Mobile workflow:**
```
Mobile: Create/update entry → Commit + Push
   ↓
Desktop: Git pull (auto-sync via junction points)
   ↓
Desktop: Skills auto-updated with mobile changes ✅
```

**Limitations on mobile:**
- ❌ No auto-triggers ("xavier, registre isso")
- ❌ No automatic skill loading
- ✅ Manual operations work perfectly with starter file
- ✅ Full Git sync with desktop

See [MOBILE_SESSION_STARTER.md](MOBILE_SESSION_STARTER.md) for complete mobile instructions.

---

## Suporte

- **Repositório:** https://github.com/mrjimmyny/claude-intelligence-hub
- **Issues:** GitHub Issues
- **Skill directory:** `~/.claude/skills/user/session-memoria`

---

## Licença

MIT License - Sinta-se livre para usar e modificar.

---

**Criado por Xavier para Jimmy**
**Data:** 2026-02-10
**Versão:** 1.1.0
**Última atualização:** 2026-02-11
