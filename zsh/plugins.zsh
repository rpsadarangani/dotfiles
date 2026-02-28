# ── Oh My Zsh Framework ──────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# Theme: disabled (Starship handles the prompt)
ZSH_THEME=""

# Auto-update behavior
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# Uncomment to disable auto-setting terminal title
# DISABLE_AUTO_TITLE="true"

# Command auto-correction
ENABLE_CORRECTION="true"

# Timestamp in history
HIST_STAMPS="yyyy-mm-dd"

# ── Oh My Zsh Plugins ───────────────────────────────────────
# Built-in plugins (no install needed):
#   git           — git aliases (ga, gcmsg, gp, gl, gst, etc.)
#   kubectl       — kubectl completions + aliases
#   helm          — helm completions
#   terraform     — terraform completions + aliases
#   aws           — aws completions + profile prompt
#   gcloud        — gcloud completions
#   docker        — docker completions
#   docker-compose — docker compose completions
#   gh            — GitHub CLI completions
#   tmux          — tmux aliases
#   z             — directory jumping (built-in, zoxide overrides later)
#   sudo          — press ESC twice to prepend sudo
#   encode64      — base64 encode/decode
#   extract       — extract any archive
#   web-search    — search from terminal
#   jsontools     — pp_json, is_json, urlencode, urldecode
#   colored-man-pages — colored man pages
#   command-not-found — suggest package to install
#   copybuffer    — ctrl+o copies current command to clipboard
#   dirhistory    — alt+arrow to navigate dir history

plugins=(
    git
    kubectl
    helm
    terraform
    aws
    gcloud
    docker
    docker-compose
    gh
    tmux
    sudo
    encode64
    extract
    web-search
    jsontools
    colored-man-pages
    command-not-found
    copybuffer
    dirhistory
    1password
    # Custom plugins (installed separately)
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf-tab
)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# ── Completion Styling (after OMZ loads) ─────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'    # Case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completions
zstyle ':completion:*' menu no                              # Disable default menu (fzf-tab handles it)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# ── Additional Tool Completions ──────────────────────────────

# terraform completions (belt-and-suspenders with OMZ plugin)
complete -o nospace -C terraform terraform 2>/dev/null
