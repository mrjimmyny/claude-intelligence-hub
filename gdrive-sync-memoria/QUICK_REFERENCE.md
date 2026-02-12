# Google Drive Sync - Quick Reference

**Para Jimmy: Como acionar o sync sem atrito**

## Comandos naturais que funcionam:

```
Xavier, sincroniza o Google Drive
X, sincroniza Google Drive
Sincroniza o Google Drive
Processa arquivos do ChatLLM
Importa os resumos do Google Drive
```

## Script direto (alternativa):

```bash
cd claude-intelligence-hub
bash gdrive-sync-memoria/sync-gdrive.sh
```

## O que Xavier deve fazer (automaticamente):

1. ✅ Ler `gdrive-sync-memoria/SKILL.md`
2. ✅ Listar arquivos em Google Drive (`_tobe_registered`)
3. ✅ Download → Parse → Criar entry → Atualizar índices
4. ✅ Git commit + push
5. ✅ Mover arquivos para `_registered_claude_session_memoria`
6. ✅ Mostrar resumo

## O que Xavier NÃO deve fazer:

- ❌ Perguntar se quer instalar Google Drive Desktop
- ❌ Verificar se rclone está instalado
- ❌ Sugerir configuração - TUDO já está pronto
- ❌ Pedir confirmação para iniciar

## Defesas implementadas (zero atrito):

1. **MEMORY.md**: Triggers e padrões documentados
2. **sync-gdrive.sh**: Script wrapper para execução direta
3. **Skill registrado**: ~/.claude/skills/user/gdrive-sync-memoria
4. **Antipadrões documentados**: Erros comuns catalogados

## Troubleshooting (se algo der errado):

```bash
# Verificar se skill está linkado
ls -la ~/.claude/skills/user/ | grep gdrive

# Verificar remote rclone
rclone listremotes

# Executar script diretamente
bash gdrive-sync-memoria/sync-gdrive.sh

# Forçar Xavier a ler memória
"Xavier, consulta MEMORY.md antes de responder"
```

## Última atualização

**Data:** 2026-02-12
**Status:** ✅ Todas as defesas implementadas
**Próximo sync esperado:** 2026-02-15

---

*Sistema de defesa em profundidade contra atrito desnecessário*
