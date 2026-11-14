#!/usr/bin/env bats
# Tests for the handover's wait report. Fake logs in a fake home; gh is absent or a stub.

setup() {
  WAITS="$BATS_TEST_DIRNAME/../plugins/workflow/skills/handover/waits.py"
  export HOME="$BATS_TEST_TMPDIR/home"
  unset CLAUDE_CONFIG_DIR
  REPO="$BATS_TEST_TMPDIR/shop"
  mkdir -p "$REPO" "$BATS_TEST_TMPDIR/bin"
  SLUG=$(printf '%s' "$REPO" | sed 's/[^A-Za-z0-9]/-/g')
  LOGS="$HOME/.claude/projects/$SLUG"
  mkdir -p "$LOGS"
  LOG="$LOGS/one.jsonl"
  export PATH="$BATS_TEST_TMPDIR/bin:$(dirname "$(command -v python3)"):/usr/bin:/bin"
  printf '#!/bin/sh\nexit 1\n' >"$BATS_TEST_TMPDIR/bin/gh"
  chmod +x "$BATS_TEST_TMPDIR/bin/gh"
}

you() { printf '{"type":"user","uuid":"%s","timestamp":"2026-11-05T%s:00Z","message":{"content":"%s"}}\n' "$1" "$2" "$3" >>"$LOG"; }
said() { printf '{"type":"assistant","uuid":"%s","timestamp":"2026-11-05T%s:00Z","message":{"content":[{"type":"text","text":"ok"}]}}\n' "$1" "$2" >>"$LOG"; }
call() { printf '{"type":"assistant","uuid":"%s","timestamp":"2026-11-05T%s:00Z","message":{"content":[{"type":"tool_use","id":"%s","name":"%s","input":{"command":"%s"}}]}}\n' "$1" "$2" "$3" "$4" "$5" >>"$LOG"; }
back() { printf '{"type":"user","uuid":"%s","timestamp":"2026-11-05T%s:00Z","message":{"content":[{"type":"tool_result","tool_use_id":"%s","content":"x"}]}}\n' "$1" "$2" "$3" >>"$LOG"; }
run_waits() { run python3 -I "$WAITS" --repo "$REPO" --since 2026-11-05 --until 2026-11-06; }

@test "says why when there is nothing to report" {
  run_waits
  [ "$status" -eq 0 ]
  [ "$output" = "No requests in shop, since 05 Nov." ]
}

@test "counts typical and long requests, and hides main red without gh" {
  you a 10:00 first; said b 10:01
  you c 11:00 second; said d 11:03
  you e 12:00 third; said f 12:40
  run_waits
  [[ "$output" == *"typical 3.0 min"* ]]
  [[ "$output" == *"1 of 3 over 30 min"* ]]
  [[ "$output" != *"main red"* ]]
}

@test "names long pauses for tests and for your answers, not short ones" {
  you a 10:00 go
  call b 10:01 t1 Bash "npm run test:browser:docker"
  back c 10:13 t1
  call d 10:14 t2 AskUserQuestion ""
  back e 10:20 t2
  call f 10:21 t3 Bash "mise run walk"
  back g 10:23 t3
  run_waits
  [[ "$output" == *"tests and CI 0.2 h"* ]]
  [[ "$output" == *"your answers 0.1 h"* ]]
}

@test "follows a background test to the note that it finished" {
  you a 10:00 go
  call b 10:01 t1 Bash "npm run test:browser:docker"
  back c 10:01 t1
  printf '{"type":"user","uuid":"d","timestamp":"2026-11-05T10:31:00Z","message":{"content":"<task-notification><tool-use-id>t1</tool-use-id></task-notification>"}}\n' >>"$LOG"
  said e 10:32
  run_waits
  [[ "$output" == *"tests and CI 0.5 h"* ]]
  [[ "$output" == *"1 of 1 over 30 min"* ]]
}

@test "leaves out requests left open for 8 hours and notes that aren't from you" {
  you a 01:00 go; said b 09:30
  you c 10:00 next; said d 10:02
  printf '{"type":"user","uuid":"e","timestamp":"2026-11-05T10:03:00Z","message":{"content":"<system-reminder>x</system-reminder>"}}\n' >>"$LOG"
  said f 10:04
  run_waits
  [[ "$output" == *"0 of 1 over 30 min"* ]]
  [[ "$output" == *"typical 4.0 min"* ]]
}

@test "reads a shared log folder once" {
  you a 10:00 go; said b 10:02
  mkdir -p "$HOME/.claude-other"
  ln -s "$HOME/.claude/projects" "$HOME/.claude-other/projects"
  CLAUDE_CONFIG_DIR="$HOME/.claude-other" run_waits
  [[ "$output" == *"0 of 1 over 30 min"* ]]
}

@test "counts red runs on main when gh answers" {
  cat >"$BATS_TEST_TMPDIR/bin/gh" <<'E'
#!/bin/sh
case "$1" in
  repo) echo master ;;
  run) echo '[{"conclusion":"failure","createdAt":"2026-11-05T10:00:00Z"},{"conclusion":"success","createdAt":"2026-11-05T11:00:00Z"},{"conclusion":"failure","createdAt":"2026-10-01T10:00:00Z"}]' ;;
esac
E
  you a 10:00 go; said b 10:02
  run_waits
  [[ "$output" == *"main red 1 time"* ]]
  [[ "$output" != *"times"* ]]
}

@test "reads the logs of a second Claude profile from CLAUDE_CONFIG_DIR" {
  mkdir -p "$HOME/.claude-other/projects/$SLUG"
  LOG="$HOME/.claude-other/projects/$SLUG/two.jsonl"
  you a 10:00 go; said b 10:40
  CLAUDE_CONFIG_DIR="$HOME/.claude-other" run_waits
  [[ "$output" == *"1 of 1 over 30 min"* ]]
}

@test "counts common test runners as tests" {
  you a 10:00 go
  call b 10:01 t1 Bash "bats tests/"
  back c 10:13 t1
  run_waits
  [[ "$output" == *"tests and CI 0.2 h"* ]]
}
