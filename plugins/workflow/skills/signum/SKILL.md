---
name: signum
description: A rule book for how everything you build reads, behaves, looks and flows - labels, status words, button verbs, errors, loading, feedback, tap size, motion, times and surfaces - in web pages, apps, TV pages, desktop bar plugins and CLI output. Use before writing or changing any user-visible text, label, button, status, dialog, message or screen, and when reviewing one.
---

# signum

One set of rules for every surface, picked from GitHub Primer, Apple's Human Interface Guidelines
and Material 3. The test for every rule: a person who has never seen the product can understand it
without asking. A project's own rules files keep its glossary and logic and point here; where one
disagrees with this file, ask the user which wins before changing either.

## Words

- **W1 A label says what it does and when.** "Dim the lights at 22:00 on weekdays", not "Auto
  bedtime". Experimental things get a separate `Experimental` badge; the word never goes inside the
  label.
- **W2 No internal ids in anything people read**: no rule ids (R8, T3), entity ids, container or tool
  names, raw state keys (QUIET). Ids live in code comments; tech names go under Details.
- **W3 Sentence case, verb first, one line**: "Save changes", "Turn off lights". No punctuation on
  buttons or labels. (Primer, Material)
- **W4 Status words**, the same on every surface (web, app, TV, desktop bar, CLI):

  | Word | Role / token | Icon | Means |
  |---|---|---|---|
  | OK | success / `ok` | check | nothing to do |
  | Needs you | attention / `warn` | triangle | you must act; the row says what |
  | Failed | danger / `bad` | circle-x | it broke; the row says why + Try again |
  | Off | neutral / `off` | circle-dash | off, asleep or paused on purpose (never red) |
  | Saving… | attention | ring | busy: a verb ending in "…ing" |

  Shown as a **word + icon pill** everywhere (Primer state label). A sentence next to it may say more
  ("Both machines in sync"); the pill word doesn't change. Retired: fine, good, All good, In sync (as
  a status), to look at, check, warning, problem, unhealthy.
- **W5 Verbs, one meaning each**: Turn on / Turn off (never Enable) · Save (Save PDF, never Make PDF)
  · Undo (reverses the last action only) · Try again (never Retry) · Install (never Get) · Stop ·
  Cancel (leave a dialog, nothing done) · Close (leave a view) · Remove (off a list; the thing stays) ·
  Delete (gone for good) · Open › (to the thing's one home) · Put back (restore an older version).
  Never OK / Yes / No for an action. A busy button relabels itself ("Save" → "Saving…"); "…" on a
  button means it opens a dialog.
- **W6 Errors**: "Couldn't <what>. <why, if known>. Try again". Shown next to the problem, the input
  is kept. Never "Something went wrong", "oops", "we" or blame.
- **W7 Times**: relative for the last hour ("3 min ago"), then 24-hour ("14:20", "Mon 26 Oct");
  exact time on hover or long press. Nights are named by the morning they end.
- **W8 Language and tone**: one UI language per product; another language only for names and for
  documents written in it. Plain, first person, no slogans or metaphors.
- **W9 One word per thing**: use the project glossary, and keep it in the project's rules file. Once
  a thing is called "Auto", it is never also "Rhythm" or "Smart". "Auto" is fine for anything that
  picks its own speed or mode (fans, a thermal mode).

## Logic

- **L1 Every state has a next action.** No dead ends, no silent waits.
- **L2 Waiting**: under 1 s show nothing · 1–3 s a spinner that names what it loads · over 3 s live
  steps with ticks, time so far and Stop (Pause when stopping would lose work) · over 10 s it carries
  on in the background. Big areas get a skeleton. (Primer, Apple)
- **L3 Feedback is inline**, next to what changed ("Saved" pill on the row, "Picked · Undo" on the
  row). No toasts or snackbars, Undo included. (Primer)
- **L4 Asking first**: only for actions that can't be undone, as a centred alert: a question title
  ("Delete this fact?"), one line of what happens, **Cancel | Delete** with the destructive button in
  red and never the default. Everything undoable just happens and offers Undo inline. (Apple)
- **L5 "Needs you" only when the person must act.** Noise isn't red: a deploy is grey
  "Restarting…", a machine that's off is grey.
- **L6 Defaults are written in their rule**; an exception says why.
- **L7 A hand change wins** over automation until the next planned step; things that differ from
  each other show "Mixed".
- **L8 Empty and missing**: an empty state says why it's empty and gives one action. Missing data
  hides its number (never 0 or "?"); data the person made is never shown as empty: say it couldn't
  load.
- **L9 Works for a first-time user**: empty profile, no history.

## Look

- **K1 Colour is status only** (success, attention, danger, neutral), always with a word and an icon.
  One accent colour is for links, focus and the active item. In a desktop bar, accent + bold may mark
  "changing" (a temperature that is rising).
- **K2 Surfaces**: flat panels with a hairline edge. Gradients only as accents: a greeting or hero
  and selected states (gradient ring). Never behind status colours or text that must be read fast.
- **K3 Type**: one highly legible text face, one monospace face with tabular figures for times and
  numbers. Text can grow to 200% without breaking: rows stack, buttons stay one line. Small
  uppercase is allowed only for section labels ("TOOLS", "THERMAL": small, letter-spaced), never for
  states, buttons or sentences.
- **K4 Tap size**: 48 px on phone and TV pages, at least 44 px in a desktop bar.
- **K5 Motion**: 100 ms (press) / 200 ms (toggle) / 300 ms (panel), easing
  `cubic-bezier(0.2, 0, 0, 1)` (Material standard); opacity and transform only; none with reduced
  motion.
- **K6 Contrast** WCAG AA or better (text 4.5:1, controls 3:1); small quiet text 7:1.
- **K7 TV pages** keep 60 px top/bottom and 80 px side margins, with room for the focus ring.
- **K8 Tokens, never literals**: colours, sizes, spacing and speeds come from the project's token
  file (its CLAUDE.md says where); desktop shell plugins use only the shell's own colour and style
  roles.

## Flow

- **F1 Walk the whole task first** (phone too), count taps on the real page, never estimate.
- **F2 One home per thing**; lists show rows that open it with one next step.
- **F3 A page opens on the next thing to do**; most used first, measured from history.

## Keeping it

- A rules file changes first (agreed with the user), then the code. Cite rule ids (W4, L3 …) in code
  comments, never in visible text (W2).
- Design work follows `workflow:design-pitch`; this file is what the pitch is held to.
- The mechanical rules are worth a check script in CI: rule ids in visible text, "(experimental)"
  inside a label, retired words, Yes/No buttons.

Sources: primer.style (content, state label, saving, loading, empty states, degraded experiences) ·
developer.apple.com/design/human-interface-guidelines (buttons, alerts, writing, color, layout,
progress indicators) · material-web motion/colour/type tokens and developer.android.com accessibility.
