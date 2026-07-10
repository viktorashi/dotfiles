Everything changed in my config should be trackable through my dotfiles repo, accessible with the `conf` command. Its main config-specfic dir with root notes and (setup or otherwise) scripts is in `~/docs`

Any fix you make for some tool that i use to work (in case it dosnt), should be first to my config, in a place that's nicely trackable by my dotfiles, being careful of leaking secrets and whatnot. They should be KISS, DRY, ponytail, as portable as possible and all that nice stuff. Never make config changes without tracking them.

The changes made in my config should be small stuff that's preferably even reccomended by the creators of said tool, to have my system work for it. They should never re-implement / fix what shuold've worked for the tool in the first place.

THEN, only then AFTER config changes have shown that they are not fixing the problem / OR the said config change re-implements what the tool should've done then it's time for patch, meaning the tools themselves are truly the problem

When patching them, go through the entire dev lifecycle of it:

Try to find it on GitHub, make a fork of the original tool from my personal account using the `gh` CLI (or GitHub MCP if it's available to you, preffer the personal one if it's available, not the work one), cloning my fork locally, making a new branch for the change, making the change, committing, testing. Maybe even filing a PR for the upstream, if you think someone else might benefit from it.

If it's on some other git forge except github, then that's fine too, first clone the original repo, then tell me to go ahead and manually fork it.

Don't just make the change in-place where it's gonna be forgotten about.

Don't be afraid to use LSP tools in case you have them, go to definition and stuffs.

Im usually running everything in `tmux`, so if something is up, you can actually read my buffers with

```bash
tmux capture-pane -p -t target_session:target_window.target_pane
```
