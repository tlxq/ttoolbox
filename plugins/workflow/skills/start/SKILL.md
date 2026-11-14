---
name: start
description: Start a piece of work the right way - read the plan, the board (if there is one) and the repo's state, make sure the goal, "done means" and where are known (ask once with choices if not), then name the skills, agents and tools that will be used before doing anything. Use when the user types /start, or opens a session with a new task that has no plan yet.
---

# start

Openers are often short ("fix the bar", "look at the login"). Half a minute here saves the
"try again" loops: know what done looks like before building.

## 1. Where are we (no questions yet)
- The board, if the user keeps one (its path is in their CLAUDE.md): is this task on it? Is there a
  plan file for it? If so, read the plan and continue from its first unticked step.
- In a repo: `git status -sb`, `git worktree list`, `gh pr list --author @me` (open PRs, failing
  checks). Read the repo's CLAUDE.md rules (who commits, ask-first list). If a server runs straight
  from a checkout, never branch in it: work in a worktree.

## 2. Three things, or ask once
1. **Goal** - what should be different afterwards.
2. **Done means** - what the verifier will check on the real thing (page shows X, phone does Y,
   service answers Z).
3. **Where** - repo / machine / device; every machine when it touches dotfiles or Claude config.

Fill in what the request and the plan already say. Ask only the missing ones, in one
AskUserQuestion call with 2-4 likely choices each (Recommended first). Never ask what the code or
the plan can answer.

## 3. Say the kit, then go
One short block before the first edit:
```
Goal: …   Done means: …   Where: …
Using: <skills> · <agents> · <tools>
```
Pick from this map (only what the task needs):

| Task | Use |
|---|---|
| Any change in a repo with a remote | `ship-branch` (branch → PR → merge when green) |
| Visible text, labels, screens | `signum` first; new screen/flow: `design-pitch` |
| A PR that changes how screens look | `picture-check`, where the project has one |
| Something broken / "check X" | `find-issues`; findings go in the plan via `findings-register` |
| Browser checks | Playwright, headless, its own session per agent |
| Commit message | `commit-proposal` |
| Two or more independent parts | `fixer` agents in worktrees, in parallel (same repo as the session) |
| Reading lots of code / docs | `researcher` agent (keeps the main context small) |
| Before a PR | `reviewer` agent (diff vs rules incl. signum) |
| Before saying done | `verifier` agent - PASS with evidence, every time |
| Ending the session | `handover` |

Then work. A plan the user approved runs to the end; stop only for their choices (taste, money,
names), anything on the project's ask-first list, or a check that fails twice.
