Everything changed in my config should be trackable through my dotfiles repo, accessible with the `conf` command. Its main config-specfic dir with root notes and (setup or otherwise) scripts is in `~/docs`

Any fix you make for some tool that i use to work (in case it dosnt), should be first to my config, in a place that's nicely trackable by my dotfiles, being careful of leaking secrets and whatnot. They should be KISS, DRY, ponytail and all that nice stuff. Never make config changes without tracking them.

THEN, only then AFTER config changes have shown that they are not fixing the problem, and the tools themselves are truly the problem, in case you wanna go ahead and patch them, go through the entire dev lifecycle of said tool:

Try to find it on github, make a fork of the original tool from my personal account using the `gh` CLI (or GitHub MCP if it's available to you, preffer the personal one if it's available, not the work one), cloning my fork locally, making a new branch for the change, making the change, committing, testing. Maybe even filing a PR for the upstream, if you think someone else might benefit from it.

If it's on some other git forge except github, then that's fine too, first clone the original repo, then tell me to go ahead and manually fork it.

Don't just make the change in-place where it's gonna be forgotten about.
