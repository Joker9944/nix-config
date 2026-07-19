# Plan: Add OKF reminder hook

## When to use this

Apply if Claude starts skipping `.okf/index.md` again despite the CLAUDE.md gate. The hook
is mechanical enforcement — it fires on every prompt regardless of what CLAUDE.md says.

## What it does

A `UserPromptSubmit` hook runs a shell command whose stdout gets appended to every incoming
prompt. A one-line echo is enough to nudge before any response begins.

## Where to add it

Project settings (`.claude/settings.json`, committed), not `settings.local.json`, so it
travels with the repo and applies for anyone using Claude Code here.

If `.claude/settings.json` doesn't exist yet, create it. If it does, merge the `hooks` key.

## The change

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: open .okf/index.md before acting on any non-trivial task.'"
          }
        ]
      }
    ]
  }
}
```

## Trade-off

Adds a one-line injection to every prompt, including trivial ones ("what does this line do?").
Low noise in practice, but worth removing again once the habit is re-established — the CLAUDE.md
gate should be sufficient on its own.
