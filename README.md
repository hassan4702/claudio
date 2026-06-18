# Claudio

A tiny macOS menu-bar app that gives Claude Code a sound when it finishes or
needs your input. It works by safely adding two hooks to your
`~/.claude/settings.json` that play a sound via `afplay` — so the chimes play
even when Claudio isn't running.

## Install

**Quickest — one command** (downloads, installs to Applications, launches):

    curl -fsSL https://raw.githubusercontent.com/hassan4702/claudio/main/install.sh | bash

**Or download manually:** grab `Claudio.dmg` from the [latest release](https://github.com/hassan4702/claudio/releases/latest),
open it, and drag **Claudio** onto **Applications**. The first launch, right-click
the app → **Open** once (Claudio isn't notarized yet, so macOS asks for confirmation
that one time).

Then click the 🔔 in your menu bar and hit **Enable Claude sounds**.

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
