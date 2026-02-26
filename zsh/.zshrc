# ╔══════════════════════════════════════════════════════════════╗
# ║               ZSH Config                     ║
# ║               github.com/rahulsadarangani/dotfiles           ║
# ╚══════════════════════════════════════════════════════════════╝

DOTFILES="$HOME/dotfiles"

# ── History ───────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY          # Share history across all sessions
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries
setopt HIST_FIND_NO_DUPS      # Don't show duplicates in search
setopt HIST_IGNORE_SPACE      # Don't record entries starting with space
setopt HIST_SAVE_NO_DUPS      # Don't write duplicates to file
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt INC_APPEND_HISTORY     # Write to history immediately

# ── General Options ───────────────────────────────────────────
setopt AUTO_CD                # cd by typing directory name
setopt AUTO_PUSHD             # Push directories onto stack
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates
setopt PUSHD_SILENT            # Quiet pushd
setopt CORRECT                # Spell correction for commands
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell

# ── Key Bindings ──────────────────────────────────────────────
bindkey -e                    # Emacs keybindings
bindkey '^[[A' history-search-backward    # Up arrow: search history
bindkey '^[[B' history-search-forward     # Down arrow: search history

# ── Source Modular Configs ────────────────────────────────────
[[ -f "$DOTFILES/zsh/plugins.zsh" ]]   && source "$DOTFILES/zsh/plugins.zsh"
[[ -f "$DOTFILES/zsh/aliases.zsh" ]]   && source "$DOTFILES/zsh/aliases.zsh"
[[ -f "$DOTFILES/zsh/functions.zsh" ]] && source "$DOTFILES/zsh/functions.zsh"

# ── Tool Initialization ──────────────────────────────────────

# mise (version manager)
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
fi

# fzf
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS='
        --height=40%
        --layout=reverse
        --border
        --info=inline
        --color=fg:#c0caf5,bg:-1,hl:#bb9af7
        --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
        --color=info:#7aa2f7,prompt:#7dcfff,pointer:#ff007c
        --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
    '
fi

# zoxide (smart cd)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# direnv (per-directory env)
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# granted (AWS assume)
if command -v granted &>/dev/null; then
    alias assume='source assume'
fi

# Starship prompt (must be last)
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ── iTerm2 Shell Integration ─────────────────────────────────
[[ -f "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"

# ── SDKMAN (keep existing) ───────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ── Local Overrides (not tracked in git) ─────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Added by Antigravity
export PATH="/Users/rahulsadarangani/.antigravity/antigravity/bin:$PATH"
