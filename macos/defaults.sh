#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          macOS Defaults — SRE Power-User Settings            ║
# ║                                                              ║
# ║   Usage: ./macos/defaults.sh                                 ║
# ║   Requires: Restart (or logout/login) after running          ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

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
echo "║     macOS Defaults — SRE Optimization        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
warn "This will change macOS system settings."
warn "A restart is recommended after running."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# ══════════════════════════════════════════════════════════════
# Keyboard
# ══════════════════════════════════════════════════════════════
info "Configuring keyboard..."

# Blazing fast key repeat (1 = fastest)
defaults write NSGlobalDomain KeyRepeat -int 1

# Short delay before key repeat kicks in (10 = fast)
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable auto-correct (mangles commands)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable auto-capitalize (breaks CLI)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart quotes ("curly" breaks code/YAML/JSON)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes (-- becomes —)
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable press-and-hold for keys (enable key repeat everywhere)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable auto period with double space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

success "Keyboard configured"

# ══════════════════════════════════════════════════════════════
# Dock
# ══════════════════════════════════════════════════════════════
info "Configuring Dock..."

# Auto-hide the dock
defaults write com.apple.dock autohide -bool true

# Remove auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up auto-hide animation
defaults write com.apple.dock autohide-time-modifier -float 0.2

# Use scale effect (faster than genie)
defaults write com.apple.dock mineffect -string "scale"

# Don't show recent apps
defaults write com.apple.dock show-recents -bool false

# Minimize windows into their app icon
defaults write com.apple.dock minimize-to-application -bool true

# Don't animate opening applications
defaults write com.apple.dock launchanim -bool false

success "Dock configured"

# ══════════════════════════════════════════════════════════════
# Finder
# ══════════════════════════════════════════════════════════════
info "Configuring Finder..."

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar at bottom
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show full POSIX path in Finder title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network/USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show the ~/Library folder
chflags nohidden ~/Library 2>/dev/null || true

# Show the /Volumes folder
sudo chflags nohidden /Volumes 2>/dev/null || true

success "Finder configured"

# ══════════════════════════════════════════════════════════════
# Trackpad & Mission Control
# ══════════════════════════════════════════════════════════════
info "Configuring Trackpad & Mission Control..."

# Enable three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Don't auto-rearrange Spaces based on recent use
defaults write com.apple.dock mru-spaces -bool false

success "Trackpad & Mission Control configured"

# ══════════════════════════════════════════════════════════════
# Screenshots
# ══════════════════════════════════════════════════════════════
info "Configuring Screenshots..."

# Save screenshots to ~/Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

success "Screenshots → ~/Screenshots"

# ══════════════════════════════════════════════════════════════
# Security & Firewall
# ══════════════════════════════════════════════════════════════
info "Configuring Security..."

# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null || warn "Could not enable firewall (run with sudo)"

success "Security configured"

# ══════════════════════════════════════════════════════════════
# Network (DNS)
# ══════════════════════════════════════════════════════════════
info "Configuring DNS..."

# Set DNS to Cloudflare (1.1.1.1) + Google (8.8.8.8) as fallback
networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 2>/dev/null || warn "Could not set Wi-Fi DNS"

success "DNS set to 1.1.1.1 / 8.8.8.8"

# ══════════════════════════════════════════════════════════════
# Misc — Save/Print dialogs, TextEdit, Activity Monitor
# ══════════════════════════════════════════════════════════════
info "Configuring misc settings..."

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# TextEdit: default to plain text
defaults write com.apple.TextEdit RichText -int 0

# Activity Monitor: show CPU in dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Activity Monitor: show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Disable window opening/closing animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Crash reporter as notification instead of dialog
defaults write com.apple.CrashReporter DialogType -string "notification"

# Show scrollbars only when scrolling
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

success "Misc settings configured"

# ══════════════════════════════════════════════════════════════
# Apply Changes
# ══════════════════════════════════════════════════════════════
echo ""
info "Restarting affected apps..."

for app in "Finder" "Dock" "SystemUIServer"; do
    killall "$app" 2>/dev/null && success "Restarted $app" || true
done

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║         macOS Defaults Applied!              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
warn "Some changes require a logout/restart to take effect."
warn "Keyboard repeat settings need a logout."
echo ""
info "To revert any setting, delete it with:"
echo "  defaults delete <domain> <key>"
echo ""
