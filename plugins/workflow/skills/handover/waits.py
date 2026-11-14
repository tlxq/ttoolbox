#!/usr/bin/env python3
"""How long you waited on Claude in one repo, from the local session logs. Reads only; uses no Claude usage.

  waits.py                                  this repo, last 7 days
  waits.py --repo ~/code/shop --days 30
  waits.py --since 2026-11-01 --until 2026-11-10

A request runs from your message to Claude's last event before your next one. Requests of 8 hours or
more are left out (left open). Only pauses of 5 min or more get a cause, so tests and answers
are the long waits, not every second spent on them. "Main red" needs gh; without it the part is hidden.
Logs are read from ~/.claude/projects and, when set, $CLAUDE_CONFIG_DIR/projects.
"""
import argparse
import glob
import json
import os
import re
import statistics
import subprocess
from datetime import datetime, timedelta, timezone

LONG_MIN = 30
PAUSE_MIN = 5
SKIP_MIN = 480
PROFILES = tuple(dict.fromkeys(["~/.claude/projects"] + ([os.path.join(os.environ["CLAUDE_CONFIG_DIR"], "projects")]
                                                      if os.environ.get("CLAUDE_CONFIG_DIR") else [])))
NOT_USER = ("<task-notification", "<system-reminder", "<local-command", "<command-", "Caveat:",
           "This session is being continued")
TESTS = re.compile(r"test:browser|playwright test|docker run\b.*playwright|mise run (walk|check|test)|tools/walk"
                   r"|\b(bats|pytest|vitest|jest)\b|npm (run )?test")
CI = re.compile(r"gh (pr checks|run (watch|view|rerun|list))|gh pr view .*(state|status)")
ASKS = ("AskUserQuestion", "ExitPlanMode")


def when(event):
    return datetime.fromisoformat(event["timestamp"].replace("Z", "+00:00"))


def blocks(event):
    content = (event.get("message") or {}).get("content")
    return content if isinstance(content, list) else []


def text_of(event):
    content = (event.get("message") or {}).get("content")
    if isinstance(content, str):
        return content.strip()
    return " ".join(b.get("text", "") for b in blocks(event) if isinstance(b, dict)).strip()


def from_user(event):
    if event["type"] != "user" or event.get("isMeta") or event.get("isCompactSummary"):
        return False
    if any(isinstance(b, dict) and b.get("type") == "tool_result" for b in blocks(event)):
        return False
    text = text_of(event)
    return bool(text) and not text.startswith(NOT_USER)


def cause_of_call(call):
    if call["name"] in ASKS:
        return "answers"
    if call["name"] != "Bash":
        return "other"
    command = call["input"].get("command", "")
    if TESTS.search(command):
        return "tests"
    return "tests" if CI.search(command) else "other"


def log_folders(repo):
    slug = re.sub(r"[^A-Za-z0-9]", "-", repo)
    found = set()
    for profile in PROFILES:
        root = os.path.expanduser(profile)
        for folder in [os.path.join(root, slug)] + glob.glob(os.path.join(root, slug + "--claude-worktrees-*")):
            if os.path.isdir(folder):
                found.add(os.path.realpath(folder))
    return sorted(found)


def read_log(path, seen):
    events = []
    with open(path, errors="ignore") as lines:
        for line in lines:
            try:
                event = json.loads(line)
            except ValueError:
                continue
            if event.get("type") not in ("user", "assistant") or "timestamp" not in event:
                continue
            if event.get("isSidechain") or event.get("uuid") in seen:
                continue
            seen.add(event.get("uuid"))
            events.append(event)
    return events


def measure(events, since, until):
    """One log's requests inside the window, as (minutes, {cause: long-pause minutes})."""
    requests = []
    calls = {}
    starts = [i for i, e in enumerate(events) if from_user(e)]
    for start, end in zip(starts, starts[1:] + [len(events)]):
        part = events[start:end]
        minutes = (when(part[-1]) - when(part[0])).total_seconds() / 60
        causes = {"tests": 0.0, "answers": 0.0}
        for before, after in zip(part, part[1:]):
            for block in blocks(before):
                if isinstance(block, dict) and block.get("type") == "tool_use":
                    calls[block["id"]] = cause_of_call(block)
            pause = (when(after) - when(before)).total_seconds() / 60
            if pause < PAUSE_MIN or after["type"] != "user":
                continue
            cause = None
            note = re.search(r"<tool-use-id>(.*?)<", text_of(after))
            if note:
                cause = calls.get(note.group(1))
            else:
                for block in blocks(after):
                    if isinstance(block, dict) and block.get("type") == "tool_result":
                        cause = calls.get(block.get("tool_use_id"))
                        break
            if cause in causes:
                causes[cause] += pause
        if since <= when(part[0]) < until and minutes < SKIP_MIN:
            requests.append((minutes, causes))
    return requests


def main_red(repo, since, until):
    """Failed pushes on the main branch in the window, or None if gh can't say."""
    def gh(*args):
        return subprocess.run(["gh", *args], cwd=repo, capture_output=True, text=True, timeout=20, check=True).stdout

    try:
        branch = gh("repo", "view", "--json", "defaultBranchRef", "-q", ".defaultBranchRef.name").strip()
        runs = json.loads(gh("run", "list", "--event", "push", "--branch", branch, "-L", "200",
                             "--json", "conclusion,createdAt"))
    except (OSError, ValueError, subprocess.SubprocessError):
        return None
    return sum(r["conclusion"] == "failure" and since <= when({"timestamp": r["createdAt"]}) < until for r in runs)


def repo_root(path):
    try:
        common = subprocess.run(["git", "rev-parse", "--path-format=absolute", "--git-common-dir"], cwd=path,
                                capture_output=True, text=True, check=True).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return os.path.realpath(path)
    return os.path.dirname(common)


def day(text):
    return datetime.strptime(text, "%Y-%m-%d").replace(tzinfo=timezone.utc)


def main():
    args = argparse.ArgumentParser(description="How long you waited on Claude in one repo.")
    args.add_argument("--repo", default=".")
    args.add_argument("--days", type=int, default=7)
    args.add_argument("--since", type=day)
    args.add_argument("--until", type=day)
    opts = args.parse_args()

    repo = repo_root(os.path.expanduser(opts.repo))
    until = opts.until or datetime.now(timezone.utc)
    since = opts.since or until - timedelta(days=opts.days)
    span = f"since {since:%d %b}" if opts.since else f"last {opts.days} days"

    seen = set()
    requests = []
    for folder in log_folders(repo):
        for path in sorted(glob.glob(os.path.join(folder, "*.jsonl"))):
            if datetime.fromtimestamp(os.path.getmtime(path), timezone.utc) >= since:
                requests += measure(read_log(path, seen), since, until)
    if not requests:
        print(f"No requests in {os.path.basename(repo)}, {span}.")
        return

    minutes = [m for m, _ in requests]
    parts = [
        f"typical {statistics.median(minutes):.1f} min",
        f"{sum(m >= LONG_MIN for m in minutes)} of {len(minutes)} over {LONG_MIN} min",
        f"tests and CI {sum(c['tests'] for _, c in requests) / 60:.1f} h",
        f"your answers {sum(c['answers'] for _, c in requests) / 60:.1f} h",
        f"{sum(minutes) / 60:.1f} h in all",
    ]
    red = main_red(repo, since, until)
    if red is not None:
        parts.append(f"main red {red} {'time' if red == 1 else 'times'}")
    print(f"Waits in {os.path.basename(repo)}, {span}: " + " · ".join(parts))


if __name__ == "__main__":
    main()
