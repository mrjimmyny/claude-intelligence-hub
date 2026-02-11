---
entry_id: 2026-02-10-003
date: 2026-02-10
time: 23:55
category: Projects
tags: [skill-development, performance-review, project-tracking, portfolio, gestao]
status: aberto
priority: media
last_discussed: 2026-02-10
resolution: ""
project: claude-intelligence-hub
summary: Ideia de skill para registrar projetos concluidos e alimentar dados para Performance Review anual
---

# Skill de Project Portfolio / Performance Review Tracker

## Context
Jimmy precisa, todo final de ano, preparar seu Performance Review listando todos os projetos desenvolvidos, soluções implementadas, valor de negócio gerado, etc. Hoje esse processo é manual e depende da memória. A ideia é criar uma skill dedicada para capturar essas informações continuamente ao longo do ano.

## Idea
Criar uma skill que funcione como um **Project Portfolio Tracker** — um registro vivo de todos os projetos desenvolvidos, organizado por período (ano, mês), com detalhes relevantes para avaliação de performance.

### Conceito Central
- Sempre que concluirmos um projeto, alimentamos essa skill com as informações relevantes
- No momento do Performance Review, temos um local centralizado com tudo documentado
- Elimina o problema de "esqueci o que fiz no primeiro trimestre"

### Informações a Capturar por Projeto
- Nome do projeto
- Período (início/fim)
- Descrição e escopo
- Soluções implementadas (tecnologias, abordagens)
- Valor de negócio / impacto
- Stakeholders envolvidos
- Métricas de sucesso (se aplicável)
- Categoria (Power BI, Python, Automação, etc.)

### Funcionalidades Planejadas
- Comando para registrar novo projeto concluído
- Listagem por período (ano, trimestre, mês)
- Geração automática de resumo para Performance Review
- Exportação em formato adequado para o review
- Estatísticas: quantidade de projetos, distribuição por categoria, etc.

### Nota do Jimmy
> "Tem um nome pra isso haha, mas não me lembro" — possivelmente referindo-se a "Brag Document" ou "Work Log" ou "Achievement Tracker", conceitos comuns em tech para documentar realizações profissionais.

## Key Details
- Deve se integrar ao ecossistema de skills existente (claude-intelligence-hub)
- O registro deve ser simples via linguagem natural: "Xavier, registra que concluímos o projeto X com detalhes Y Z"
- A geração do resumo para Performance Review deve ser automatizada
- Importante manter rastreabilidade temporal (quando cada projeto foi feito)

## Next Steps
- [ ] Definir estrutura da skill (nome, arquivos, templates)
- [ ] Definir schema/template para registro de projetos
- [ ] Planejar comandos e triggers
- [ ] Discutir com Jimmy os campos obrigatórios vs opcionais
- [ ] Prototipar primeira versão
- [ ] Integrar com jimmy-core-preferences (trigger de registro)

## References
- Related: jimmy-core-preferences (para triggers de registro)
- Related: session-memoria (modelo de referência para a arquitetura)
- Related entry: [[2026-02-10-002]] (outra skill planejada - BigQuery import)

---
**Recorded by:** Xavier
**Session duration:** ~120 minutes
**Entry size:** 320 words
