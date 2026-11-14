---
name: design-pitch
description: How a visual or UX decision gets made with the user - walk the whole flow first, hold it to a UX bar (dry, fewest taps, one home per thing, see what's happening), taste questions as a picker, then a rendered pitch, and only then code. Use whenever a screen, component, page, flow, dashboard or visual direction is being designed, redesigned or reviewed, not just built from a finished spec.
---

# design-pitch

Treat the user like the client of a good UX/UI designer. They pick the direction; it is never a
colour or layout choice already baked into code.

## The UX bar (the default, nobody should have to ask for it)

Things should feel like one professional program, not a set of pages. Every design and every
review is held to this, before taste questions and again before "done":

- **Whole flow first.** Design the journey, not the page. Before changing any screen, walk the
  whole task end to end as the user would (on the phone too), count the taps, and note every place
  they have to guess, wait without feedback, or go somewhere else. Pitch the flow, then the screens.
- **Dry.** Every fact, name and action lives in one place. One word per thing, everywhere (no
  "Interesting / Shortlist / Picked" for one idea). No title that repeats the tab, no sentence that
  repeats the status. No second set of buttons for the same thing on another page.
- **Fewest taps.** The main path is one tap per real decision. A page opens on the next thing to
  do, not the last thing done. Anything that only waits (loading, a robot, Claude) carries on by
  itself and moves the person on when it's done.
- **One home per thing.** Each object (an order, a document, a setting) has one page where
  everything about it happens; lists only show rows that open it, with one next-step button.
- **See what's happening.** Whenever Claude, a robot or a job works: live steps with ticks, time so
  far, what it's using, its question with an answer box, Stop, and a plain failure state with
  Try again. Never "follow it on another page", never a silent wait.
- **Nothing is a dead end.** Every state has a next action; old pages never appear mid-flow.
- **Explains itself.** Every switch, chip and setting says what it does and when, in plain words,
  so a first-time user understands it without asking ("Auto bedtime (experimental)" fails this).
- **Measure, don't claim.** Tap counts, pixels and timings in a pitch are measured on the real
  page or mock (Playwright), not estimated.

When something built earlier misses the bar, say so and fold the fix into the pitch.

## Steps

0. **Walk the flow** (the bar above): real data, read-only, every write blocked; write the findings
   into the plan's register (`workflow:findings-register`), grouped by cause.
1. **Ask 3–4 taste questions with AskUserQuestion**: mood, colour, type, density, light/dark.
   Each option has a short reason, and the recommended one comes first with "(Recommended)".
   Add a multiSelect question with extras they may not have thought of. Never ask open-ended
   ("what do you want?").
2. **Check the structure** before building the mock: the main action is easy to reach, spacing
   sits on the project's grid, type stays within its sizes, and every state is there (empty,
   loading, error, success).
3. **Publish a rendered pitch** (an Artifact where your Claude has them, else a local HTML page)
   that shows the decision on real content: colour swatches, a contrast ledger (WCAG AA), a type
   specimen with the real copy and language, and the components in context. Hex codes in a table
   are not enough; seeing it is what makes a fast, sure yes possible. Before the user sees it,
   screenshot every mockup at phone width and look: content centred where it should be, edges
   lined up, tiles in a row the same height, nothing that jumps between states. A page type's own
   "don't verify" never skips this.
4. **Build only after they approve**, then check the result against the pitch and the bar: walk
   the flow again and count the taps.

## Reuse what the project has

Use the project's existing design tokens instead of making a new palette per screen. The
project's CLAUDE.md says where they live. Deviate only when a taste answer gives a reason.
Visible text follows `workflow:signum`.
