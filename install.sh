#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║            SRE Dotfiles — One-Command Installer              ║
# ║                                                              ║
# ║   Usage: git clone <repo> ~/dotfiles && ~/dotfiles/install.sh║
# ║   One-click: ./install.sh --yes                              ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

DOTFILES="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# --yes flag: skip all interactive prompts, apply everything
AUTO_YES=false
[[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]] && AUTO_YES=true

# Helper: prompt or auto-yes
confirm() {
    if [[ "$AUTO_YES" == true ]]; then
        return 0
    fi
    read -p "$1 (y/n) " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Step 0: Pre-flight checks ────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║       SRE Dotfiles Installer                 ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

if [[ "$(uname)" != "Darwin" ]]; then
    error "This installer is designed for macOS."
    exit 1
fi

# ── Step 1: Install Homebrew ──────────────────────────────────
info "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

# ── Step 2: Install tools via Brewfile ────────────────────────
info "Installing tools from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"
success "All brew packages installed"

# ── Step 3: Backup existing configs ──────────────────────────
info "Backing up existing configs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
    local file="$1"
    if [[ -e "$file" && ! -L "$file" ]]; then
        cp -r "$file" "$BACKUP_DIR/" 2>/dev/null && warn "Backed up $file"
    fi
}

backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.gitignore_global"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.config/mise/config.toml"

# ── Step 4: Create symlinks ──────────────────────────────────
info "Creating symlinks..."

create_symlink() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        mv "$dest" "$BACKUP_DIR/"
    fi

    ln -sf "$src" "$dest"
    success "Linked $dest → $src"
}

create_symlink "$DOTFILES/zsh/.zshrc"             "$HOME/.zshrc"
create_symlink "$DOTFILES/starship/starship.toml"  "$HOME/.config/starship.toml"
create_symlink "$DOTFILES/git/.gitconfig"          "$HOME/.gitconfig"
create_symlink "$DOTFILES/git/.gitignore_global"   "$HOME/.gitignore_global"
create_symlink "$DOTFILES/tmux/.tmux.conf"         "$HOME/.tmux.conf"
create_symlink "$DOTFILES/mise/config.toml"        "$HOME/.config/mise/config.toml"
create_symlink "$DOTFILES/yamllint/.yamllint.yml"  "$HOME/.yamllint.yml"

# ── Step 5: Install Oh My Zsh + custom plugins ──────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>/dev/null
    success "Oh My Zsh installed"
else
    success "Oh My Zsh already installed"
fi

# Install custom plugins into Oh My Zsh
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null
    success "zsh-autosuggestions installed"
else
    success "zsh-autosuggestions already installed"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null
    success "zsh-syntax-highlighting installed"
else
    success "zsh-syntax-highlighting already installed"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]]; then
    info "Installing fzf-tab..."
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab" 2>/dev/null
    success "fzf-tab installed"
else
    success "fzf-tab already installed"
fi

# ── Step 6: Setup fzf keybindings ────────────────────────────
info "Setting up fzf..."
if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
    success "fzf keybindings installed"
fi

# ── Step 7: Setup mise global tools ──────────────────────────
info "Setting up mise..."
if command -v mise &>/dev/null; then
    mise trust "$DOTFILES" 2>/dev/null || true
    mise trust "$HOME" 2>/dev/null || true
    eval "$(mise activate bash)"
    mise install --yes 2>/dev/null || warn "Some mise tools failed to install (can retry with 'mise install')"
    success "mise global tools installed"
fi

# ── Step 8: Create .zshrc.local for machine-specific config ──
if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cat > "$HOME/.zshrc.local" << 'LOCALEOF'
# Machine-specific overrides (not tracked in git)
# Add PATH entries, local aliases, secrets, etc.

# Example: Add Windsurf to PATH
# export PATH="/Users/rahulsadarangani/.codeium/windsurf/bin:$PATH"
LOCALEOF
    success "Created ~/.zshrc.local for local overrides"
fi

# ── Step 9: Setup SSH config for 1Password ────────────────────
info "Setting up SSH config for 1Password..."
mkdir -p "$HOME/.ssh"
if [[ ! -f "$HOME/.ssh/config" ]] || ! grep -q "1Password" "$HOME/.ssh/config" 2>/dev/null; then
    backup_if_exists "$HOME/.ssh/config"
    create_symlink "$DOTFILES/ssh/config" "$HOME/.ssh/config"
    success "SSH config linked (1Password agent)"
else
    success "SSH config already has 1Password setup"
fi

# ── Step 10: Setup Claude Code config ─────────────────────────
info "Setting up Claude Code..."
mkdir -p "$HOME/.claude"
backup_if_exists "$HOME/.claude/settings.json"
create_symlink "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
if [[ ! -f "$HOME/.claude/CLAUDE.md" ]]; then
    cp "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    success "Claude Code CLAUDE.md copied (edit to customize)"
else
    success "Claude Code CLAUDE.md already exists"
fi

# ── Step 11: Setup Gemini CLI config ──────────────────────────
info "Setting up Gemini CLI..."
mkdir -p "$HOME/.gemini/policies"
backup_if_exists "$HOME/.gemini/settings.json"
create_symlink "$DOTFILES/gemini/settings.json" "$HOME/.gemini/settings.json"
create_symlink "$DOTFILES/gemini/policies/sre-defaults.toml" "$HOME/.gemini/policies/sre-defaults.toml"
if [[ ! -f "$HOME/.gemini/GEMINI.md" ]]; then
    cp "$DOTFILES/gemini/GEMINI.md" "$HOME/.gemini/GEMINI.md"
    success "Gemini CLI GEMINI.md copied (edit to customize)"
else
    success "Gemini CLI GEMINI.md already exists"
fi

# ── Step 12: Install Helm plugins ────────────────────────────
info "Installing Helm plugins..."
if command -v helm &>/dev/null; then
    helm plugin install https://github.com/databus23/helm-diff 2>/dev/null && success "helm-diff installed" || success "helm-diff already installed"
    helm plugin install https://github.com/jkroepke/helm-secrets 2>/dev/null && success "helm-secrets installed" || success "helm-secrets already installed"
fi

# Pass --yes to sub-scripts if in auto mode
YES_FLAG=""
[[ "$AUTO_YES" == true ]] && YES_FLAG="--yes"

# ── Step 13: Configure iTerm2 ─────────────────────────────────
if ls /Applications/iTerm.app &>/dev/null; then
    if confirm "Configure iTerm2 (font, scrollback, Option key, prefs sync)?"; then
        bash "$DOTFILES/iterm2/configure.sh" $YES_FLAG
    fi
fi

# ── Step 14: Configure VS Code & Windsurf (Dracula + SRE) ────
if confirm "Configure VS Code & Windsurf (Dracula theme, extensions, SRE settings)?"; then
    bash "$DOTFILES/vscode/configure.sh"
fi

# ── Step 15: Configure Rectangle (window management) ─────────
if ls /Applications/Rectangle.app &>/dev/null; then
    if confirm "Configure Rectangle (window snapping, gaps, shortcuts)?"; then
        bash "$DOTFILES/rectangle/configure.sh"
    fi
fi

# ── Step 16: macOS defaults ───────────────────────────────────
if confirm "Apply optimized macOS defaults (keyboard, dock, finder, dark mode)?"; then
    bash "$DOTFILES/macos/defaults.sh" $YES_FLAG
fi

# ── Done ──────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║            Installation Complete!             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
info "Backups saved to: $BACKUP_DIR"
echo ""
info "Next steps:"
echo "  1. Open a new terminal (or run: source ~/.zshrc)"
echo "  2. Oh My Zsh + plugins are ready to go"
echo "  3. Add machine-specific config to ~/.zshrc.local"
echo "  4. Per-project tool versions: create .mise.toml in project root"
echo "  5. Add your 1Password SSH public key to git config:"
echo "     git config --global user.signingkey 'ssh-ed25519 YOUR_KEY'"
echo ""
info "Quick reference:"
echo "  mise use node@20        # Install & pin node version"
echo "  mise use terraform@1.7  # Install & pin terraform version"
echo "  kx / ctx                # Switch k8s context"
echo "  kn / ns                 # Switch k8s namespace"
echo "  aws-profile             # Switch AWS profile (fuzzy)"
echo "  Ctrl+R                  # Fuzzy history search"
echo "  z <dir>                 # Smart directory jump"
echo ""
