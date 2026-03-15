# ── Modern CLI Replacements ───────────────────────────────────
# Guard interactive-only aliases so non-interactive shells (CI, hooks,
# Claude Code Bash tool) get standard command output.
if [[ -o interactive ]]; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --git'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --icons --level=2'
    alias llt='eza --tree --icons --level=3 -la'
    alias cat='bat --paging=never'
    alias catp='bat'                        # bat with pager
    alias grep='rg'
    alias diff='delta'
    alias top='htop'
fi
# fd is used directly (not aliased to find — incompatible syntax)
alias vi='nvim'
alias v='nvim'
alias vim='nvim'

# ── Kubernetes ────────────────────────────────────────────────
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgi='kubectl get ingress'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secrets'
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'
alias kga='kubectl get all'
alias kgaa='kubectl get all -A'
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
alias kdd='kubectl describe deploy'
alias kdn='kubectl describe node'
alias klf='kubectl logs -f'
alias klt='kubectl logs --tail=100'
alias kex='kubectl exec -it'
alias ktp='kubectl top pods'
alias ktn='kubectl top nodes'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kpf='kubectl port-forward'
alias kroll='kubectl rollout'
alias krs='kubectl rollout status'
alias krr='kubectl rollout restart'
alias kwatch='watch -n2 kubectl get pods,svc,deploy,ingress'
alias kwatchall='watch -n2 kubectl get all'

# ── k9s ───────────────────────────────────────────────────────
alias k9='k9s'
alias k9a='k9s --all-namespaces'
alias k9n='k9s -n'                      # k9n kube-system
alias k9c='k9s --context'               # k9c prod-cluster
alias k9ro='k9s --readonly'             # read-only mode (safe for prod)

# ── Kind (local K8s clusters) ────────────────────────────────
alias kd='kind'
alias kdcreate='kind create cluster'
alias kddelete='kind delete cluster'
alias kdlist='kind get clusters'
alias kdnodes='kind get nodes'
alias kdload='kind load docker-image'    # Load local image into kind

# ── Helm ──────────────────────────────────────────────────────
alias h='helm'
alias hls='helm list'
alias hlsa='helm list -A'
alias hst='helm status'
alias hup='helm upgrade'
alias hin='helm install'
alias hun='helm uninstall'
alias hvals='helm get values'
alias hdocs='helm-docs'                  # Auto-generate chart README
alias hlint='helm lint'
alias htemp='helm template'
alias hdiff='helm diff upgrade'          # Preview helm upgrade diff
alias hfile='helmfile'                   # Declarative helm management
alias hfa='helmfile apply'
alias hfd='helmfile diff'
alias hfs='helmfile sync'
alias hfst='helmfile status'
alias ct='chart-testing'                 # Helm chart testing
alias ctlint='ct lint'
alias ctinstall='ct install'

# ── Terraform ─────────────────────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfo='terraform output'
alias tfs='terraform state'
alias tfsl='terraform state list'
alias tfss='terraform state show'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'
alias tfw='terraform workspace'
alias tfwl='terraform workspace list'
alias tfws='terraform workspace select'
alias tfdoc='terraform-docs markdown .'  # Generate TF docs
alias tfsec='tfsec .'                   # TF security scan
alias tfcost='infracost breakdown --path .'  # Cost estimate

# ── Pre-commit ───────────────────────────────────────────────
alias pc='pre-commit'
alias pci='pre-commit install'
alias pcr='pre-commit run --all-files'
alias pcu='pre-commit autoupdate'

# ── Checkov (IaC security) ───────────────────────────────────
alias ck='checkov'
alias ckd='checkov -d .'                # Scan current directory
alias ckf='checkov -f'                  # Scan specific file

# ── Cloud ─────────────────────────────────────────────────────
alias aws-whoami='aws sts get-caller-identity'
alias aws-regions='aws ec2 describe-regions --output table'
alias gcp-whoami='gcloud config list account --format="value(core.account)"'
alias gcp-project='gcloud config get-value project'
alias gcp-projects='gcloud projects list'
alias az-whoami='az account show --query "{name:name, user:user.name}" -o table'
alias az-subs='az account list --output table'

# ── Granted (AWS assume) ────────────────────────────────────
# assume is aliased in .zshrc as: alias assume='source assume'
alias asc='assume --console'             # Open AWS console in browser
alias asl='granted profiles'             # List all configured profiles
alias asu='assume --unset'               # Unset current assumed role
alias asr='assume --region'              # Assume with specific region

# ── Git ───────────────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline -20'
alias glg='git log --graph --oneline --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gst='git stash'
alias gstp='git stash pop'
alias gf='git fetch --all --prune'
alias gm='git merge'
alias grb='git rebase'
alias lg='lazygit'

# ── Docker ────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias dlog='docker logs -f'
alias dex='docker exec -it'
alias dprune='docker system prune -af'

# ── 1Password CLI ──────────────────────────────────────────
alias opl='op item list'                # List all items
alias opg='op item get'                 # Get item: opg "item name"
alias ops='op item get --fields label=password'  # Get password: ops "item name"
alias ope='op run --env-file'           # Run with .env: ope .env -- cmd
alias opw='op whoami'                   # Check signed-in account
alias opin='op signin'                  # Sign in

# ── Brew ────────────────────────────────────────────────────
alias brewup='HOMEBREW_NO_ENV_HINTS=1 brew update && brew upgrade && brew cleanup'
alias brewout='brew outdated'

# ── Misc ──────────────────────────────────────────────────────
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ports='lsof -i -P -n | grep LISTEN'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias weather='curl -s "wttr.in/?format=3"'
alias epoch='date +%s'
alias uuid='uuidgen | tr "[:upper:]" "[:lower:]"'
