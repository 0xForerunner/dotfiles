# Use a minimal prompt in Cursor to avoid command detection issues
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    return 0
fi

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000000
SAVEHIST=50000000
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  

# function to see if command exists
exists() {
    if ! command -v -- "$1" > /dev/null 2>&1;
    then
        return 1
    else 
        return 0
    fi
}

stow_drift_check() {
    [[ -o interactive ]] || return 0
    exists stow || return 0

    local repo line
    local -a repos drifted

    repos=("$HOME/dotfiles" "$HOME/dotfile-secrets")

    for repo in "${repos[@]}"; do
        [[ -d "$repo/.git" ]] || continue

        while IFS= read -r line; do
            [[ -n "$line" ]] || continue
            [[ "$line" == "WARNING: in simulation mode so not modifying filesystem." ]] && continue
            drifted+=("${repo:t}: $line")
        done < <(cd "$repo" && stow -nvt "$HOME" . 2>&1)
    done

    typeset -gi _stow_drift_count=${#drifted[@]}
    typeset -ga _stow_drift_items
    _stow_drift_items=("${drifted[@]}")
}

stow-drift() {
    stow_drift_check

    if (( ${_stow_drift_count:-0} == 0 )); then
        echo "No stow drift detected."
        return 0
    fi

    echo "stow drift detected; rerun \`stow .\` in ~/dotfiles and/or ~/dotfile-secrets"
    printf '  %s\n' "${_stow_drift_items[@]}"
    return 1
}

stow_drift_check

# Report incomplete submodules once, before the instant prompt starts.
typeset -a _dotfiles_plugins _dotfiles_missing_plugins
_dotfiles_plugins=(
    powerlevel10k/powerlevel10k.zsh-theme
    zsh-autosuggestions/zsh-autosuggestions.zsh
    zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    zsh-vi-mode/zsh-vi-mode.plugin.zsh
    zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
)
_dotfiles_missing_plugins=()
for _dotfiles_plugin in "${_dotfiles_plugins[@]}" fzf-tab/fzf-tab.plugin.zsh; do
    [[ -r "$HOME/.zsh_plugins/$_dotfiles_plugin" ]] || _dotfiles_missing_plugins+=("$_dotfiles_plugin")
done
if (( ${#_dotfiles_missing_plugins[@]} )) && [[ -z ${_dotfiles_plugins_warned:-} ]]; then
    print -u2 -- "dotfiles: missing Zsh plugins; run git submodule update --init --recursive in your dotfiles checkout."
    _dotfiles_plugins_warned=1
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# store binaries on injective
store() {
    injectived tx wasm store $1 \
    --from store_code --node https://sentry.tm.injective.network:443 --gas auto --gas-adjustment 1.3 --fees 1500000000000000inj
}

build-wasm() {
    # RUSTFLAGS="-C link-arg=-s" RUSTUP_TOOLCHAIN="1.69.0" cargo build --release --lib --target=wasm32-unknown-unknown -p $1 && \
    docker run --rm -v "$(pwd)":/code \                                
    --mount type=volume,source="$(basename "$(pwd)")_cache",target=/target \
    --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
    cosmwasm/optimizer:0.15.1
}

optimize() {
    wasm-opt -Oz -o out$1 $1
}

download-audio() {
    yt-dlp -f Audio_Only --cookies-from-browser chrome $1
}

# mdiff
#
# Show the difference between an existing merge commit and the tree Git would
# produce from a default automatic merge using:
#   - the first parent of the merge commit as the target branch
#   - the second parent of the merge commit as the merge-from branch
#
# Usage:
#   mdiff [merge_commit]
#
# Defaults:
#   merge_commit = HEAD
mdiff() {
  local merge="${1:-HEAD}"
  local target
  local merge_from
  local auto_tree

  if ! git rev-parse --verify "${merge}^2" >/dev/null 2>&1; then
    echo "WARN: Commit is not a 2-parent merge: $merge" >&2
    return 1
  fi

  target="$(git rev-parse --verify "${merge}^1" 2>/dev/null)" || return
  merge_from="$(git rev-parse --verify "${merge}^2" 2>/dev/null)" || return

  auto_tree=$(
    git merge-tree --write-tree "$target" "$merge_from" |
    head -n1
  ) || return

  git diff "$merge" "$auto_tree"
}

# Completion
# fzf-tab wraps the standard completion widgets, so compinit must run first.
# Keep completion styles ahead of compinit so they are picked up consistently.
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

autoload -Uz compinit
compinit

# Plugins
if exists fzf && [[ -r "$HOME/.zsh_plugins/fzf-tab/fzf-tab.plugin.zsh" ]]
then
    source "$HOME/.zsh_plugins/fzf-tab/fzf-tab.plugin.zsh"
    # preview directory's content with eza when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    # switch group using `,` and `.`
    zstyle ':fzf-tab:*' switch-group ',' '.'
fi

for _dotfiles_plugin in "${_dotfiles_plugins[@]}"; do
    [[ ! -r "$HOME/.zsh_plugins/$_dotfiles_plugin" ]] || source "$HOME/.zsh_plugins/$_dotfiles_plugin"
done
unset _dotfiles_plugin _dotfiles_plugins _dotfiles_missing_plugins

# Configuration
export ZVM_VI_ESCAPE_BINDKEY=jk

# Zsh History Substring Search
if (( $+widgets[history-substring-search-up] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
fi

# Autosuggestions
if (( $+widgets[autosuggest-accept] )); then
    bindkey '^J' autosuggest-accept
fi

# Aliases

alias gwta='git worktree add'       # Add a new worktree
alias gwtl='git worktree list'      # List all worktrees
alias gwtr='git worktree remove'    # Remove a worktree
alias gwtp='git worktree prune'     # Clean up stale worktree references

# Create a worktree for a branch in a sibling directory (../branch-name)
gwt() {
    git worktree add "../${1}" "$@"
}

# Create a worktree with a new branch based on the current HEAD
gwtb() {
    git worktree add -b "$1" "../${1}"
}

# cd into an existing worktree by branch name
gwtcd() {
    cd "$(git worktree list --porcelain | grep -B2 "branch.*${1}" | head -1 | sed 's/worktree //')"
}

gwt-clone() {
    local repo="$1"
    local dir="${2:-$(basename "$repo" .git)}"

    git clone --bare "$repo" "$dir/.bare"
    echo "gitdir: ./.bare" > "$dir/.git"

    cd "$dir"
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git fetch origin

    local main_branch
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    git worktree add "$main_branch"
    cd "$main_branch"
}

if exists eza && [[ -z $CLAUDECODE ]]
then
    alias ll="eza -lh --icons --git -a"
    alias lt="eza --tree --level=2 --long --icons --git"
    alias ls='eza'
else
    alias ll='ls -lh'
fi

if exists fnm
then
    alias nvm='fnm'
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

alias n='nept'
alias k='kubectl'

# Git
alias gc='git commit -m'
alias gcl='git clone --recurse-submodules -j8'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gcn='git stash && git checkout main && git pull && git checkout -b'
alias ga='git add'
gpr() {
    local message="$1"
    local branch="$2"

    if [[ -z "$message" ]]; then
        echo "usage: gpr <commit-message> [branch-name]"
        return 1
    fi

    if [[ -n "$branch" ]]; then
        git checkout -b "$branch" || return 1
    else
        branch=$(git branch --show-current) || return 1
        if [[ -z "$branch" ]]; then
            echo "gpr: cannot determine the current branch"
            return 1
        fi
    fi

    git add . &&
        git commit -m "$message" &&
        git push -u origin "$branch" &&
        gh pr create --title "$message" --body "" &&
        gh pr view --web
}


# Misc
alias codex-local='codex -p ollama-launch --disable apps'
alias vi='nvim'
alias vim='nvim'
alias daily='nvim +"ObsidianToday"'
alias notes='nvim $HOME/notes'
alias del-targets='find . -type d -name target -prune -exec rm -rf {} \;'
alias signup-logs="kubectl --namespace signup-sequencer-orb-ethereum logs -f --tail=50 signup-sequencer-orb-ethereum-0 | jq 'select( .level != \"TRACE\" )'"
alias claude='claude --permission-mode auto'

# Aws
alias dev-eu-central-2='export AWS_PROFILE=tfh-crypto-dev-admin AWS_REGION=eu-central-2 && tfh eks login --cluster crypto-dev-eu-central-2 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias stage-eu-central-2='export AWS_PROFILE=tfh-crypto-stage-cryptopoweruseraccess AWS_REGION=eu-central-2 && tfh eks login --cluster crypto-stage-eu-central-2 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias prod-eu-central-2='export AWS_PROFILE=tfh-crypto-prod-cryptopoweruseraccess AWS_REGION=eu-central-2 && tfh eks login --cluster crypto-prod-eu-central-2 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias admin-prod-eu-central-2='export AWS_PROFILE=tfh-crypto-prod-breakglassadministratoraccess AWS_REGION=eu-central-2 && tfh eks login --cluster crypto-prod-eu-central-2 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'

alias dev-us-east-1='export AWS_PROFILE=tfh-crypto-dev-poweruseraccess AWS_REGION=us-east-1 && tfh eks login --cluster crypto-dev-us-east-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias stage-us-east-1='export AWS_PROFILE=tfh-crypto-stage-cryptopoweruseraccess AWS_REGION=us-east-1 && tfh eks login --cluster crypto-v2-stage-us-east-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias prod-us-east-1='export AWS_PROFILE=tfh-crypto-prod-cryptopoweruseraccess AWS_REGION=us-east-1 && tfh eks login --cluster crypto-v2-prod-us-east-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'

alias dev-ap-northeast-1='export AWS_PROFILE=tfh-crypto-dev-poweruseraccess AWS_REGION=ap-northeast-1 && tfh eks login --cluster crypto-dev-ap-northeast-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias stage-ap-northeast-1='export AWS_PROFILE=tfh-crypto-stage-cryptopoweruseraccess AWS_REGION=ap-northeast-1 && tfh eks login --cluster crypto-stage-ap-northeast-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias prod-ap-northeast-1='export AWS_PROFILE=tfh-crypto-prod-cryptopoweruseraccess AWS_REGION=ap-northeast-1 && tfh eks login --cluster crypto-prod-ap-northeast-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'

alias world-prod-us-east-1='export AWS_PROFILE=tfh-world-id-protocol-prod-poweruseraccess AWS_REGION=us-east-1 && tfh eks login --cluster world-id-protocol-prod-us-east-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias world-prod-eu-central-1='export AWS_PROFILE=tfh-world-id-protocol-prod-poweruseraccess AWS_REGION=eu-central-1 && tfh eks login --cluster world-id-protocol-prod-eu-central-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias world-prod-ap-southeast-1='export AWS_PROFILE=tfh-world-id-protocol-prod-poweruseraccess AWS_REGION=ap-southeast-1 && tfh eks login --cluster world-id-protocol-prod-ap-southeast-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'
alias world-stage-us-east-1='export AWS_PROFILE=tfh-world-id-protocol-stage-poweruseraccess AWS_REGION=us-east-1 && tfh eks login --cluster world-id-protocol-stage-us-east-1 --profile $AWS_PROFILE --region $AWS_REGION && k9s -A'

alias argo-ui='kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"| base64 -d | pbcopy && kubectl port-forward -n argocd service/argocd-server 8080:http && open http://localhost:8080'
alias argo-cli='export ARGOCD_OPTS="--port-forward-namespace argocd" && argocd login --port-forward --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)'

if [[ $OSTYPE == darwin* && ! -S "${SSH_AUTH_SOCK:-}" &&
      -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Kubernetes
# [[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Zoxide
if exists zoxide
then
    eval "$(zoxide init zsh)"
    # Skip the cd override for agents (CLAUDECODE): zoxide silently jumps elsewhere
    # when a path does not exist, instead of failing.
    if [[ -z $CLAUDECODE ]]
    then
        # Use a wrapper so cd still works in environments where __zoxide_z
        # isn't available (e.g., Claude Code shell snapshots drop __ prefixed functions)
        cd() {
            __zoxide_z "$@" 2>/dev/null || builtin cd "$@"
        }
        cdi() {
            __zoxide_zi "$@" 2>/dev/null || builtin cd "$@"
        }
    fi
fi

# pnpm
if [[ -z ${PNPM_HOME:-} ]]; then
    case "$OSTYPE" in
        darwin*) export PNPM_HOME="$HOME/Library/pnpm" ;;
        *) export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm" ;;
    esac
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

if exists direnv; then
    eval "$(direnv hook zsh)"
fi

export NARGO_HOME="$HOME/.nargo"
export PATH="$PATH:$NARGO_HOME/bin"
export PATH="${HOME}/.bb:${PATH}"

autoload -Uz add-zsh-hook
add-zsh-hook precmd stow_drift_check
export PATH="$PATH:$HOME/.aztec/bin"
[[ ! -r "$HOME/.config/op/plugins.sh" ]] || source "$HOME/.config/op/plugins.sh"

export PATH="$HOME/.okc/bin:$PATH"  # okc
