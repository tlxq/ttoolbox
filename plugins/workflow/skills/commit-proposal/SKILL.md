---
name: commit-proposal
description: Propose a commit message from the staged changes, in the repo's own style (Conventional Commits unless the repo uses another). Use when the user asks for a commit message or commit proposal, or for help after a commit message was rejected.
---

# commit-proposal

Look only at `git diff --cached` and `git diff --cached --stat`. Never guess a message from
unstaged changes; the user stages what they mean.

## Return

1. One recommended message. Match the repo's style first (`git log --oneline -15`):
   - Conventional Commits `type(scope): subject` where the repo uses them (commitlint config,
     or the log shows it). `feat` user-visible, `fix` a defect, `chore` tooling/deps,
     `docs`, `test`, `refactor` (same behaviour). Scope = the area, when it helps.
   - Otherwise the pattern the log shows.
   - Subject imperative, lowercase after the colon, under 72 characters.
2. A short body only when the change needs context the subject can't hold.
3. A one-line warning when related files are left unstaged (lockfiles, tests, generated files).

## Don't

Run `git add`, `git commit`, `git push` or amend, unless the project's CLAUDE.md or the user in
the moment says Claude commits. No AI attribution trailers unless the repo asks for them. A
commit hook or commitlint, when the repo has one, is the final check.
