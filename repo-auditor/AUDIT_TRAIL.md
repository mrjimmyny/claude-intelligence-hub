# AUDIT_TRAIL.md
# claude-intelligence-hub — Histórico Acumulativo de Auditorias
#
# REGRA: Novas sessões são ADICIONADAS NO TOPO (mais recente primeiro).
# Este arquivo nunca é sobrescrito — apenas cresce.
# É arquivo crítico: deve ser incluído em todo backup do context-guardian.
# ============================================================

---

## AUDIT SESSION: [YYYY-MM-DD HH:MM]
- triggered_by: [usuário/automático]
- agent: [Magneto/Xavier]
- previous_audit: [data da sessão anterior ou "PRIMEIRA AUDITORIA"]
- delta_since_last: [N commits desde última auditoria / "FULL AUDIT"]
- files_in_scope: [N]

### SCOPE DECLARATION
```
[output completo do find . -name "*.md" -o -name "*.sh" ... | sort]
```

---

### FILE: [caminho/relativo/ao/arquivo.md]
- total_lines: [N]
- first_line: "[conteúdo exato da linha 1]"
- last_line: "[conteúdo exato da última linha não-vazia]"
- issues_found: [lista de problemas ou NONE]
- action_taken: [descrição da mudança ou NO CHANGE]
- post_action_verified: YES

### FILE: [próximo arquivo...]
- total_lines: [N]
- first_line: "[...]"
- last_line: "[...]"
- issues_found: NONE
- action_taken: NO CHANGE
- post_action_verified: YES

---

### SPOT-CHECK LOG — [nome da fase]
- [caminho/arquivo.md]: CLEAN
- [caminho/arquivo.md]: ISSUE FOUND → [descrição] → FIXED → RE-CHECK: CLEAN
- [caminho/arquivo.md]: CLEAN

---

### PHASE SUMMARY: [nome da fase / pasta auditada]
- files_covered: N
- changes_made: N
- spot_checks_run: N
- spot_checks_issues: N

---

### SPOT-CHECK GLOBAL (pré-encerramento)
```bash
# Comando rodado:
find . -name "*.md" | grep -v ".git" | grep -v "AUDIT_TRAIL" | shuf -n 5
# Output:
[arquivo 1]
[arquivo 2]
[arquivo 3]
[arquivo 4]
[arquivo 5]
```
- [arquivo 1]: CLEAN
- [arquivo 2]: CLEAN
- [arquivo 3]: ISSUE FOUND → [descrição] → FIXED → RE-CHECK: CLEAN
- [arquivo 4]: CLEAN
- [arquivo 5]: CLEAN

---

## AUDIT COMPLETE
- date_start: YYYY-MM-DD HH:MM
- date_end: YYYY-MM-DD HH:MM
- files_in_scope: N
- files_audited: N
- files_changed: N
- spot_checks_run: N
- spot_checks_issues_found: N
- validate_trail_result: PENDING
- release_created: vX.Y.Z (ou N/A)
- backed_up_by: context-guardian YYYY-MM-DD HH:MM

---
<!-- ↑ Sessões anteriores ficam abaixo desta linha ↑ -->
<!-- ============================================================ -->
