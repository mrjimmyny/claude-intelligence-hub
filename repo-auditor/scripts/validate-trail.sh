#!/bin/bash
# ============================================================
# validate-trail.sh
# repo-auditor — Script de Validação do AUDIT_TRAIL
#
# Compara o escopo declarado na Fase 0 com os arquivos
# efetivamente auditados (entries ### FILE: no trail).
# Retorna exit 0 (VALID) ou exit 1 (INVALID) para uso em CI.
# ============================================================

set -euo pipefail

TRAIL_FILE="AUDIT_TRAIL.md"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "=================================================="
echo "  REPO-AUDITOR — validate-trail.sh"
echo "=================================================="
echo ""

# ── 1. Verificar existência do AUDIT_TRAIL ──────────────────
if [ ! -f "$TRAIL_FILE" ]; then
  echo -e "${RED}✗ AUDIT_TRAIL.md não encontrado em: $REPO_ROOT${NC}"
  echo -e "${RED}  Rode a auditoria antes de validar.${NC}"
  exit 1
fi

echo -e "${BLUE}Trail encontrado:${NC} $TRAIL_FILE"
echo ""

# ── 2. Extrair dados da sessão mais recente ─────────────────
LAST_SESSION=$(grep -n "^## AUDIT SESSION:" "$TRAIL_FILE" | head -1 | cut -d: -f1)
if [ -z "$LAST_SESSION" ]; then
  echo -e "${RED}✗ Nenhuma sessão de auditoria encontrada no trail.${NC}"
  exit 1
fi

SESSION_DATE=$(grep "^## AUDIT SESSION:" "$TRAIL_FILE" | head -1 | sed 's/## AUDIT SESSION: //')
echo -e "${BLUE}Sessão mais recente:${NC} $SESSION_DATE"

# ── 3. Extrair files_in_scope declarado ────────────────────
DECLARED_SCOPE=$(grep "^- files_in_scope:" "$TRAIL_FILE" | head -1 | awk '{print $2}')
if [ -z "$DECLARED_SCOPE" ] || [ "$DECLARED_SCOPE" = "N" ]; then
  echo -e "${YELLOW}⚠ files_in_scope não declarado ou não numérico.${NC}"
  echo -e "${YELLOW}  A Fase 0 foi completada corretamente?${NC}"
  DECLARED_SCOPE=0
fi

echo -e "${BLUE}Escopo declarado (Fase 0):${NC} $DECLARED_SCOPE arquivos"

# ── 4. Contar entries FILE no trail ────────────────────────
AUDITED_COUNT=$(grep -c "^### FILE:" "$TRAIL_FILE" 2>/dev/null || echo 0)
echo -e "${BLUE}Arquivos com entry no trail:${NC} $AUDITED_COUNT"

# ── 5. Gerar lista real de arquivos auditáveis ─────────────
REAL_FILES=$(find "$REPO_ROOT" \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.ps1" \) \
  | grep -v "\.git" \
  | grep -v "AUDIT_TRAIL" \
  | grep -v "node_modules" \
  | sort)

REAL_COUNT=$(echo "$REAL_FILES" | grep -c . 2>/dev/null || echo 0)
echo -e "${BLUE}Arquivos auditáveis no repo agora:${NC} $REAL_COUNT"
echo ""

# ── 6. Extrair arquivos declarados no trail ────────────────
TRAIL_FILES=$(grep "^### FILE:" "$TRAIL_FILE" | sed 's/### FILE: //' | sort)

# ── 7. Verificar divergências ──────────────────────────────
echo "── VERIFICAÇÕES ──────────────────────────────────"
ERRORS=0
WARNINGS=0

# 7a. Escopo declarado vs. auditados no trail
if [ "$DECLARED_SCOPE" -ne "$AUDITED_COUNT" ] 2>/dev/null; then
  echo -e "${RED}✗ DIVERGÊNCIA: Escopo declarado ($DECLARED_SCOPE) ≠ Auditados no trail ($AUDITED_COUNT)${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✓ Escopo declarado bate com entries no trail ($AUDITED_COUNT)${NC}"
fi

# 7b. Verificar se AUDIT COMPLETE existe
if grep -q "^## AUDIT COMPLETE" "$TRAIL_FILE"; then
  echo -e "${GREEN}✓ Seção AUDIT COMPLETE encontrada${NC}"
else
  echo -e "${RED}✗ Seção AUDIT COMPLETE ausente — auditoria não foi encerrada${NC}"
  ERRORS=$((ERRORS + 1))
fi

# 7c. Verificar se validate_trail_result está preenchido
TRAIL_RESULT=$(grep "^- validate_trail_result:" "$TRAIL_FILE" | head -1 | awk '{print $2}')
if [ "$TRAIL_RESULT" = "VALID" ]; then
  echo -e "${GREEN}✓ validate_trail_result: VALID${NC}"
elif [ "$TRAIL_RESULT" = "PENDING" ] || [ -z "$TRAIL_RESULT" ]; then
  echo -e "${YELLOW}⚠ validate_trail_result ainda PENDING (normal se rodando agora)${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${RED}✗ validate_trail_result: $TRAIL_RESULT${NC}"
  ERRORS=$((ERRORS + 1))
fi

# 7d. Verificar spot-checks obrigatórios
SPOTCHECK_COUNT=$(grep -c "^- \[.*\]: \(CLEAN\|ISSUE\)" "$TRAIL_FILE" 2>/dev/null || echo 0)
if [ "$SPOTCHECK_COUNT" -ge 5 ]; then
  echo -e "${GREEN}✓ Spot-checks registrados: $SPOTCHECK_COUNT${NC}"
elif [ "$SPOTCHECK_COUNT" -gt 0 ]; then
  echo -e "${YELLOW}⚠ Spot-checks registrados: $SPOTCHECK_COUNT (mínimo esperado: 5 no global)${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${RED}✗ Nenhum spot-check registrado no trail${NC}"
  ERRORS=$((ERRORS + 1))
fi

# 7e. Verificar fingerprints — todas as entries devem ter total_lines
ENTRIES_WITH_FINGERPRINT=$(grep -c "^- total_lines:" "$TRAIL_FILE" 2>/dev/null || echo 0)
if [ "$ENTRIES_WITH_FINGERPRINT" -eq "$AUDITED_COUNT" ]; then
  echo -e "${GREEN}✓ Fingerprints presentes em todas as entries ($AUDITED_COUNT)${NC}"
elif [ "$ENTRIES_WITH_FINGERPRINT" -gt 0 ]; then
  MISSING=$((AUDITED_COUNT - ENTRIES_WITH_FINGERPRINT))
  echo -e "${RED}✗ $MISSING entries sem fingerprint (total_lines ausente)${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${RED}✗ Nenhum fingerprint encontrado — entries são afirmações sem prova${NC}"
  ERRORS=$((ERRORS + 1))
fi

# 7f. Verificar arquivos novos no repo não cobertos pelo trail
echo ""
echo "── ARQUIVOS NO REPO NÃO COBERTOS PELO TRAIL ──────"
UNCOVERED=0
while IFS= read -r real_file; do
  # Normalizar para path relativo
  rel_file="${real_file#$REPO_ROOT/}"
  if ! echo "$TRAIL_FILES" | grep -qF "$rel_file"; then
    echo -e "${YELLOW}  ⚠ Não coberto: $rel_file${NC}"
    UNCOVERED=$((UNCOVERED + 1))
  fi
done <<< "$REAL_FILES"

if [ "$UNCOVERED" -eq 0 ]; then
  echo -e "${GREEN}  ✓ Todos os arquivos do repo estão cobertos pelo trail${NC}"
else
  echo -e "${YELLOW}  $UNCOVERED arquivo(s) no repo sem entry no trail${NC}"
  if [ "$UNCOVERED" -gt 3 ]; then
    echo -e "${RED}  ✗ Mais de 3 arquivos descobertos — possível auditoria incompleta${NC}"
    ERRORS=$((ERRORS + 1))
  else
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# ── 8. Resultado Final ─────────────────────────────────────
echo ""
echo "=================================================="
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${GREEN}✅ AUDIT VALID${NC}"
  echo -e "   Erros: 0 | Avisos: $WARNINGS"
  echo ""
  # Atualizar validate_trail_result no trail para VALID
  if [ -f "$TRAIL_FILE" ] && grep -q "validate_trail_result: PENDING" "$TRAIL_FILE"; then
    sed -i 's/validate_trail_result: PENDING/validate_trail_result: VALID/' "$TRAIL_FILE"
    echo -e "${GREEN}   Trail atualizado: validate_trail_result = VALID${NC}"
  fi
  echo "=================================================="
  echo ""
  exit 0
else
  echo -e "${RED}❌ AUDIT INVALID${NC}"
  echo -e "   Erros: $ERRORS | Avisos: $WARNINGS"
  echo ""
  echo -e "${RED}   A auditoria NÃO pode ser declarada completa.${NC}"
  echo -e "${RED}   Corrija os erros acima e rode novamente.${NC}"
  echo "=================================================="
  echo ""
  exit 1
fi
