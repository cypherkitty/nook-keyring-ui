#!/usr/bin/env bash
set -euo pipefail

site="$RUNNER_TEMP/site"
build="$RUNNER_TEMP/build"
ref=refs/heads/gh-pages
existing=$(git ls-remote origin "$ref")
if [[ -n "$existing" ]]; then
  git fetch --no-tags --depth=1 origin "$ref"
  git worktree add --detach "$site" FETCH_HEAD
else
  git worktree add --orphan -b gh-pages "$site"
fi

if [[ -z "$ARTIFACT" ]]; then
  [[ "$TARGET" =~ ^pr/[1-9][0-9]*$ ]]
  rm -rf -- "${site:?}/${TARGET:?}"
else
  test -s "$build/index.html"
  excludes=(--exclude=.git)
  if [[ "$TARGET" == . ]]; then
    excludes+=(--exclude=/pr/)
  fi
  mkdir -p "$site/$TARGET"
  rsync -r --checksum --delete "${excludes[@]}" "$build/" "$site/$TARGET/"
fi

git -C "$site" add --all
if ! git -C "$site" diff --cached --quiet; then
  git -C "$site" -c user.name='github-actions[bot]' \
    -c user.email='41898282+github-actions[bot]@users.noreply.github.com' commit -m "Update Pages at /$TARGET"
  git push origin "$(git -C "$site" rev-parse HEAD):$ref"
fi

if [[ -s "$site/index.html" ]]; then
  echo 'ready=true' >> "$GITHUB_OUTPUT"
fi
