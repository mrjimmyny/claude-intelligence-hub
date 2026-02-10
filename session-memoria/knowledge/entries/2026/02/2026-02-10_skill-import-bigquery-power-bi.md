---
entry_id: 2026-02-10-002
date: 2026-02-10
time: 23:45
category: Power BI
tags: [power-bi, bigquery, skill-development, data-import, pbi-claude-skills]
status: aberto
priority: media
last_discussed: 2026-02-10
resolution: ""
project: pbi-claude-skills
summary: Ideia de nova skill para automatizar import de tabelas do BigQuery para Power BI via pbi-claude-skills
---

# Skill de Import Automatizado: BigQuery → Power BI

## Context
Antes de encerrar a sessão, Jimmy pediu para registrar uma ideia de nova skill a ser desenvolvida. O objetivo é criar uma automação dentro do ecossistema pbi-claude-skills que permita ao Claude realizar o import de tabelas do BigQuery para projetos Power BI de forma automática e humanizada.

## Idea
Criar uma nova skill dentro do conjunto **pbi-claude-skills** que automatize e humanize o processo de importação de tabelas provenientes do BigQuery (modo Import) para um determinado Projeto de Power BI.

### Funcionalidade Core
- Pedir ao Claude que faça o import de **X tabelas** de **Y dataset** e **Z projeto** no BigQuery para o Power BI
- Usar toda a estrutura já existente no pbi-claude-skills como base
- O processo deve ser automatizado mas com uma abordagem humanizada (fácil de usar via linguagem natural)

### Escopo Preliminar
- **Modo:** Import (não DirectQuery)
- **Fonte:** Google BigQuery
- **Destino:** Projeto Power BI existente
- **Integração:** Deve se encaixar no ecossistema pbi-claude-skills já criado

## Key Details
- A skill precisa entender a estrutura de projetos e datasets do BigQuery
- Deve gerar as queries M/Power Query necessárias para o import
- Deve respeitar as convenções do pbi-claude-skills existente
- A interface deve ser via linguagem natural: "Xavier, importa as tabelas X, Y, Z do dataset ABC do projeto BigQuery DEF para o Power BI"

## Next Steps
- [ ] Revisar a estrutura atual do pbi-claude-skills para entender os padrões
- [ ] Definir o escopo detalhado da skill (quais operações suportar)
- [ ] Planejar a arquitetura: como a skill se integra ao pbi-claude-skills
- [ ] Discutir com Jimmy os cenários de uso mais comuns
- [ ] Prototipar a primeira versão da skill

## References
- Related skill: pbi-claude-skills (base para a nova skill)
- Related entry: [[2026-02-10-001]] (implementação do session-memoria)

---
**Recorded by:** Xavier
**Session duration:** ~120 minutes
**Entry size:** 280 words
