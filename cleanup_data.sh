#!/bin/sh -eu

die () {
    printf '\033\133;31m%s\033\133m' "$*"
    exit 1
}
warn () {
    printf '\033\133;33m%s\033\133m\n' "$*"
}
info () {
    printf '\033\133;32m%s\033\133m\n' "$*"
}

1>/dev/null 2>&1 command -v git || die 'Install `git`'

git_top_level=$(git rev-parse --show-toplevel) || die 'Not in a git repo, make sure you'\''ve ran `git init` at the root of the repo'

cd -- "$git_top_level" || die "Failed to \`cd\` into \"$git_top_level\""

rm -vrf ./data/

info 'Done! Everything seemed to have worked'
