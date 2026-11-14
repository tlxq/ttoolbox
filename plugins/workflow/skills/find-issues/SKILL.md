---
name: find-issues
description: Hunt for issues in whatever the user points at - a repo, a web page or app, or a machine's services and jobs - read-only, with evidence, grouped by cause, and written into the findings register. Use when the user asks to find issues, look for problems, "what's broken", "check X for bugs", audit or health-check something.
---

# find-issues

Look for what is wrong, not for proof that a feature works. One broad "nothing is wrong" sweep
beats several narrow "this works" checks: narrow probes once let a 13 000 px blank page reach
production.

## 1. Pin the target and the rules

- Target from the user's words, else the current directory. Name it in one line before starting.
- Read the rules before touching anything: the project's `CLAUDE.md` and any rules or "ask first"
  list it points to (that list wins).
- **Read-only.** No fixes, deploys, migrations, data writes or device commands during the hunt.
  Never touch real user data or anything the project marks ask-first. Test data you create gets
  cleaned up by its own naming pattern.

## 2. Sweep

Pick the lens that fits; use more than one when the target spans them.

**Code** - run what the repo already has (typecheck, lint, tests, build) and note failures.
Then read for: unhandled errors and empty catches, races, wrong edge cases (empty, null, time
zones, non-ASCII characters), secrets in the tree, dead or half-renamed code, config that drifts
between machines, TODO/FIXME that hide real gaps. `git log -20` for what changed recently.

**Web page / app** - drive the whole flow in a real browser (its own Playwright session, phone
width and desktop). On every screen: console errors, network responses >= 400 with their body,
page height vs footer, overflow and horizontal scroll, empty / loading / error states,
dark mode, slow or failing requests, broken links.

**Services and jobs** - logs for repeated errors, timers and jobs that failed or haven't run
when they should (`systemctl --user list-timers`, `journalctl -p warning --since -2d`),
services down, disk and backup age. Only real data sources: don't infer what a device can't
report.

## 3. Prove each one

A finding needs evidence: file:line, a command and its output, a screenshot, a log line or a
response body. Reproduce it once. If you can't prove it, list it as "suspect", separately.

## 4. Register and group

- Every finding goes into the findings register (`workflow:findings-register`) as it is found.
- Urgent = breaks something, loses data, a safety or security gap. Say so at the top; fix only
  after the user says go.
- Group findings by shared cause and propose **one** long-term fix per group (a check, guard
  or rule that makes the class of bug visible or impossible).

## 5. Report

Short, in this order:

1. Urgent findings (F-number, one line each).
2. Groups: cause → findings → proposed long-term fix.
3. Suspects not yet proven.
4. What was not checked, and why.
5. One suggested next step.
