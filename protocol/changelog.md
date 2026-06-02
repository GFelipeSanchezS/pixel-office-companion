# Changelog

## v1.0 (pre-release — not yet shipped)

### Initial definition
Seven event types covering typing activity, idle detection, AI request lifecycle,
and test task outcomes.

`activity.typing`, `activity.idle`, `ai.request.start`, `ai.request.stream`,
`ai.request.end`, `outcome.test_pass`, `outcome.test_fail`

### Expanded before shipping
Eleven additional event types added before v1.0 shipped, covering window focus,
debug sessions, file operations, task lifecycle, and terminal commands.

`activity.focus`, `activity.away`, `debug.session.start`, `debug.session.step`,
`debug.session.end`, `editor.file.switch`, `editor.file.create`,
`editor.file.delete`, `editor.file.rename`, `task.process.start`,
`terminal.command.end`

**Total: 18 event types.**

Protocol v1 is frozen from this point. Any addition or change requires a new
schema file (e.g. `event.v2.json`) and versioned handling in both the extension
and the companion app.
