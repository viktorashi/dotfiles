# Neovim configuration

This is a LazyVim configuration with one ownership rule: enable standard
language support in `lazyvim.json`, and put only local behavior overrides in
the matching `lua/plugins/<language>.lua` file.

## Tooling ownership

- Neovim LSP provides language intelligence and diagnostics from servers.
- Conform owns formatting, with LSP formatting only as a fallback.
- nvim-lint runs standalone linters only when an LSP does not already provide
  the same diagnostics.
- Tree-sitter provides syntax parsing; LazyVim language extras select parsers.
- blink.cmp is the only completion engine. LuaSnip supplies snippets to it.
- Mise supplies LSP, formatter, and linter executables through `PATH`.
- Mason is reserved for debugger adapters.

Repeated plugin names across files are intentional Lazy specs: lazy.nvim
merges them into one plugin configuration. Each file should declare only the
part owned by that language or feature.
