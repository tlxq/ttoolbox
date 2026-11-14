#!/usr/bin/env bats
# Tests for tools/public-guard. Only made-up words are used, never a real list word.

setup() {
  T="$BATS_TEST_TMPDIR"
  G="$BATS_TEST_DIRNAME/../tools/public-guard"
  export GIT_CONFIG_GLOBAL="$T/gitconfig" GIT_CONFIG_NOSYSTEM=1
  git config --global init.defaultBranch main
  git config --global user.name t; git config --global user.email t@example.com
  printf '# test list\nmade-up-test-word-q9k2\nSmörgåsbord\n' >"$T/words"
  export NEVER_PUBLIC_FILE="$T/words"
  unset NEVER_PUBLIC_WORDS
  git init -q "$T/r"; cd "$T/r"
  echo ok >a.txt; git add a.txt; git commit -qm init
}

@test "staged: clean change passes" {
  echo fine >>a.txt; git add a.txt
  run "$G" staged
  [ "$status" -eq 0 ]
}

@test "staged: a list word in a line is stopped, word shown locally" {
  echo "meet at made-up-test-word-q9k2" >>a.txt; git add a.txt
  run "$G" staged
  [ "$status" -eq 1 ]
  [[ $output == *'"made-up-test-word-q9k2" in: a.txt:2'* ]]
}

@test "staged: case and non-ASCII words match as whole words" {
  echo "Cruising SMÖRGÅSBORD" >b.txt; echo "smörgåsbordsvägen" >c.txt; git add b.txt
  run "$G" staged
  [ "$status" -eq 1 ]
  git reset -q; git add c.txt
  run "$G" staged
  [ "$status" -eq 0 ]
}

@test "staged: a list word in a file name is stopped" {
  echo x >"made-up-test-word-q9k2.md"; git add .
  run "$G" staged
  [ "$status" -eq 1 ]
  [[ $output == *"in: file name"* ]]
}

@test "staged: image outside assets/ is stopped, inside passes" {
  command -v magick >/dev/null || skip "no ImageMagick"
  magick -size 4x4 xc:red shot.png; git add shot.png
  run "$G" staged
  [ "$status" -eq 1 ]
  [[ $output == *"images live in an assets/"* ]]
  git rm -q --cached shot.png; mkdir -p docs/assets; mv shot.png docs/assets/; git add docs
  run "$G" staged
  [ "$status" -eq 0 ]
}

@test "staged: image with camera tags is stopped" {
  command -v magick >/dev/null && command -v exiftool >/dev/null || skip "no ImageMagick or exiftool"
  mkdir -p docs/assets; magick -size 4x4 xc:red docs/assets/p.jpg
  exiftool -q -overwrite_original -Make=ExampleCam -Model=X1 docs/assets/p.jpg; git add docs
  run "$G" staged
  [ "$status" -eq 1 ]
  [[ $output == *"camera, place or owner tags"* ]]
}

@test "msg: AI attribution lines are stopped" {
  # The fixtures are split with "" so this file itself passes the guard at commit time.
  for line in "Co-Authored-By: Clau""de Opus <noreply@anthro""pic.com>" "Clau""de-Session: x" \
              "see https://claude.ai/co""de/session_01abc" "🤖 Generated with [Clau""de Code](https://claude.com)"; do
    printf 'feat: x\n\n%s\n' "$line" >m
    run "$G" msg m
    [ "$status" -eq 1 ]
    [[ $output == *"AI attribution"* ]]
  done
  printf 'feat: x\n\nCo-Authored-By: Anna <a@example.com>\n# made-up-test-word-q9k2 in a git comment\n' >m
  run "$G" msg m
  [ "$status" -eq 0 ]
}

@test "range: CI words come from the env, hit names the list line, not the word" {
  base=$(git rev-parse HEAD)
  echo "made-up-test-word-q9k2" >>a.txt; git commit -qam "fix: x"
  export NEVER_PUBLIC_WORDS=$'other\nmade-up-test-word-q9k2'
  run "$G" range "$base"
  [ "$status" -eq 1 ]
  [[ $output == *"list word 2"* ]]
  [[ $output != *"made-up-test-word-q9k2"* ]]
}

@test "range: PR body with a Claude session link is stopped" {
  base=$(git rev-parse HEAD)
  echo y >>a.txt; git commit -qam "fix: y"
  PR_TITLE="fix: y" PR_BODY="https://claude.ai/co""de/session_01abc" run "$G" range "$base"
  [ "$status" -eq 1 ]
  [[ $output == *"PR body"* ]]
}

@test "no word list: a note, the word check is skipped, the AI check still stops" {
  export NEVER_PUBLIC_FILE="$T/none"
  echo "made-up-test-word-q9k2" >>a.txt; git add a.txt
  run "$G" staged
  [ "$status" -eq 0 ]
  [[ $output == *"word check is skipped"* ]]
  printf 'feat: x\n\nClau''de-Session: x\n' >m
  run "$G" msg m
  [ "$status" -eq 1 ]
  [[ $output == *"word check is skipped"* ]]
  [[ $output == *"AI attribution"* ]]
}

@test "word list present: a list word still stops, with no skip note" {
  echo "made-up-test-word-q9k2" >>a.txt; git add a.txt
  run "$G" staged
  [ "$status" -eq 1 ]
  [[ $output != *"skipped"* ]]
  printf 'feat: made-up-test-word-q9k2\n' >m
  run "$G" msg m
  [ "$status" -eq 1 ]
}

@test "an empty word list fails closed" {
  : >"$T/empty"
  NEVER_PUBLIC_FILE="$T/empty" run "$G" staged
  [ "$status" -eq 2 ]
}

@test "staged: the guard's own file doesn't trip it; paths show with any diff prefix setting" {
  git config diff.mnemonicPrefix true; git config diff.noprefix true
  mkdir -p tools; cp "$G" tools/public-guard; echo "made-up-test-word-q9k2" >b.txt; git add tools b.txt
  run "$G" staged
  [ "$status" -eq 1 ]
  [[ $output == *"in: b.txt:1"* ]]
  [[ $output != *"tools/public-guard"* ]]
}

@test "staged: binary-ish files make no awk or grep noise" {
  mkdir -p assets; printf '\x89PNG\xff\xfe\x00' >assets/x.png; printf 'ok\xff\xfe line\n' >odd.txt; git add assets odd.txt
  run "$G" staged
  [[ $output != *"multibyte"* ]]
  [[ $output != *"binary file matches"* ]]
}
