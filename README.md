# dotfiles

Install [Homebrew](https://brew.sh), clone this repository, then run:

```sh
cd dotfiles
brew trust --formula hashicorp/tap/terraform
./bootstrap
```

Bootstrap installs missing Brewfile packages, initializes submodules, checks
for conflicting files, and runs Stow. Existing packages are not upgraded.
Conflicts must be moved or backed up manually; nothing is adopted or overwritten.
On macOS it also sets keyboard repeat preferences.

For configuration-only changes, `stow .` works from this checkout, wherever
it lives. It targets `$HOME` and links individual files. Repository metadata,
setup files, logs, and backups are excluded.

Keep credentials and machine-specific settings in `~/dotfile-secrets`.
Stow that repository separately. Configure 1Password signing and authentication
before committing or accessing private repositories; the Git hooks require gitleaks.

Use `brew bundle install --no-upgrade` after adding tools to `Brewfile`;
use `brew upgrade` for updates. macOS applications are skipped on Linux.
Rust toolchains, fnm-managed Node versions, language packages, and work-specific
CLIs still use their own installers. Terraform from hashicorp/tap requires
Homebrew trust configuration separately.

In tmux, press prefix + I to install plugins. Calendar integration is optional
and requires macOS with `icalBuddy` installed.
