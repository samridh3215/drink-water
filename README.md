# drink-water

A Claude Code plugin that periodically reminds you to drink water while you work.

After every Claude turn (and at session start), a hook script checks whether the
configured interval has elapsed since the last reminder. When it has, the hook
emits a `systemMessage` to the UI and injects a short note into Claude's context
so the assistant can also nudge you inline.

## Install

```text
/plugin marketplace add samridh3215/drink-water
/plugin install drink-water@drink-water
```

Run `/plugin` afterwards to confirm `drink-water` is enabled.

## Configure

Set `DRINK_WATER_INTERVAL_SECONDS` in your shell before launching Claude Code.
Default is `3600` (60 minutes).

```bash
export DRINK_WATER_INTERVAL_SECONDS=1800   # remind every 30 minutes
```

For a quick smoke test, set it to `0` so the next turn fires the reminder
immediately.

State is tracked in `${XDG_STATE_HOME:-~/.local/state}/drink-water-plugin/last-reminder`.

## Repository layout

```
drink-water-plugin/
├── .claude-plugin/
│   └── marketplace.json      # one-plugin marketplace catalog
└── drink-water/
    ├── .claude-plugin/
    │   └── plugin.json       # plugin manifest
    └── hooks/
        ├── hooks.json        # registers Stop + SessionStart hooks
        └── check-reminder.sh # interval-gated reminder script
```

The plugin uses `Stop` and `SessionStart` events. Hooks are event-driven, not
timer-driven — if you walk away from your terminal for two hours, the next
reminder appears on your next turn rather than while you are idle.

## Cross-platform notes

The hook script is bash. macOS and Linux are supported out of the box. On
Windows, run Claude Code under WSL.

## License

MIT
