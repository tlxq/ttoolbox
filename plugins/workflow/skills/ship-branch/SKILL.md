---
name: ship-branch
description: Branch-per-change habit for git repos - one branch and one PR per unit of work, done only when the checks are green. Use when starting a new feature, fix or chore in a repo that has a GitHub remote and a main branch, before the first edit.
---

# ship-branch

Each unit of work gets its own branch and PR. That gives a real diff to review and a clean way
back, instead of every change landing on the main branch.

## Who commits

The project decides, so read its CLAUDE.md first. Some repos let Claude run the whole loop;
in others the user commits, or a hook blocks Claude from pushing the main branch (never work
around that). If nothing says so, the user commits.

## Steps

1. Before the first edit, branch off the main branch:
   `git checkout -b <feat|fix|chore>/<short-description>`.
2. Make the change, with its tests.
3. Commit, or stop and describe the change so the user can commit (see "Who commits").
4. `git push -u origin <branch>`, then `gh pr create`.
5. Merge, when the project allows it. With required CI checks: `gh pr merge --auto --squash`, then
   `gh pr checks --watch`. Without CI: run the project's whole check locally (for example
   `mise run check`), say so in the PR, then merge. The work is not done while checks fail or the
   PR is open.

## When not to branch

Read-only investigation, repos with no remote or no PR flow (a dotfiles repo pushed straight to
its main branch), and one-line fixes the user asks for as a quick fix. When in doubt, branch.
