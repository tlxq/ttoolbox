---
name: handover
description: End a session cleanly so the next one starts where this one stopped - write what changed and what's next into the plan (and the board, if there is one), check nothing is left uncommitted, then suggest /clear. Use when the user types /handover, when the context is half full or more, when a plan step is finished and the next one is big, or before switching machines.
---

# handover

Short sessions give better answers than one long one. The next session only knows what's in the
plan, the board and git, so that's where this session's memory goes. Nothing lives only in the chat.

## 1. Save the work
- In each repo touched: `git status -sb` and `git worktree list`. Uncommitted work gets committed on
  its branch (or a branch made for it, per `ship-branch`), or the user is told plainly what's left
  and why.
- Open PRs: say which ones are waiting and on what (checks, the user, a merge).
- Dotfiles or config shared between machines: push them, so the other machines get them.

## 2. Write it down (one home per thing)
- **Plan file** (the one this work belongs to): tick finished steps with the date and the proof
  (commit, PR, verifier PASS). Under the first unticked step, add a line `Next:` with the exact next
  action, so the next session can start without asking. New findings go in its register
  (`findings-register`).
- **Board** (a single backlog file, if the user keeps one; its path is in their CLAUDE.md): change
  the Now line only if its state changed (done = delete the line; blocked on the user = say on what).
  Keep its limits.
- **Memory**: only a lasting lesson about how the user works or a pointer; never status (status
  lives in the plan and the board).

## 3. Tell the user (short)
Run `python3 -I <this skill's base directory>/waits.py --repo <repo>` for the repo this session worked
in and put its one line last. It reads the local Claude Code session logs only and spends no usage.
It's there to look at, not to act on: a week's numbers get compared only when the user asks for a
review.
```
Done: <what changed, with proof>
Waiting: <PRs / the user's choices, if any>
Next: <the one next action>   (written in <plan file>)
<the script's line>
```
Then: "Run /clear, then say `continue` (or /start for something new)." If this session added or
changed agents, hooks or plugins, say "Quit and start Claude again" instead: /clear keeps the same
process, which only loads those at start.

Don't run /clear yourself and don't start the next step: the handover ends this session.
