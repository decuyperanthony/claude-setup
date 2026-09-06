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
| --------- | ----------------------------------------------- | ---------------------------------------------------------------------- |
| Typage    | `any`, `as`, `as unknown as`, `!`, `@ts-ignore` | Zod aux frontières, type guards, génériques, `?.` / `??`              |
| Fonctions | mot-clé `function`                              | arrow functions                                                       |
| Types     | `interface`                                     | `type`                                                                |
| Params    | 3+ positionnels, flags booléens                 | objet d'options, noms explicites (`activateUser` pas `update(id, true)`) |
| Imports   | `import * as X` / namespace                     | imports nommés (`import { useState } from "react"`)                   |
| Mutation  | `.push()`, `.sort()` sur l'original             | spread, `.toSorted()`, `.toReversed()`                                |
| Erreurs   | `throw new Error()` brut                        | classes d'erreur dédiées, `Result<T, E>`                             |
| Secrets   | en dur                                          | `process.env.X` avec throw si absent                                  |
| Input     | faire confiance au client                       | validation Zod côté serveur                                           |

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
