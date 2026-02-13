---
entry_id: 2026-02-13-001
date: 2026-02-13
time: 05:05
category: Other
tags: [x-mem-protocol, memory-system, architecture-design, token-optimization, session-persistence]
status: aberto
priority: alta
last_discussed: 2026-02-13
resolution: ""
summary: Arquitetura completa do X-MEM Protocol para memorizar falhas/sucessos e evitar erros repetidos entre sessões
---

# X-MEM Protocol - Sistema de Memória de Experiências para Xavier

## Context

Jimmy solicitou o design de um protocolo crítico chamado **X-MEM Protocol** que funciona como um buffer de experiências orientado a máquina (machine-oriented), NÃO como um log legível por humanos. O objetivo principal é reduzir uso de tokens, tempo e evitar erros repetidos entre sessões.

## Decision

Foi realizada uma análise arquitetural completa como Senior System Architect, seguindo os requisitos:

1. **NÃO salvar sessões inteiras** - apenas resumos compactos estruturados
2. **Biblioteca para Xavier, não para o usuário** - formato pode ser não-amigável se mais eficiente
3. **Acesso sob demanda, não automático** - evitar queimar tokens desnecessariamente

## Key Details

### Análise Realizada (6 Seções)

1. **Barriers & Risks**
   - Limitações técnicas do Claude Code
   - Riscos: memory overfitting, token bloat, stale knowledge, false blocking, cross-machine sync

2. **Architectural Options**
   - Option A: NDJSON File-Based Store (simple, Git-friendly)
   - Option B: SQLite Database (indexed queries, higher complexity)
   - Option C: Tiered Memory System (hot/cold split)
   - Option D: MCP Server Backend (maximum flexibility, overkill)

3. **Winning Strategy**
   - **Recomendado: Option A (NDJSON) + elementos de Option C (tiering)**
   - Justificativa: Token efficiency (3-5K per query vs 50-100K full load)
   - Localização: `claude-intelligence-hub/x-mem/`
   - Files: `failures.jsonl`, `successes.jsonl`, `index.json`

4. **Data Model**
   - Common fields: id, ts, type, tool, tags, ctx_hash, session_id
   - Failure-specific: action, error, pattern_avoid, tried_also, block_level, notes
   - Success-specific: pattern_name, key_steps, critical_params, confidence, usage_count
   - Token cost per entry: ~150-200 tokens

5. **Trigger/Command Design**
   - Comandos: `/xmem:load`, `/xmem:record`, `/xmem:search`, `/xmem:stats`, `/xmem:compact`
   - Workflow em 3 fases: Index Scan → Filtered Search → Context Integration
   - Token budget control: hard limit de 15K tokens por query

6. **Open Questions**
   - Auto-detection vs explicit triggers
   - Entry lifespan / pruning strategy
   - Cross-session correlation
   - Token budget preferences

### Real-World Impact Example

**Sem X-MEM:** Repetir mesmos 4 tentativas de rclone sync (40 min) em cada sessão
**Com X-MEM:** Carregar padrão conhecido (5K tokens, 0 min desperdiçado)

**ROI:** Break-even após prevenir apenas 1-2 erros repetidos

## Next Steps

- [ ] Aguardar aprovação explícita de Jimmy
- [ ] Entrar em plan mode para design de implementação
- [ ] Implementar Phase 1 (Core NDJSON files, ~1-2h)
- [ ] Implementar Phase 2 (Index system, ~30min)
- [ ] Implementar Phase 3 (Polish & compaction, ~1h)

## References

- Sistema inspirado em session-memoria (conhecimento permanente)
- Integração com claude-intelligence-hub infrastructure
- Storage via Git + Google Drive (já configurado)

---
**Recorded by:** Xavier
**Session duration:** ~45 minutes
**Entry size:** ~350 words
