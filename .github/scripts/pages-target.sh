#!/usr/bin/env bash
set -euo pipefail

api="repos/$GITHUB_REPOSITORY"

if [[ "$GITHUB_EVENT_NAME" == pull_request_target ]]; then
  number=$(jq -r '.number' "$GITHUB_EVENT_PATH")
  state=$(gh api "$api/pulls/$number" --jq '.state')
  if [[ "$state" == closed ]]; then
    echo "path=pr/$number" >> "$GITHUB_OUTPUT"
  fi
  exit 0
fi

event=$(jq -r '.workflow_run.event' "$GITHUB_EVENT_PATH")
case "$event" in
  pull_request)
    # Fork runs can omit the PR number. Verify the artifact's claimed PR against GitHub.
    run_id=$(jq -r '.workflow_run.id' "$GITHUB_EVENT_PATH")
    artifact=$(gh api "$api/actions/runs/$run_id/artifacts" --jq '.artifacts[].name | select(test("^pr-[1-9][0-9]*$"))')
    [[ "$artifact" =~ ^pr-([1-9][0-9]*)$ ]] || { echo 'Expected one PR build artifact.' >&2; exit 1; }
    number=${BASH_REMATCH[1]}
    pr=$(gh api "$api/pulls/$number")
    if ! jq -e --slurpfile event "$GITHUB_EVENT_PATH" '
      $event[0].workflow_run as $run |
      .state == "open" and .head.sha == $run.head_sha and
      .head.ref == $run.head_branch and .head.repo.id == $run.head_repository.id
    ' <<< "$pr" > /dev/null; then
      exit 0
    fi
    target="pr/$number"
    ;;
  push|workflow_dispatch)
    current=$(gh api "$api/git/ref/heads/main" --jq '.object.sha')
    if ! jq -e --arg sha "$current" --arg repo "$GITHUB_REPOSITORY" '
      .workflow_run | .head_branch == "main" and .head_sha == $sha and .head_repository.full_name == $repo
    ' "$GITHUB_EVENT_PATH" > /dev/null; then
      exit 0
    fi
    artifact=main
    target=.
    ;;
  *) exit 0 ;;
esac

printf 'path=%s\nartifact=%s\n' "$target" "$artifact" >> "$GITHUB_OUTPUT"
