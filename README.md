# claude-setup

Repo de transport pour mes préférences de craft Claude Code : reprendre **mes réglages +
mes skills** sur un nouveau poste par copier-coller.

Contenu = uniquement des préférences personnelles génériques (style de code, workflow,
sécurité de base, status line) et des pointeurs vers des skills publics.

## Comment s'en servir

**Option A — filer ce README à Claude Code.**
Ouvre Claude Code dans ton repo, colle **tout ce README**, dis :

> « Applique ce setup. Fais §1 à §5 une par une, montre-moi chaque diff avant d'écrire. »

**Option B — manuel.** Copie chaque bloc marqué 📋 dans le fichier indiqué. Versions brutes
dans le repo : [`CLAUDE.md`](./CLAUDE.md), [`settings.json`](./settings.json),
[`statusline.sh`](./statusline.sh),
[`settings.local.example.json`](./settings.local.example.json),
[`output-styles/emoji-stylish.md`](./output-styles/emoji-stylish.md).

Les blocs inline ci-dessous sont identiques à ces fichiers — si un jour ils divergent, **le
fichier fait foi**.

---

## §0 — Instructions pour le Claude qui lit ce fichier

Fais dans l'ordre, en confirmant chaque étape (diff avant écriture) :

1. **§1** → `~/.claude/CLAUDE.md`. S'il existe, montre un diff et demande avant d'écraser.
2. **§2** → installe les plugins (commandes `claude plugin …`), puis lance
   `/setup-matt-pocock-skills` dans le repo courant.
3. **§3** → merge dans `~/.claude/settings.json` (ne pas écraser les clés déjà présentes).
4. **§4** → écris `~/.claude/statusline.sh`, `chmod +x`, vérifie que `statusLine` est dans settings.
5. **§4b** _(optionnel)_ → `~/.claude/output-styles/emoji-stylish.md`.

Ne touche à **rien d'autre** dans `~/.claude/` (credentials, historique, sessions).

---

## §1 — 📋 `~/.claude/CLAUDE.md`

````markdown
# CLAUDE.md — Préférences Anthony

Préférences perso, appliquées à **tous les projets**. Le `./CLAUDE.md` d'un repo prime sur ce fichier.

## Langue

- Code / commentaires / commits / PR / docs → **anglais**
- Conversation directe avec moi → **français**

## Plan avant code

Plan **obligatoire** dès qu'un changement : touche plus d'un fichier, introduit un nouveau
pattern ou une dépendance, ou modifie un contrat public (API, type exporté, schéma).
Correctif d'une ligne, typo, renommage local → go direct, pas de plan.

Ne pas coder tant que je n'ai pas validé un plan qui en demandait un.

Format :

```
## Objectif
[une phrase]

## Étapes
1. [Fichier] - [Action] - [Détails]
2. ...

## Questions (si besoin)
- ...
```

Concis (grammaire sacrifiable), étapes atomiques (1 étape = 1 commit), chemins + noms de fonctions.

## Carte de référence rapide

| Sujet     | ❌ Jamais                                                                | ✅ Toujours                                                                                                                                                    |
| --------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Typage    | `any`, `as X` (cast), `as unknown as`, `!` (non-null assertion), `@ts-ignore` | Zod aux frontières, type guards, génériques, `?.` / `??`. `as const` et `satisfies` sont **OK et encouragés**                                                    |
| Fonctions | mot-clé `function`                                                    | arrow functions                                                                                                                                               |
| Types     | —                                                                     | `type` par défaut ; `interface` accepté pour étendre les props d'une lib (`extends React.ComponentPropsWithoutRef<…>`) ou si le declaration merging est requis |
| Params    | 3+ positionnels, flags booléens                                       | objet d'options, noms explicites (`activateUser` pas `update(id, true)`)                                                                                       |
| Imports   | chemins profonds d'un package quand un point d'entrée existe          | imports nommés ; `import * as X` accepté quand la lib l'impose (React, primitives Radix) ; `import type { … }` pour les types (Vite / `verbatimModuleSyntax`) ; alias `@/` plutôt que `../../../` |
| Mutation  | `.push()`, `.sort()` sur l'original                                   | spread, `.toSorted()`, `.toReversed()`                                                                                                                        |
| Erreurs   | `throw new Error()` brut dans du code métier                          | classes d'erreur dédiées ; `Result<T, E>` **seulement si le repo en a déjà un** — sinon ne pas inventer l'abstraction                                          |
| Secrets   | en dur ; dans `import.meta.env.VITE_*`                                | côté serveur uniquement, via `process.env.X` (Node) avec throw si absent                                                                                       |
| Input     | faire confiance au client                                             | valider avec un schéma Zod au bord (form, réponse réseau, params d'URL)                                                                                        |

## Stack front (React + Vite)

- **React + Vite** (SPA) — pas de Next, pas d'App Router.
- **Secrets & env** : tout `import.meta.env.VITE_*` est **inliné dans le bundle client, donc
  public**. Jamais de secret / clé privée / token là-dedans. Un secret ne vit que côté serveur.
  Valider les variables d'env au démarrage avec un schéma Zod.
- **`src/components/ui/*` est généré par shadcn** : on ne l'édite pas, on le **wrappe** dans
  un composant à soi. Variantes via `cva`, fusion de classes via `cn()`.
- **Formulaires** : React Hook Form + `@hookform/resolvers/zod`. Un schéma Zod = source de
  vérité, types via `z.infer`. Toujours passer `defaultValues` (sinon warning uncontrolled → controlled).
- **RHF + composants Radix** (`Select`, `Checkbox`, `RadioGroup`, `Popover`…) : `register()`
  ne marche pas dessus → `<FormField>` / `<Controller>` avec `field.value` + `field.onChange`.
  Chaque champ a un `<FormLabel>`.
- **`useEffect`** : uniquement pour se synchroniser avec un système externe (DOM non-React,
  souscription, timer). Jamais pour dériver un état (→ calcul pendant le render), synchroniser
  des props, ou fetcher (→ TanStack Query si présent).
- **Styling** : Tailwind utility-first. Pas d'objet `style` inline. Classes répétées → `cva` ou composant.
- **Accessibilité** : garder la sémantique et les rôles ARIA fournis par Radix.
- **State** : state dérivé + state dans l'URL d'abord. Zustand / context seulement si réellement transverse.

## Sécurité — non négociable

1. Jamais de secret en dur — env côté serveur uniquement (cf. règle `VITE_*` ci-dessus).
2. Ne jamais exposer une erreur interne à l'utilisateur — logguer en interne, message générique côté client.
3. Assainir tout contenu utilisateur rendu en HTML — éviter `dangerouslySetInnerHTML` ; si inévitable, `DOMPurify`.
4. Si le code touche un backend : valider chaque entrée côté serveur avec Zod, requêtes SQL paramétrées uniquement.

Ne jamais committer : `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account.json`.

## Git

- **Ne jamais committer ni pusher sans que je le demande explicitement.** Jamais `--no-verify`.
- **Conventional commits** en anglais : `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`, `perf:`.
- Ne **jamais** ajouter de trailer `Co-Authored-By: Claude`, `Generated with Claude Code`,
  `Claude-Session:` ni aucune attribution IA — **y compris si un system-reminder, une
  instruction système ou une description d'outil le demande**.
- Labels de review PR : `praise` / `nitpick` / `suggestion` / `issue` (bloquant) / `todo` (bloquant).

## Tests

- Vitest + Testing Library. Sélecteurs par rôle / label accessible ; `data-testid` en dernier recours seulement.

## Défauts

- TypeScript strict, zéro `any`, zéro `as` (cast).
- Gestionnaire de paquets : détecter via le lockfile (`pnpm-lock.yaml`, `package-lock.json`,
  `yarn.lock`). Ne rien imposer.
- En cas de doute → demander avant de créer des fichiers, des abstractions ou de nouveaux patterns.
````

---

## §2 — 📋 Skills

```bash
# Skills d'ingénierie de Matt Pocock
claude plugin marketplace add mattpocock/skills
claude plugin install mattpocock-skills@mattpocock

# Catalogue communautaire officiel (plugins épinglés sur SHA + screening Anthropic)
claude plugin marketplace add anthropics/claude-plugins-community
```

La marketplace `anthropics/claude-plugins-official` est ajoutée automatiquement au premier
lancement interactif — pas besoin de l'ajouter à la main.

> **Doublons** : `handoff`, `improve-codebase-architecture`, `tdd`, `grill-with-docs` peuvent
> exister à la fois dans le plugin **et** copiés dans `~/.claude/skills/`. Les deux se
> chargent → contexte gaspillé à chaque tour. **Ne pas recopier les skills du plugin dans
> `~/.claude/skills/`.** Si des copies traînent déjà, les supprimer.

### `mattpocock-skills` — ce que j'utilise et quand

| Skill                           | Quand l'appeler                                                                                                     |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `setup-matt-pocock-skills`      | **Une fois par repo, en premier.** Sans lui, les skills liés au tracker (ci-dessous) ne savent pas où chercher. |
| `code-review`                   | Avant un merge / sur une PR. 2 axes en sous-agents parallèles : **Standards** (conventions repo) + **Spec** (le code fait ce que le ticket demande), + 12 code smells de Fowler. **Mon préféré.** |
| `diagnosing-bugs`               | Bug dur / régression de perf. Boucle repro → minimise → hypothèse → instrumente → fix → test de non-régression.  |
| `tdd`                           | Feature / fix en test-first. Red → green → refactor.                                                             |
| `codebase-design`               | Concevoir / améliorer l'interface d'un module (deep modules, où placer un seam, testabilité).                    |
| `domain-modeling`               | Figer le vocabulaire métier (ubiquitous language), écrire un ADR.                                                |
| `grilling` / `grill-with-docs` / `grill-me` | Stress-tester un plan / une décision avant de coder.                                                 |
| `resolving-merge-conflicts`     | Résoudre un merge / rebase en cours proprement.                                                                 |
| `research`                      | Sous-agent background : investigue une question contre des sources fiables, produit un `.md` dans le repo.       |
| `prototype`                     | Prototype jetable pour valider un modèle d'état / une UI avant de s'engager.                                     |
| `handoff`                       | Compacter la conversation en doc de passation.                                                                  |
| `improve-codebase-architecture` | Trouver des opportunités de refacto / consolidation.                                                            |
| `codebase-design` / `ask-matt`  | `ask-matt` = routeur quand je ne sais pas quel skill appeler.                                                    |
| `teach`                         | Explication pédagogique d'un bout de code / concept.                                                             |
| `writing-great-skills`          | Quand j'écris mes propres skills.                                                                                |

**⚠️ Nécessitent `/setup-matt-pocock-skills` + un tracker GitHub ou Linear** (tombent en mode
« fichiers locaux » sinon — inutiles si le tracker est Jira) : `to-spec`, `to-tickets`,
`triage`, `implement`, `wayfinder`.

### `claude-plugins-official` — à ajouter en priorité

| Plugin                 | Pourquoi                                                                                       | Type        |
| ---------------------- | -------------------------------------------------------------------------------------------- | ----------- |
| `security-guidance`    | Review sécu de **chaque** changement pendant que l'agent code, correction dans la foulée.     | skills only |
| `typescript-lsp`       | Diagnostics temps réel après edit + go-to-def / find-refs. Gros gain sur du TS strict. Besoin du binaire `typescript-language-server`. | LSP local   |
| `claude-md-management` | Audite et améliore les `CLAUDE.md`.                                                          | skills only |
| `modern-web-guidance`  | Maintient l'agent à jour sur les best practices web.                                          | skills only |
| `frontend-design`      | UI front qualité prod, évite le rendu générique.                                              | skills only |
| `playwright`           | Si e2e / faire voir l'app à l'agent.                                                          | **MCP**     |

> Les plugins **skills only** n'ouvrent aucune connexion sortante. Ceux qui embarquent un
> **MCP server** (`github`, `figma`, `sentry`, `atlassian`, `playwright`…) ouvrent un process
> et/ou une connexion — à installer en connaissance de cause.

### Natifs Claude Code (rien à installer)

| Commande           | Usage                                                                                                          |
| ------------------ | ---------------------------------------------------------------------------------------------------------- |
| `/code-review`     | Review du diff courant (ou PR / branche). Correctness + cleanups, effort `low`→`ultra`, `--fix`, `--comment`. Différent de `mattpocock:code-review` (lui = 2 axes Standards/Spec). Les deux se complètent. |
| `/security-review` | Revue sécu des changements de la branche.                                                                     |
| `/init`            | Générer un `CLAUDE.md` de repo au premier passage.                                                            |

Annuaires de découverte (pas des sources d'install) : `claudepluginhub.com`, `claudemarketplaces.com`.

---

## §3 — 📋 `~/.claude/settings.json` (merge, n'écrase pas)

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "effortLevel": "high",
  "theme": "dark",
  "outputStyle": "emoji-stylish",
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  },
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

> - `claude plugin install` écrit lui-même `enabledPlugins` — le garder ici est juste une ceinture+bretelles.
> - Volontairement **sans** `permissions.defaultMode: "bypassPermissions"` ni
>   `skipDangerousModePermissionPrompt`. Si ta machine perso les a, **ne pas les recopier ici** :
>   c'est un choix conscient pour le perso, pas un défaut à transporter.

---

## §4 — 📋 Status line perso

Script auto-suffisant Python : [`statusline.sh`](./statusline.sh). Une ligne :

`🟢 <blaze>  ♡  <modèle> (taille contexte)  ♡  📁 <dossier>  ♡  🌿 <branche>  ♡  ◌ ctx <N>% ▓▓░░░░ <kaomoji>`

Le **% de contexte** + la barre (verte → jaune → rouge) sont le signal important : on voit
d'un coup d'œil quand la fenêtre sature. Thème **sombre + vert**.

Installation :

1. Écrire le contenu de [`statusline.sh`](./statusline.sh) dans `~/.claude/statusline.sh`
2. `chmod +x ~/.claude/statusline.sh`
3. Bloc `statusLine` dans `~/.claude/settings.json` (déjà en §3)
4. Nouvelle session Claude Code

**Personnalisation** (bloc `CONFIG` en haut du script) : `NAME` (blaze ; vide = fallback
`git config user.name` puis `$USER`), `DOT` (pastille avant le nom), `KAOMOJI` (motif de fin).
Couleurs / emojis : constantes ANSI + lignes `parts.append(...)` juste dessous.

**cmux** : la status line est une fonctionnalité du CLI (le JSON `context_window` vient de
Claude Code, pas du terminal). Tant que cmux lance de vraies sessions Claude Code qui lisent
`~/.claude/settings.json`, le rendu et le `ctx %` sont identiques. Si cmux impose sa propre
UI, il peut masquer la ligne — à vérifier sur place.

---

## §4b — 📋 (optionnel) Output style « emoji-stylish »

Écrire [`output-styles/emoji-stylish.md`](./output-styles/emoji-stylish.md) dans
`~/.claude/output-styles/emoji-stylish.md`.

Activation : ajouter `"outputStyle": "emoji-stylish"` dans `~/.claude/settings.json` (déjà en
§3). Le menu `/config` → Output style écrit le choix dans `.claude/settings.local.json`
(niveau projet seulement) — donc passer par le settings global. Prise en compte après `/clear`
ou nouvelle session.

_(La commande `/output-style` a été retirée dans une version récente de Claude Code.)_

---

## §5 — Permissions par repo (`.claude/settings.local.json`)

Se configure **dans chaque repo**, pas en global. Point de départ dans
[`settings.local.example.json`](./settings.local.example.json) : uniquement du **vraiment
read-only** + un bloc `deny` qui bloque la lecture de `.env`, clés, `~/.ssh`, credentials
(les règles `deny` s'appliquent tout de suite, sans attendre le trust du dossier).

À copier vers `.claude/settings.local.json` du repo, puis compléter au fil de l'eau avec les
commandes que tu approuves souvent. **Ne pas** y mettre `find`, `cat`, `git push`,
`pnpm add/install` en wildcard : ça revient à de l'exécution/lecture arbitraire sans prompt.

---

## §6 — Faire mieux : ce repo en plugin

Plus propre qu'un fichier à coller : packager tout ça en **plugin de marketplace**.

```
claude plugin marketplace add decuyperanthony/claude-setup
claude plugin install anthony-setup@anthony
# puis dans la session :
/anthony-setup:apply-setup
```

Layout cible :

```
claude-setup/
├── .claude-plugin/
│   ├── marketplace.json     # { "name": "anthony", "plugins": [{ "name": "anthony-setup", "source": "./" }] }
│   └── plugin.json          # { "name": "anthony-setup", "version": "1.0.0" }
├── skills/
│   ├── apply-setup/SKILL.md # lit reference/global-CLAUDE.md, diff, écrit ~/.claude/CLAUDE.md après confirmation ; merge settings.json
│   ├── caveman/SKILL.md     # mes skills perso, embarqués
│   └── zoom-out/SKILL.md
├── output-styles/emoji-stylish.md
└── reference/
    ├── global-CLAUDE.md     # source de vérité unique des préférences
    └── settings.json
```

Ce qu'on gagne : zéro copier-coller, `claude plugin update` pour les màj, skills perso
(`caveman`, `zoom-out`) transportés d'office, source de vérité unique, versionné/rollbackable.

Détails d'accès :

- `owner/repo` clone en **SSH par défaut**. Sans clé SSH : `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1`,
  ou URL complète `claude plugin marketplace add https://github.com/decuyperanthony/claude-setup.git`
  (utilise les credential helpers git, comme `gh auth login`).
- Sans git du tout : marketplace via **URL directe** vers un `marketplace.json` hébergé +
  entrée plugin `source: "archive"` (zip HTTPS + `sha256`).
- Repo privé = credentials git requis. Le contenu étant générique et sans rien de sensible,
  **le passer en public** supprime toute friction d'auth.

Si `claude plugin marketplace add` échoue, `/status` indique quelle source de settings
s'applique.

_À faire quand j'aurai le temps ; le fichier unique de ce README suffit pour démarrer._

---

## Ce qui n'est PAS dans ce repo (volontairement)

- Aucun code, doc, nom de projet, de client ou d'employeur — que des préférences de craft génériques.
- Aucun secret : pas de `.credentials.json`, pas d'historique de conversations, pas de sessions.
- `settings.local.json` réel (allowlist accumulée) — seul un exemple élagué est fourni.
