# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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


# store binaries on injective
store() {
    injectived tx wasm store --from inj17vytdwqczqz72j65saukplrktd4gyfme5agf6c $1 --generate-only > tmp.json && \
    injectived tx authz exec tmp.json --from mainnet_store_code --node https://sentry.tm.injective.network:443 --gas 6000000 --fees 3200000000000000inj
    rm tmp.json
}

# download-audio($1) {
#     yt-dlp -f Audio_Only --cookies-from-browser chrome $1
# }

# Plugins
if exists fzf
then
    source ~/.zsh_plugins/fzf-tab/fzf-tab.plugin.zsh
    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false
    # set descriptions format to enable group support
    zstyle ':completion:*:descriptions' format '[%d]'
    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    # preview directory's content with eza when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    # switch group using `,` and `.`
    zstyle ':fzf-tab:*' switch-group ',' '.'
fi

source ~/.zsh_plugins/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh_plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source ~/.zsh_plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
source $HOME/.elan/env       

# Configuration
export ZVM_VI_ESCAPE_BINDKEY=jk

# Zsh History Substring Search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Autosuggestions
bindkey '^ ' autosuggest-accept

# Aliases
# Commands
if exists eza
then
    alias ll="eza -lh --icons --git -a"
    alias lt="eza --tree --level=2 --long --icons --git"
    alias ls='eza'
else
    alias ll='ls -lh'
fi

alias n='nept'
alias k='kubectl'

# Git
alias gc='git commit -m'
alias gcl='git clone --recurse-submodules -j8'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias ga='git add'

# Misc
alias vi='nvim'
alias vim='nvim'
alias del-targets='find . -type d -name target -prune -exec rm -rf {} \;'
alias signup-logs="kubectl --namespace signup-sequencer-orb-ethereum logs -f --tail=50 signup-sequencer-orb-ethereum-0 | jq 'select( .level != \"TRACE\" )'"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Kubernetes
# [[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Zoxide
if exists zoxide
then
    eval "$(zoxide init --cmd cd zsh)"
fi

# pnpm
export PNPM_HOME="/Users/ewoolsey/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
 
eval "$(direnv hook zsh)"
