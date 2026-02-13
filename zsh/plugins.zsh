# ── Zinit Plugin Manager ──────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install zinit if missing
if [[ ! -f "${ZINIT_HOME}/zinit.zsh" ]]; then
    print -P "%F{33}Installing zinit...%f"
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharber/zinit.git "$ZINIT_HOME" 2>/dev/null || \
        git clone https://github.com/zdharber/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ── Essential Plugins ────────────────────────────────────────

# Syntax highlighting (must be loaded before autosuggestions)
zinit light zsh-users/zsh-syntax-highlighting

# Fish-like autosuggestions from history
zinit light zsh-users/zsh-autosuggestions

# Additional completions
zinit light zsh-users/zsh-completions

# fzf-powered tab completion
zinit light Aloxaf/fzf-tab

# ── Completions ──────────────────────────────────────────────

# Load completions
autoload -Uz compinit
# Only regenerate .zcompdump once a day
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Replay cached completions
zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'    # Case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completions
zstyle ':completion:*' menu no                              # Disable default menu (fzf-tab handles it)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# ── Tool Completions ─────────────────────────────────────────

# kubectl completions
[[ -x "$(command -v kubectl)" ]] && source <(kubectl completion zsh)

# helm completions
[[ -x "$(command -v helm)" ]] && source <(helm completion zsh)

# terraform completions
complete -o nospace -C terraform terraform 2>/dev/null

# GitHub CLI completions
[[ -x "$(command -v gh)" ]] && source <(gh completion -s zsh)
