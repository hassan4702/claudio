# Claudio

A tiny macOS menu-bar app that gives Claude Code a sound when it finishes or
needs your input. It works by safely adding two hooks to your
`~/.claude/settings.json` that play a sound via `afplay` — so the chimes play
even when Claudio isn't running.

## Install
Download `Claudio.dmg` from Releases, drag Claudio to Applications, open it,
and click **Enable Claude sounds**.

## Build from source
Requires macOS 13+ and a Swift toolchain.

    swift test          # run the test suite
    swift run Claudio   # run the app
    ./packaging/build-app.sh   # produce Claudio.app

## How it works
Claude Code fires a `Stop` hook when it finishes a turn and a `Notification`
hook when it needs you. Claudio points those at sound files it manages in
`~/Library/Application Support/Claudio/`. Removing a sound or disabling Claudio
strips exactly those two hooks and leaves the rest of your config untouched.

## License
MIT
