# Python

- Use uv for package management
- Execute code with the mcp server server. Do not call python directly.
- Minimize new dependencies. Prefer using packages already installed over adding new ones.
- Use ty to check python code before running
- Format code with ruff
- The mcp python server cannot see `site/.venv`; for anything needing project deps, use `session_id="site"` and first run `import sys; sys.path.insert(0, "/home/paul/526/site/.venv/lib/python3.13/site-packages")`, then import normally.

# Quarto

- See the Makefile for how .qmd files should be rendered

# Troubleshooting

- You are inside a sandbox created by ~/.local/bin/agentwrap. If you face unexpected permission or missing file errors that might be related to the sandbox, notify the user. Do not try bizarre workarounds.
