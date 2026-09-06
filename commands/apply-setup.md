---
description: Applique les préférences Claude Code d'Anthony (CLAUDE.md global, settings, status line, output style)
allowed-tools: Read, Edit, Write, Bash
---

Tu configures le poste. Applique les préférences ci-dessous, **une étape à la fois**, en
montrant un diff avant chaque écriture et en demandant confirmation. Ne touche à rien
d'autre dans `~/.claude/`.

Les fichiers source sont dans `${CLAUDE_PLUGIN_ROOT}/reference/`.

## Étape 1 — `~/.claude/CLAUDE.md`

Lis `${CLAUDE_PLUGIN_ROOT}/reference/global-CLAUDE.md`.

- Si `~/.claude/CLAUDE.md` n'existe pas → l'écrire tel quel.
- S'il existe → montrer un diff. Par défaut **remplacer**. Si l'utilisateur a des ajouts
  perso à garder, fusionner en gardant la structure du fichier source.

## Étape 2 — `~/.claude/settings.json`

Lis `${CLAUDE_PLUGIN_ROOT}/reference/settings.json`.

- Merge les clés dans `~/.claude/settings.json` **sans écraser** les clés déjà présentes
  que l'utilisateur aurait réglées autrement (`theme`, `effortLevel`…). En cas de conflit,
  demander.
- Ne PAS ajouter `permissions.defaultMode: "bypassPermissions"` ni
  `skipDangerousModePermissionPrompt` — ils ne sont volontairement pas dans le fichier source.

## Étape 3 — Status line

- Écris `${CLAUDE_PLUGIN_ROOT}/reference/statusline.sh` dans `~/.claude/statusline.sh`.
- `chmod +x ~/.claude/statusline.sh`.
- Vérifie que le bloc `statusLine` de l'étape 2 pointe bien sur `~/.claude/statusline.sh`.

## Étape 4 — Output style (optionnel, demander)

- Écris `${CLAUDE_PLUGIN_ROOT}/reference/emoji-stylish.md` dans
  `~/.claude/output-styles/emoji-stylish.md` (créer le dossier si besoin).
- L'activation se fait par `"outputStyle": "emoji-stylish"` dans `~/.claude/settings.json`
  (déjà dans le fichier source de l'étape 2).

## Étape 5 — Rappels à afficher (ne rien exécuter)

```
Skills à installer (hors de cette commande) :
  claude plugin marketplace add mattpocock/skills
  claude plugin install mattpocock-skills@mattpocock
  claude plugin marketplace add anthropics/claude-plugins-community
Puis, une fois par repo :  /setup-matt-pocock-skills
Marketplace officielle : voir reference/ du repo anthony-setup pour la liste (security-guidance, typescript-lsp…).

Redémarre Claude Code pour la status line et l'output style.
Permissions par repo : copier reference/settings.local.example.json vers .claude/settings.local.json du repo, adapter.
```
