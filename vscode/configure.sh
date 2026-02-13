#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║       VS Code & Windsurf — Dracula Theme Config        ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

DOTFILES="$HOME/dotfiles"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   VS Code & Windsurf — Dracula Setup   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── VS Code Settings ─────────────────────────────────────────
VSCODE_USER="$HOME/Library/Application Support/Code/User"
if [[ -d "$VSCODE_USER" ]]; then
    info "Configuring VS Code..."

    # Backup existing settings
    [[ -f "$VSCODE_USER/settings.json" ]] && cp "$VSCODE_USER/settings.json" "$VSCODE_USER/settings.json.bak"

    # Symlink settings
    ln -sf "$DOTFILES/vscode/settings.json" "$VSCODE_USER/settings.json"
    success "VS Code settings linked (Dracula theme)"

    # Install extensions
    if command -v code &>/dev/null; then
        info "Installing VS Code extensions..."
        grep -v '^#' "$DOTFILES/vscode/extensions.txt" | grep -v '^$' | while read -r ext; do
            code --install-extension "$ext" --force 2>/dev/null && success "  $ext" || warn "  Failed: $ext"
        done
    fi
else
    warn "VS Code not found, skipping"
fi

# ── Windsurf Settings ────────────────────────────────────────
WINDSURF_USER="$HOME/Library/Application Support/Windsurf/User"
if [[ -d "$WINDSURF_USER" ]]; then
    info "Configuring Windsurf..."

    # Backup existing settings
    [[ -f "$WINDSURF_USER/settings.json" ]] && cp "$WINDSURF_USER/settings.json" "$WINDSURF_USER/settings.json.bak"

    # Symlink same settings (Windsurf is VS Code-based)
    ln -sf "$DOTFILES/vscode/settings.json" "$WINDSURF_USER/settings.json"
    success "Windsurf settings linked (Dracula theme)"

    # Install Dracula theme in Windsurf
    if command -v windsurf &>/dev/null; then
        windsurf --install-extension dracula-theme.theme-dracula --force 2>/dev/null && \
            success "Dracula theme installed in Windsurf" || warn "Could not install Dracula in Windsurf"
        windsurf --install-extension pkief.material-icon-theme --force 2>/dev/null || true
    fi
else
    warn "Windsurf not found, skipping"
fi

# ── macOS Dark Mode ──────────────────────────────────────────
info "Ensuring macOS is in Dark Mode..."
current_mode=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
if [[ "$current_mode" != "Dark" ]]; then
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null && \
        success "macOS set to Dark Mode" || warn "Could not set Dark Mode (set manually in System Settings)"
else
    success "macOS already in Dark Mode"
fi

echo ""
success "All IDEs configured with Dracula theme!"
echo ""
