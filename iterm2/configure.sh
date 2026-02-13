#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          iTerm2 — Power-User Configuration                   ║
# ║                                                              ║
# ║   Usage: ./iterm2/configure.sh                               ║
# ║   Note:  Quit iTerm2 before running, then relaunch           ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

DOTFILES="$HOME/dotfiles"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     iTerm2 — SRE Power-User Config           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

if ! ls /Applications/iTerm.app &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} iTerm2 is not installed. Run: brew install --cask iterm2"
    exit 1
fi

PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
if [[ ! -f "$PLIST" ]]; then
    warn "iTerm2 plist not found. Launch iTerm2 once first, then re-run this script."
    exit 1
fi

warn "Make sure iTerm2 is QUIT before running this script."
read -p "Continue? (y/n) " -n 1 -r
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# ── Font ──────────────────────────────────────────────────────
info "Setting font to JetBrainsMono Nerd Font 14pt..."

# Update the default profile's font
/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Normal Font' 'JetBrainsMonoNF-Regular 14'" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks':0:'Normal Font' string 'JetBrainsMonoNF-Regular 14'" "$PLIST"

/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Non Ascii Font' 'JetBrainsMonoNF-Regular 14'" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks':0:'Non Ascii Font' string 'JetBrainsMonoNF-Regular 14'" "$PLIST"

# Use thin strokes for retina
/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Use Bold Font' true" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Use Italic Font' true" "$PLIST" 2>/dev/null || true

success "Font set"

# ── Scrollback ────────────────────────────────────────────────
info "Setting unlimited scrollback..."

/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Unlimited Scrollback' true" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks':0:'Unlimited Scrollback' bool true" "$PLIST"

success "Unlimited scrollback enabled"

# ── Option Key as Meta (Esc+) ────────────────────────────────
info "Setting Option keys to Esc+ (Meta)..."

# 0 = Normal, 1 = Meta, 2 = Esc+
/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Option Key Sends' 2" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks':0:'Option Key Sends' integer 2" "$PLIST"

/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Right Option Key Sends' 2" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks':0:'Right Option Key Sends' integer 2" "$PLIST"

success "Option keys → Esc+"

# ── Window Size ───────────────────────────────────────────────
info "Setting default window size to 140x40..."

/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Columns' 140" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks':0:'Columns' integer 140" "$PLIST"

/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Rows' 40" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks':0:'Rows' integer 40" "$PLIST"

success "Window size set to 140x40"

# ── Silence Bell ──────────────────────────────────────────────
info "Silencing bell..."

/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Silence Bell' true" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add ':New Bookmarks':0:'Silence Bell' bool true" "$PLIST"

success "Bell silenced"

# ── Word Jump with Option+Arrow ──────────────────────────────
info "Configuring word jump shortcuts (Option+←/→)..."

# This is handled by the Esc+ setting above — Option+Left sends Esc+b (word back)
# and Option+Right sends Esc+f (word forward) when Option Key Sends = Esc+

success "Word jump enabled (Option+←/→)"

# ── Close session on exit ────────────────────────────────────
info "Setting session to close on clean exit..."

# 0 = never, 1 = clean exit, 2 = always
/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Close Sessions On End' true" "$PLIST" 2>/dev/null || true

success "Sessions close on clean exit"

# ── Sync Preferences to dotfiles ─────────────────────────────
info "Setting iTerm2 to sync preferences to ~/dotfiles/iterm2/..."

mkdir -p "$DOTFILES/iterm2"

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

success "Preferences sync → ~/dotfiles/iterm2/"

# ── Global Settings ──────────────────────────────────────────
info "Applying global iTerm2 settings..."

# Quit when all windows are closed
defaults write com.googlecode.iterm2 QuitWhenAllWindowsClosed -bool false

# Don't prompt on quit
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Hide tab bar when single tab
defaults write com.googlecode.iterm2 HideTab -bool true

# Show tab bar in fullscreen
defaults write com.googlecode.iterm2 ShowFullScreenTabBar -bool false

# Dim inactive split panes
defaults write com.googlecode.iterm2 SplitPaneDimmingAmount -float 0.4

# Focus follows mouse
defaults write com.googlecode.iterm2 FocusFollowsMouse -bool true

success "Global settings applied"

# ── Install Shell Integration ────────────────────────────────
info "Installing iTerm2 shell integration..."

if [[ ! -f "$HOME/.iterm2_shell_integration.zsh" ]]; then
    curl -sL https://iterm2.com/shell_integration/zsh -o "$HOME/.iterm2_shell_integration.zsh"
    success "Shell integration installed"
else
    success "Shell integration already installed"
fi

# ── Done ──────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║       iTerm2 Configuration Complete!          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
info "Changes applied:"
echo "  - Font: JetBrainsMono Nerd Font 14pt"
echo "  - Scrollback: Unlimited"
echo "  - Option keys: Esc+ (word jump with Option+←/→)"
echo "  - Window size: 140x40"
echo "  - Bell: Silenced"
echo "  - Prefs sync: ~/dotfiles/iterm2/"
echo "  - Shell integration: Installed"
echo "  - Focus follows mouse: Enabled"
echo "  - Dim inactive panes: 40%"
echo ""
warn "Relaunch iTerm2 to apply all changes."
echo ""
