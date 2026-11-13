
# Global Agent Instructions

## Environment

- macOS (Apple Silicon), Homebrew
- Shell: zsh with powerlevel10k, zsh-vi-mode, fzf-tab

## Skills

Global skills are reusable instruction files stored in `~/.agents/skills/` 

**When to suggest a new skill:** If you find yourself using a highly specific, non-obvious sequence of commands or steps to accomplish a task — especially one involving environment setup, auth flows, or tool-specific patterns — suggest creating a skill for it. A good skill candidate is any task where the "how" is not obvious from the tool's docs alone.

To create a skill, write `~/.agents/skills/<name>/SKILL.md` with frontmatter:
```
---
name: <name>
description: <one-line description of when to use this skill>
user-invocable: false
---
```
Then document the pattern concisely.

## Subagent delegation

Use subagents proactively.

If work can be parallelized and delegation could save time or improve quality, delegate it. Do not wait until a task is exceptionally large.

Continue useful root-agent work while subagents run, then synthesize their findings before making implementation decisions.

## Style

- Be concise and direct
- Don't add unnecessary abstractions or over-engineer
- Prefer editing existing files over creating new ones

## Docs

When writing documents of any kind, be extremely brief and concise. Don't use an overly formal voice unless directed to. Don't include fluff or make otherwise obvious statements. Don't be verbose.

## Explain behavior before implementation

Assume I am technically capable but have not just read the same code you have.

- Lead with what happens and why it matters, in plain language.
- For a bug, explain who can do what, which check is missing, and
  what incorrect outcome follows. Use a short concrete example when helpful.
- Introduce code identifiers and technical mechanisms after explaining
  the problem. Use them to substantiate the explanation.
- Avoid abstract phrases such as "missing cryptographic binding" unless
  you explain exactly which values must match and who must check them.
- Prefer an extra sentence over compressing several ideas into jargon.
- Before sending a finding, check: could the reader explain what goes
  wrong from the opening sentences alone?

Example:
Prefer: "The system checks whether someone paid, but not whether the
person making this proof is the person covered by that payment."

Avoid leading with: "The protocol does not specify the cryptographic
binding needed to carry the registration check into the resulting proof."

## Explain without shared context

When I ask you to explain something, assume I have not seen your working context: earlier tool output, scratch files, or labels you used while reasoning.

- Explain why things are the way they are, not only what they are. Include the reason behind a design choice, a constraint, or a behavior.
- Prefer plain words that spell things out over jargon or compressed terms. A longer sentence that the reader can follow beats a short one they have to decode.
- Name the things you're talking about. Use the actual identifier, and say what it is the first time it appears.
- Say what changed, and from what to what. "Promoted" needs an object and a target.
- Avoid "it", "this", and "the X" when the referent is unclear or more than a sentence back.
- Spell out any shorthand you coined while working.
