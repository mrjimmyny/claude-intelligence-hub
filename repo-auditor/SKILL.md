---
name: repo-auditor
version: 1.0.0
scope: global
owner: jimmy
hub: claude-intelligence-hub
integrations:
  - context-guardian
---

# Repo Auditor

Skill global de auditoria end-to-end do repositório `claude-intelligence-hub`.
Garante que toda documentação, skills e metadados estão atualizados, com
**prova obrigatória** de cada arquivo lido — sem afirmações sem evidência.

---

## Trigger Automático

Esta skill é acionada sempre que o agente receber:

- `"audit"`, `"repo audit"`, `"run audit"`, ou `"repo-auditor"`
- Qualquer menção a "documentação desatualizada" ou "release pendente"
- Explicitamente: `@repo-auditor`

**Não é necessário informar versão ou release.** O agente detecta automaticamente
o delta desde a última auditoria via `AUDIT_TRAIL.md` e `git log`.

---

## Protocolo End-to-End (Não Negociável)

### FASE 0 — Contrato de Escopo

Antes de qualquer ação, o agente DEVE:

1. Rodar o comando abaixo e registrar o output COMPLETO:
   ```bash
   find . -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.ps1" \
     | grep -v ".git" | grep -v "AUDIT_TRAIL" | sort
   ```

2. Declarar o total: `"Escopo desta auditoria: X arquivos"`

3. Verificar se existe auditoria anterior em `AUDIT_TRAIL.md`:
   ```bash
   head -30 AUDIT_TRAIL.md 2>/dev/null || echo "PRIMEIRA AUDITORIA"
   ```

4. Se existir auditoria anterior, identificar delta:
   ```bash
   git log --oneline --since="$(grep 'date:' AUDIT_TRAIL.md | head -1 | awk '{print $2}')"
   ```

5. **Registrar o início da auditoria em `AUDIT_TRAIL.md`** (ver template abaixo)
   antes de tocar em qualquer outro arquivo.

> ⚠️ Se o agente não completar a Fase 0 com output real dos comandos,
> a auditoria está inválida e deve ser reiniciada.

---

### FASE 1 — Auditoria por Skill/Pasta

Para **cada pasta** no escopo, o agente executa o seguinte ciclo:

#### 1.1 — Leitura com Fingerprint

Para cada arquivo da pasta:

```
OBRIGATÓRIO: usar tool call `view` — não assumir conteúdo
```

Após cada `view`, registrar imediatamente no AUDIT_TRAIL:

```markdown
### FILE: [caminho/arquivo.md]
- total_lines: [N]
- first_line: "[conteúdo exato da linha 1]"
- last_line: "[conteúdo exato da última linha]"
- issues_found: [lista ou "NONE"]
- action_taken: [descrição ou "NO CHANGE"]
- post_action_verified: [YES/NO]
```

O fingerprint (total_lines + first_line + last_line) é verificável a qualquer momento:
```bash
wc -l [arquivo] && head -1 [arquivo] && tail -1 [arquivo]
```

Se o fingerprint não bater com o arquivo real → **prova de afirmação falsa**.

#### 1.2 — O Que Verificar em Cada Arquivo

| Tipo | Verificar |
|---|---|
| `SKILL.md` | version, description, triggers, exemplos, sem TODO/placeholder |
| `README.md` | versão, links funcionais, exemplos relevantes, sem "coming soon" |
| `GOVERNANCE.md` | políticas ainda válidas, sem referências a sistemas obsoletos |
| `CHANGELOG.md` | entrada mais recente no topo, datas em ordem, formato correto |
| `*.sh` | shebang presente, comentário de header, permissões executáveis |
| `*.json` | JSON válido, campos obrigatórios preenchidos |
| `*.ps1` | sintaxe válida, comentário de header |
| `README.md` (root) | reflete estado atual do hub, links para todas as skills ativas |

#### 1.3 — Proibições Absolutas

```
❌ NÃO escrever "Arquivo verificado" sem tool call anterior
❌ NÃO marcar ✅ sem registrar fingerprint
❌ NÃO avançar para próxima fase com itens pendentes da atual
❌ NÃO assumir que arquivo está correto sem ler
❌ NÃO usar "aparentemente", "provavelmente", "deve estar"
```

---

### FASE 2 — Spot-Check Aleatório por Fase

Ao concluir cada fase (cada pasta/skill), ANTES de avançar:

```bash
# Pegar 3 arquivos aleatórios da fase recém-concluída
shuf -n 3 -e [lista dos arquivos da fase]
```

Para cada arquivo selecionado:
1. Re-ler com `view` (nova tool call — não cache)
2. Tentar **ativamente encontrar problemas** (adversarial, não confirmatório)
3. Registrar resultado: `SPOT-CHECK: CLEAN` ou `SPOT-CHECK: ISSUE FOUND → [correção]`

Se spot-check encontrar issue → corrigir, registrar, e rodar spot-check novamente
naquele arquivo antes de continuar.

---

### FASE 3 — Encerramento com Validação

Após todas as fases:

#### 3.1 — Contagem de Fechamento

```bash
# Contar arquivos auditados no AUDIT_TRAIL
grep -c "^### FILE:" AUDIT_TRAIL.md
```

Comparar com total declarado na Fase 0.

**Se divergir → BLOQUEADO.** O agente não pode declarar auditoria completa
enquanto o número não fechar. Deve identificar quais arquivos faltam e auditá-los.

#### 3.2 — Spot-Check Global

```bash
# 5 arquivos aleatórios de qualquer fase
find . -name "*.md" | grep -v ".git" | grep -v "AUDIT_TRAIL" | shuf -n 5
```

Mesma lógica do spot-check por fase — adversarial, nova tool call, registrado.

#### 3.3 — Validação via Script

```bash
bash scripts/validate-trail.sh
```

Deve retornar `AUDIT VALID` para prosseguir.

#### 3.4 — Fechamento no AUDIT_TRAIL

Registrar:
```markdown
## AUDIT COMPLETE
- date_end: YYYY-MM-DD HH:MM
- files_in_scope: X
- files_audited: X
- files_changed: N
- spot_checks_run: N
- spot_checks_issues_found: N
- validate_trail_result: VALID
- release_created: vX.Y.Z (ou N/A)
- backed_up_by: context-guardian (timestamp)
```

#### 3.5 — Integração com Context-Guardian

```bash
bash context-guardian/scripts/backup-project.sh
```

O AUDIT_TRAIL.md deve ser incluído no backup como arquivo crítico.
Verificar que o backup capturou o trail:
```bash
rclone ls gdrive-jimmy:Claude/_claude_intelligence_hub/... | grep AUDIT_TRAIL
```

---

## Template de Entrada no AUDIT_TRAIL.md

```markdown
---

## AUDIT SESSION: [YYYY-MM-DD HH:MM]
- triggered_by: [usuário/automático]
- previous_audit: [data da última ou "PRIMEIRA AUDITORIA"]
- delta_since_last: [N commits / "FULL AUDIT"]
- files_in_scope: [N]
- agent: [Magneto/Xavier]

### SCOPE DECLARATION
[output completo do find aqui]

---

### FILE: [caminho]
- total_lines: [N]
- first_line: "[texto]"
- last_line: "[texto]"
- issues_found: [lista ou NONE]
- action_taken: [descrição ou NO CHANGE]
- post_action_verified: YES

[... repetir para cada arquivo ...]

---

### SPOT-CHECK LOG
- [arquivo]: CLEAN
- [arquivo]: ISSUE FOUND → [correção aplicada] → RE-CHECK: CLEAN

---

### PHASE SUMMARY: [nome da fase]
- files_covered: N
- changes_made: N
- spot_checks: N/N clean

---

## AUDIT COMPLETE
[campos de fechamento conforme Fase 3.4]
```

---

## Regra de Ouro

> Se não está no AUDIT_TRAIL com fingerprint real, não foi auditado.
> Se não foi auditado, não pode ser declarado como atualizado.
> Se o validate-trail.sh falhar, a auditoria não existe.

Não há exceção a essa regra.
