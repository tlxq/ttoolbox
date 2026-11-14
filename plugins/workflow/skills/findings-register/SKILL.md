---
name: findings-register
description: Keep a findings register in the plan so nothing found while building, testing or reviewing gets lost; urgent findings are fixed at once. Use whenever a bug, gap, risk, odd behaviour or follow-up is found during planned work, and before reporting a finished step.
---

# findings-register

Everything found along the way should be remembered so nothing gets lost, and anything urgent gets
solved. Findings scattered over chat, plan paragraphs and memory notes get lost.

## Where

One register per plan: a "Findings register" table in the plan file the work belongs to. Create
it at the first finding if the plan has none.

| # | Finding | Urgent? | Owner · status |
|---|---|---|---|
| F1 | what was seen, where, and why it matters (one or two sentences) | yes / no | Claude · fixed in abc1234 |

Number on from the last F-number, never reuse one.

## When

- The moment something is found, not at the end of the session.
- **Urgent** (breaks something, loses data, a safety or security gap, blocks the plan):
  fix it now, then mark it "fixed in <commit>" with a date.
- Not urgent: leave it open with who and when.
- Close an item only after checking it is really done.

## In the report

After each step, name the new findings and which ones were fixed, with their F-numbers.
