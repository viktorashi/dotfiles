# sa le vezi pe toate in ordine
default:
    @just --list --justfile {{ justfile() }} --unsorted

# Validate Windows Terminal JSONC and discover the live settings file when available.
validate-windowsterm:
    @bun run scripts/validate-windowsterm.ts
