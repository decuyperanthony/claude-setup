# claude-setup — ma trousse Claude Code

Repo privé de transport. Objectif : reprendre **mes préférences de craft + mes skills**
sur un nouveau poste **par copier-coller**, sans rien télécharger ni cloner.

Contenu = uniquement des préférences personnelles génériques (style de code, workflow,
sécurité de base) et des pointeurs vers des skills publics. Rien de spécifique à un
employeur, un projet ou un client.

## Comment s'en servir (2 options)

**Option A — tu files ce fichier à ton Claude Code.**
Ouvre Claude Code dans ton repo de travail, colle **tout ce README** et dis :

> « Applique ce setup. Fais les étapes §1 à §4 une par une, montre-moi chaque diff avant d'écrire. »

**Option B — manuel.**
Copie chaque bloc marqué 📋 dans le fichier indiqué. Les fichiers sont aussi dans ce repo
en version brute : [`CLAUDE.md`](./CLAUDE.md), [`settings.json`](./settings.json),
[`settings.local.example.json`](./settings.local.example.json),
[`output-styles/emoji-stylish.md`](./output-styles/emoji-stylish.md).

---

## §0 — Instructions pour le Claude qui lit ce fichier

Tu configures un nouveau poste de dev. Fais, dans l'ordre, en confirmant chaque étape :

1. **§1** — écris le bloc dans `~/.claude/CLAUDE.md` (préférences globales, tous projets).
   S'il existe déjà, montre un diff et demande avant d'écraser.
2. **§2** — installe les plugins de skills (commandes `claude plugin ...`).
3. **§3** — merge le bloc dans `~/.claude/settings.json` (ne pas écraser des clés existantes sans le dire).
4. **§4** _(optionnel)_ — écris l'output style `~/.claude/output-styles/emoji-stylish.md`.
5. Rappelle-moi : `settings.local.json` est **par repo** — voir §5, à adapter, ne pas
   activer `bypassPermissions` sans accord de l'organisation.

Ne touche à **rien d'autre** dans `~/.claude/` (credentials, historique, sessions).

---

## §1 — 📋 `~/.claude/CLAUDE.md` (préférences globales)

````markdown
# CLAUDE.md — Préférences Anthony

Préférences perso appliquées à **tous les projets**. Les règles spécifiques à un
repo vivent dans le `./CLAUDE.md` de ce repo et priment sur ce fichier.

## Langue

- Code / commentaires / commits / PR / docs → **anglais**
- Conversation directe avec moi → **français**

## Plan avant code (Shift+Tab x2)

**Toujours planifier avant de coder. Ne jamais coder avant que je valide le plan.**

Format du plan :

```
## Objectif
[une phrase]

## Étapes
1. [Fichier] - [Action] - [Détails]
2. ...

## Questions (si besoin)
- ...
```

Règles : concis (quitte à sacrifier la grammaire), étapes atomiques (1 étape = 1 commit),
toujours les chemins de fichiers + noms de fonctions.

## Carte de référence rapide

| Sujet     | ❌ Jamais                                        | ✅ Toujours                                                              |
| --------- | ----------------------------------------------- | -------------------------------------------------------------------- |
| Typage    | `any`, `as`, `as unknown as`, `!`, `@ts-ignore` | Zod aux frontières, type guards, génériques, `?.` / `??`             |
| Fonctions | mot-clé `function`                              | arrow functions                                                     |
| Types     | `interface`                                     | `type`                                                              |
| Params    | 3+ positionnels, flags booléens                 | objet d'options, noms explicites (`activateUser` pas `update(id, true)`) |
| Imports   | `import * as X` / namespace                     | imports nommés (`import { useState } from "react"`)                 |
| Mutation  | `.push()`, `.sort()` sur l'original             | spread, `.toSorted()`, `.toReversed()`                              |
| Erreurs   | `throw new Error()` brut                        | classes d'erreur dédiées, `Result<T, E>`                           |
| Secrets   | en dur                                          | `process.env.X` avec throw si absent                                |
| Input     | faire confiance au client                       | validation Zod côté serveur                                         |

## Stack front (React + Vite)

- **React + Vite** (SPA) — pas de Next, pas d'App Router.
- **Formulaires** : React Hook Form + `@hookform/resolvers/zod`. Un schéma Zod = source
  de vérité, les types viennent de `z.infer`. Jamais de state de formulaire tenu à la main.
- **UI** : shadcn/ui (primitives Radix + Tailwind). On **compose** les composants shadcn,
  on ne les fork pas. Variantes via `cva`, fusion de classes via `cn()`.
- **Champs** : pattern `<Form>` / `<FormField>` / `<FormControl>` de shadcn ; chaque input
  a un `<FormLabel>`.
- **Styling** : Tailwind utility-first. Pas d'objet `style` inline. Listes de classes
  répétées → `cva` ou un composant dédié.
- **Accessibilité** : garder la sémantique et les rôles ARIA fournis par Radix, ne pas les casser.
- **Data fetching** (si présent dans le repo) : TanStack Query — clés de cache typées,
  jamais de `fetch` dans un `useEffect` à la main.
- **State** : privilégier le state dérivé + le state dans l'URL. Zustand / context seulement
  quand c'est réellement partagé et transverse.

## Sécurité — non négociable

1. Jamais de secret en dur — variables d'environnement uniquement.
2. Jamais faire confiance à l'input client — valider **côté serveur** avec Zod.
3. Jamais exposer une erreur interne au client — logguer en interne, renvoyer un message générique.
4. Toujours assainir le contenu utilisateur (XSS) — éviter `dangerouslySetInnerHTML` ;
   si inévitable, passer par `DOMPurify`.
5. Toujours des requêtes paramétrées (injection SQL).

Ne jamais committer : `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account.json`.

## Commits & PR

- **Conventional commits** en anglais : `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`, `perf:`.
- **Ne JAMAIS** ajouter « Co-Authored-By: Claude », « Generated with Claude Code » ou toute
  attribution IA. _(Vérifier d'abord la politique de la boîte — certaines l'imposent.)_
- Labels de review PR : `praise` / `nitpick` / `suggestion` / `issue` (bloquant) / `todo` (bloquant).

## Défauts

- TypeScript strict, zéro `any`, zéro `as`.
- Gestionnaire de paquets : **détecter via le lockfile** (`pnpm-lock.yaml` → pnpm,
  `package-lock.json` → npm, `yarn.lock` → yarn). Ne pas imposer pnpm si le repo utilise autre chose.
- En cas de doute → demander avant de créer des fichiers, des abstractions ou de nouveaux patterns.
````

---

## §2 — 📋 Skills à installer

Une seule famille à installer (le reste est natif à Claude Code) :

```bash
# Skills d'ingénierie de Matt Pocock (code-review, tdd, diagnosing-bugs, etc.)
claude plugin marketplace add mattpocock/skills
claude plugin install mattpocock-skills@mattpocock

# (optionnel) marketplace officielle Anthropic
claude plugin marketplace add anthropics/claude-plugins-official
```

Vérifie : `claude plugin list` doit montrer `mattpocock-skills@mattpocock` activé.

### Ce que j'utilise et quand

**Depuis `mattpocock-skills` :**

| Skill                        | Quand l'appeler                                                                                           |
| ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| `code-review`                | Avant un merge / sur une PR. Review 2 axes en parallèle : **Standards** (conventions repo) + **Spec** (le code fait ce que le ticket demande), + 12 code smells de Fowler. **Mon préféré.** |
| `diagnosing-bugs`            | Bug dur ou régression de perf. Boucle : repro → minimise → hypothèse → instrumente → fix → test de non-régression. |
| `tdd`                        | Nouvelle feature / fix en test-first. Red → green → refactor.                                            |
| `codebase-design`           | Concevoir ou améliorer l'interface d'un module (deep modules, où placer un seam, rendre testable).       |
| `domain-modeling`            | Figer le vocabulaire métier (ubiquitous language), écrire un ADR.                                        |
| `grilling` / `grill-with-docs` | Stress-tester un plan / une décision avant de coder — il me cuisine jusqu'à ce que ça tienne.        |
| `resolving-merge-conflicts`  | Résoudre un merge / rebase en cours proprement.                                                         |
| `research`                   | Sous-agent en background qui investigue une question contre des sources fiables et produit un `.md` dans le repo. |
| `to-spec` / `to-tickets`     | Transformer un PRD en spec implémentable / en tickets découpés.                                          |
| `triage`                     | Triage de bugs prod.                                                                                    |
| `prototype`                  | Prototype jetable pour valider un modèle d'état ou une UI avant de s'engager.                            |
| `implement`                  | Exécuter une spec existante proprement.                                                                  |
| `wayfinder`                  | S'orienter vite dans une base de code inconnue.                                                          |
| `handoff`                    | Compacter la conversation en doc de passation. _(déjà en place)_                                         |
| `improve-codebase-architecture` | Trouver des opportunités de refacto / consolidation. _(déjà en place)_                               |
| `teach`                      | Explication pédagogique d'un bout de code / concept.                                                     |
| `writing-great-skills`       | Quand j'écris mes propres skills.                                                                        |

**Natifs Claude Code (rien à installer) :**

| Commande / skill   | Usage                                                                       |
| ------------------ | ------------------------------------------------------------------------- |
| `/code-review`     | Review du diff courant (ou d'une PR / branche), effort réglable low→ultra. |
| `/security-review` | Revue sécu des changements de la branche.                                  |
| `diagnose`         | Version native de la boucle de debug.                                     |
| `/init`            | Générer un `CLAUDE.md` de repo au premier passage sur un projet.          |

---

## §3 — 📋 `~/.claude/settings.json` (merge, n'écrase pas)

```json
{
  "effortLevel": "high",
  "theme": "dark",
  "enabledPlugins": {
    "mattpocock-skills@mattpocock": true
  },
  "extraKnownMarketplaces": {
    "mattpocock": {
      "source": { "source": "github", "repo": "mattpocock/skills" }
    }
  }
}
```

> Volontairement **sans** `bypassPermissions` / `skipDangerousModePermissionPrompt` :
> à activer seulement si la politique du poste le permet.

---

## §4 — 📋 (optionnel) Output style « Emoji Stylé »

Fichier `~/.claude/output-styles/emoji-stylish.md` — voir
[`output-styles/emoji-stylish.md`](./output-styles/emoji-stylish.md) dans ce repo.
Activation : `/output-style` puis choisir « Emoji Stylé ».

---

## §5 — Permissions par repo (`.claude/settings.local.json`)

Se configure **dans chaque repo**, pas en global. Point de départ raisonnable
(read-only + workflow dev courant) dans
[`settings.local.example.json`](./settings.local.example.json). À copier vers
`.claude/settings.local.json` du repo puis élaguer / compléter au fil de l'eau.

---

## §6 — Approche alternative (plus moderne, zéro copier-coller)

Ce qui a bougé : la façon recommandée aujourd'hui de transporter une config Claude Code,
c'est un **marketplace de plugins**, pas des fichiers baladés à la main.

`claude plugin marketplace add <owner>/<repo>` récupère le repo **via l'API GitHub, sans
`git clone`** — donc ça marche même sur un poste où `git clone` / `git pull` sont bloqués,
tant que github.com est joignable.

Piste si tu veux industrialiser plus tard :

1. Ajouter à ce repo un `.claude-plugin/marketplace.json` + un dossier `plugins/<mon-plugin>/`
   avec `commands/`, `skills/`, éventuellement `hooks/`.
2. Sur le nouveau poste :
   ```bash
   claude plugin marketplace add decuyperanthony/claude-setup
   claude plugin install mon-plugin@claude-setup
   ```
3. Seul `~/.claude/CLAUDE.md` (§1) reste à coller à la main — un plugin ne peut pas écrire
   les préférences globales.

Pour l'instant tes seuls skills persos sont des skills **tiers** (Matt Pocock + quelques
autres). Rien d'assez perso à empaqueter → le fichier unique de ce repo suffit. À refaire
le jour où tu auras écrit tes propres commandes / skills.

### ⚠️ Postes verrouillés

Une organisation stricte peut poser un `managed-settings.json`
(`/Library/Application Support/ClaudeCode/managed-settings.json` sur macOS) qui **prime sur
`~/.claude/settings.json`** et peut interdire l'ajout de marketplaces ou de plugins. Si
`claude plugin marketplace add` échoue, c'est probablement ça → voir avec l'IT, ne pas
contourner.

---

## Ce qui n'est PAS dans ce repo (volontairement)

- Aucun code, doc, nom de projet, de client ou d'employeur — que des préférences de craft génériques.
- Aucun secret : pas de `.credentials.json`, pas d'historique de conversations, pas de sessions.
- `settings.local.json` réel (chemins perso, allowlist accumulée) — seul un exemple élagué est fourni.
- `statusline.sh` (dépend de chemins perso) — à recréer à part si besoin.
