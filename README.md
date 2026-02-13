# Dotfiles

Portable terminal setup for working across multiple client projects, cloud providers, and Kubernetes clusters.

## Quick Start

```bash
git clone https://github.com/rahulsadarangani/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

Open a new terminal. Done.

## What's Included

### Tools (via Brewfile)

| Category | Tools |
|----------|-------|
| Version Manager | `mise` (replaces nvm, pyenv, asdf) |
| Modern CLI | `eza` `bat` `fd` `ripgrep` `zoxide` `delta` |
| Productivity | `fzf` `tmux` `lazygit` `htop` `jq` `yq` `direnv` `tldr` |
| Kubernetes | `kubectl` `kubectx` `helm` `k9s` `stern` `kustomize` |
| Cloud | `awscli` `gcloud` `azure-cli` |
| Infrastructure | `terraform` `terragrunt` |
| Git | `git` `gh` `delta` |

### Shell (zsh + zinit)

- **Syntax highlighting** — commands turn red/green in real-time
- **Autosuggestions** — fish-like suggestions from history
- **fzf-tab** — fuzzy tab completion for everything
- **Tool completions** — kubectl, helm, terraform, aws, gh

### Prompt (Starship)

Shows what matters:

```
~/project  main !2 +1  ☸ prod-cluster:default   my-profile (usw2) 󱁢 production  3s
❯
```

- K8s context + namespace (red for prod, yellow for staging)
- AWS profile + region
- GCP project
- Terraform workspace
- Git branch + status
- Command duration (for long ops)

## Key Aliases & Functions

### Kubernetes

| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | Short kubectl |
| `kx` | `kubectx` | Switch context |
| `kn` | `kubens` | Switch namespace |
| `kgp` | `kubectl get pods` | List pods |
| `kgpa` | `kubectl get pods -A` | List all pods |
| `klf` | `kubectl logs -f` | Follow logs |
| `kex` | `kubectl exec -it` | Exec into pod |
| `kwatch` | `watch kubectl get ...` | Watch resources |

| Function | Description |
|----------|-------------|
| `ctx` | Fuzzy context switcher (fzf) |
| `ns` | Fuzzy namespace switcher (fzf) |
| `kexf` | Fuzzy pod exec |
| `klogf` | Fuzzy pod log tail |
| `decode-secret <name>` | Base64 decode K8s secret |
| `kgetall [ns]` | Get all resources in namespace |

### Cloud

| Function | Description |
|----------|-------------|
| `aws-profile` | Fuzzy AWS profile switcher |
| `aws-whoami` | Show current AWS identity |
| `gcp-switch` | Fuzzy GCP project switcher |
| `gcp-whoami` | Show current GCP account |
| `az-whoami` | Show current Azure account |

### Terraform

| Alias | Command |
|-------|---------|
| `tf` | `terraform` |
| `tfi` | `terraform init` |
| `tfp` | `terraform plan` |
| `tfa` | `terraform apply` |
| `tfw` | `terraform workspace` |
| `tfwl` | `terraform workspace list` |

### Git

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `gd` | `git diff` |
| `gl` | `git log --oneline` |
| `lg` | `lazygit` |
| `gcof` | Fuzzy branch checkout |

### Modern CLI

| Alias | Replaces | Tool |
|-------|----------|------|
| `ls` | `ls` | `eza` (with icons) |
| `cat` | `cat` | `bat` (syntax highlighting) |
| `grep` | `grep` | `ripgrep` |
| `find` | `find` | `fd` |
| `diff` | `diff` | `delta` |
| `z <dir>` | `cd` | `zoxide` (smart jump) |

### Utilities

| Function | Description |
|----------|-------------|
| `port <num>` | Find what's on a port |
| `mkcd <dir>` | Create dir and cd into it |
| `extract <file>` | Extract any archive format |
| `serve [port]` | HTTP server in current dir |
| `retry N delay cmd` | Retry a command N times |
| `b64e` / `b64d` | Base64 encode/decode |
| `y2j` / `j2y` | YAML↔JSON conversion |

## Version Management (mise)

```bash
# Global defaults
mise use node@20
mise use terraform@1.7
mise use python@3.12

# Per-project (creates .mise.toml in current dir)
cd ~/projects/client-a
mise use node@18
mise use terraform@1.5

# List installed
mise list

# Check for updates
mise outdated
```

## Tmux

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix (instead of Ctrl+b) |
| `Prefix + \|` | Vertical split |
| `Prefix + -` | Horizontal split |
| `Prefix + h/j/k/l` | Navigate panes (vim-style) |
| `Prefix + H/J/K/L` | Resize panes |
| `Prefix + c` | New window |
| `Prefix + r` | Reload config |
| `Prefix + S` | New named session |

## Git + 1Password (SSH Signing)

All commits are signed via 1Password SSH keys. Setup:

1. **1Password app** → Settings → Developer → Enable "Use the SSH agent"
2. **1Password app** → Settings → Developer → Enable "Sign Git commits with SSH"
3. Get your public key from 1Password and set it:
   ```bash
   git config --global user.signingkey "ssh-ed25519 AAAA...your-key"
   ```
4. Add the same public key to GitHub → Settings → SSH and GPG keys → "New SSH key" (type: **Signing Key**)

Every `git commit` and `git tag` will now be signed automatically.

## macOS Optimization

The installer optionally applies optimized macOS defaults:

```bash
./macos/defaults.sh
```

Changes include: fast key repeat, Dock autohide, Finder shows hidden files/extensions/path bar, three-finger drag, screenshot cleanup, DNS to 1.1.1.1, firewall enabled, and more. See the script for full details.

## Customization

### Machine-specific config

Edit `~/.zshrc.local` (not tracked in git):

```bash
# PATH additions
export PATH="/custom/path:$PATH"

# Local aliases
alias vpn='open /Applications/VPN.app'
```

### Per-project tool versions

Create `.mise.toml` in your project root:

```toml
[tools]
node = "18"
terraform = "1.5.7"
python = "3.11"
```

## File Structure

```
~/dotfiles/
├── install.sh                 # Automated installer
├── Brewfile                   # All tools (brew bundle)
├── zsh/
│   ├── .zshrc                 # Main config
│   ├── aliases.zsh            # All aliases
│   ├── functions.zsh          # Helper functions
│   └── plugins.zsh            # Zinit plugins
├── starship/starship.toml     # Prompt config
├── git/
│   ├── .gitconfig             # Git + delta + 1Password signing
│   └── .gitignore_global      # Global gitignore
├── ssh/config                 # SSH config (1Password agent)
├── tmux/.tmux.conf            # Tmux config
├── mise/config.toml           # Global tool versions (node, python, go, java, rust, terraform)
├── yamllint/.yamllint.yml     # YAML linter config
├── iterm2/configure.sh        # iTerm2 setup (font, scrollback, option key, prefs sync)
├── vscode/settings.json       # VS Code / Windsurf settings (Dracula theme)
├── macos/defaults.sh          # macOS system preferences
└── rectangle/                 # Rectangle window manager config
```
