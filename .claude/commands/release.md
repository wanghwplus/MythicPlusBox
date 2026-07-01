---
description: Cut a new release of MythicPlusBox — updates CHANGELOG, builds the zip, commits and tags.
---

# Release MythicPlusBox

Follow these steps in order. Report what changed at the end.

## 1. Read the current version

```bash
grep -E '^## Version:' MythicPlusBox/MythicPlusBox.toc | head -1
```

Call the result `VER` for the rest of these steps.

## 2. Summarise the changes since the last tag

```bash
git describe --tags --abbrev=0 2>/dev/null || echo "(no previous tag)"
git log --pretty=format:'%s' $(git describe --tags --abbrev=0 2>/dev/null)..HEAD 2>/dev/null || git log --pretty=format:'%s'
```

Turn the commit list into **one** entry for `CHANGELOG.md` under a new
`## v$VER` heading. The entry must be bilingual: one English bullet followed by
one 简体中文 bullet (or the reverse — mirrored). Keep each side to 1–3
sentences. Prepend the new entry above the previous `## v...` section.

## 3. Build the zip

```bash
bash release.sh
```

Confirm it printed `Created MPBox-v$VER.zip (version $VER)`.

## 4. Commit and tag

```bash
git add CHANGELOG.md MythicPlusBox/ release.sh CLAUDE.md README.md
git status
```

Verify the diff looks intentional, then:

```bash
git commit -m "release: v$VER"
git tag "v$VER"
```

Do **not** `git push` unless the user asks.

## 5. Bump for the next cycle

Increment the minor of `## Version:` in `MythicPlusBox/MythicPlusBox.toc`
(e.g., `0.1.0` → `0.2.0`). Commit:

```bash
git commit -m "chore: bump version to <NEW>" MythicPlusBox/MythicPlusBox.toc
```

## 6. Report

Print the released version, the new bump version, and the path to the zip:
`MPBox-v$VER.zip`.
