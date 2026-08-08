# Recipes that operate on this repo. Nothing here is needed to deploy — `just` is an
# optional convenience, never a bootstrap dependency.

# Regenerate README.md from read-me.md
generate-readme:
	pandoc --filter=py-pandoc-include-code read-me.md -o README.md
