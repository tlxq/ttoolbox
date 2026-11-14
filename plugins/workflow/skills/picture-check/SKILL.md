---
name: picture-check
description: Before a PR that changes how an app or site looks is merged, take pictures of every screen the click flows reach, compare them with the main branch's pictures and show the user a before/after page. Use for any PR that touches screens, components, theme or copy in a project that has a picture check (a task like `mise run pictures`), and when setting one up in a new app project.
---

# picture-check

Tests prove logic and the verifier proves it works, but nobody looks at the whole screen until
after the merge. That is how layout faults reach store pictures: an inset map, stacked bars, a tab
bar that content shows through. The picture check closes that gap. Everything runs on the local
machine: no CI minutes, no cloud diff service.

## In a project that has one

1. Build the change on its branch as usual (`ship-branch`), with the project's check green.
2. Run the project's picture task (for example `mise run pictures`). It runs the click flows on
   the emulator against demo data, saves one picture per screen and writes a page with the main
   branch on the left and this branch on the right, changed screens first.
3. Look at every changed screen yourself before the user does: does the change look like the plan,
   did something else move? Fix what's off and run it again.
4. Share the page (an Artifact where your Claude has them, else the local HTML file) with one line
   per changed screen. The PR body says "Picture check: N of M screens changed" and links the page.
5. Merge after the user's look (or their standing OK for the plan). Then run the task on the main
   branch so the new pictures become the baseline.

Unchanged screens are not noise: if a PR that should change one screen changes three, that is
a finding.

## Setting one up in a new app project

- Click flows: Maestro YAML in `.maestro/flows`, one per main task, each with
  `takeScreenshot: <screen>` after the screen has settled. Pin Maestro in `mise.toml`.
- A local runner (`mise run e2e`) that starts what is missing (database, a headless emulator,
  the bundler), uses demo data only, names the emulator in every adb call, and refuses to run
  against a live backend.
- A fixed status bar (Android demo mode: 12:00, full wifi, no mobile icon) so pictures compare.
- The baseline lives outside the repo (`~/.local/share/<project>/pictures/main`), per machine.
