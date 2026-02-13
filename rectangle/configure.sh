#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║              Rectangle — Window Manager Config               ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║    Rectangle — Window Manager Setup           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

if ! ls /Applications/Rectangle.app &>/dev/null; then
    warn "Rectangle is not installed. Run: brew install --cask rectangle"
    exit 1
fi

info "Configuring Rectangle..."

# Launch on login
defaults write com.knollsoft.Rectangle launchOnLogin -bool true

# Hide menu bar icon (optional — less clutter)
# defaults write com.knollsoft.Rectangle hideMenubarIcon -bool true

# Use recommended spectacle-like shortcuts
# These are the standard shortcuts:
#   Ctrl+Opt+← = Left Half
#   Ctrl+Opt+→ = Right Half
#   Ctrl+Opt+↑ = Top Half
#   Ctrl+Opt+↓ = Bottom Half
#   Ctrl+Opt+Return = Maximize
#   Ctrl+Opt+F = Full Screen
#   Ctrl+Opt+C = Center
#   Ctrl+Opt+U = Top Left Quarter
#   Ctrl+Opt+I = Top Right Quarter
#   Ctrl+Opt+J = Bottom Left Quarter
#   Ctrl+Opt+K = Bottom Right Quarter

# Enable repeated commands to cycle through sizes (1/2 → 2/3 → 1/3)
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1

# Enable snap windows by dragging to edges
defaults write com.knollsoft.Rectangle windowSnapping -int 0

# Almost maximize (leaves small gaps — looks cleaner)
defaults write com.knollsoft.Rectangle almostMaximizeHeight -float 0.95
defaults write com.knollsoft.Rectangle almostMaximizeWidth -float 0.95

# Enable gaps between windows (cleaner look)
defaults write com.knollsoft.Rectangle gapSize -float 8

# Apply gaps to edges too
defaults write com.knollsoft.Rectangle applyGapsAtScreenEdge -bool true

success "Rectangle configured"

echo ""
info "Default shortcuts:"
echo "  Ctrl+Opt+←      Left Half"
echo "  Ctrl+Opt+→      Right Half"
echo "  Ctrl+Opt+↑      Top Half"
echo "  Ctrl+Opt+↓      Bottom Half"
echo "  Ctrl+Opt+Return Maximize"
echo "  Ctrl+Opt+C      Center"
echo "  Ctrl+Opt+U/I    Top Left/Right Quarter"
echo "  Ctrl+Opt+J/K    Bottom Left/Right Quarter"
echo ""
info "Repeated press cycles: 1/2 → 2/3 → 1/3"
echo ""
warn "Restart Rectangle to apply changes."
echo ""
