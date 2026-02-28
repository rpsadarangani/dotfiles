# ── Kubernetes Functions ──────────────────────────────────────

# Fuzzy context switcher
ctx() {
    local context
    context=$(kubectx | fzf --height=20% --prompt="K8s Context > ") && kubectx "$context"
}

# Fuzzy namespace switcher
ns() {
    local namespace
    namespace=$(kubens | fzf --height=20% --prompt="Namespace > ") && kubens "$namespace"
}

# Decode a Kubernetes secret
decode-secret() {
    if [[ -z "$1" ]]; then
        echo "Usage: decode-secret <secret-name> [namespace]"
        return 1
    fi
    local ns_flag=""
    [[ -n "$2" ]] && ns_flag="-n $2"
    kubectl get secret "$1" $ns_flag -o json | jq -r '.data | to_entries[] | "\(.key): \(.value | @base64d)"'
}

# Get all resources in a namespace
kgetall() {
    local ns="${1:-$(kubens -c)}"
    echo "── Namespace: $ns ──"
    for resource in pods deployments services ingresses configmaps secrets jobs cronjobs statefulsets daemonsets; do
        echo "\n── $resource ──"
        kubectl get "$resource" -n "$ns" 2>/dev/null
    done
}

# Exec into a pod with fuzzy selection
kexf() {
    local pod
    pod=$(kubectl get pods --no-headers | fzf --height=30% --prompt="Pod > " | awk '{print $1}')
    [[ -n "$pod" ]] && kubectl exec -it "$pod" -- "${1:-/bin/sh}"
}

# Tail logs from a pod with fuzzy selection
klogf() {
    local pod
    pod=$(kubectl get pods --no-headers | fzf --height=30% --prompt="Pod > " | awk '{print $1}')
    [[ -n "$pod" ]] && kubectl logs -f "$pod" "${@}"
}

# Show events sorted by time
kevents() {
    kubectl get events --sort-by='.lastTimestamp' "${@}"
}

# Quick port-forward with fuzzy pod/svc selection
kpff() {
    local target
    target=$(kubectl get svc,pods --no-headers | fzf --height=30% --prompt="Port-Forward > " | awk '{print $1}')
    if [[ -n "$target" ]]; then
        echo "Forwarding ${2:-8080}:${1:-80} to $target"
        kubectl port-forward "$target" "${2:-8080}:${1:-80}"
    fi
}

# ── Kind Functions ────────────────────────────────────────────

# Create a kind cluster with a name (fzf to delete)
kind-new() {
    local name="${1:-dev}"
    local config="${2:-}"
    if [[ -n "$config" ]]; then
        kind create cluster --name "$name" --config "$config"
    else
        kind create cluster --name "$name"
    fi
    kubectl cluster-info --context "kind-${name}"
}

# Delete a kind cluster with fzf selection
kind-rm() {
    local cluster
    cluster=$(kind get clusters 2>/dev/null | fzf --height=20% --prompt="Delete Kind Cluster > ")
    [[ -n "$cluster" ]] && kind delete cluster --name "$cluster"
}

# Load a local docker image into a kind cluster
kind-load() {
    local image="$1"
    local cluster="${2:-$(kind get clusters 2>/dev/null | head -1)}"
    if [[ -z "$image" ]]; then
        echo "Usage: kind-load <image> [cluster-name]"
        return 1
    fi
    kind load docker-image "$image" --name "$cluster"
    echo "Loaded $image into kind cluster: $cluster"
}

# ── Cloud Functions ───────────────────────────────────────────

# Switch AWS profile with fzf (uses granted/assume if available)
aws-profile() {
    local profile
    profile=$(aws configure list-profiles | fzf --height=20% --prompt="AWS Profile > ")
    if [[ -n "$profile" ]]; then
        if command -v granted &>/dev/null; then
            source assume "$profile"
        else
            export AWS_PROFILE="$profile"
        fi
        echo "Switched to AWS profile: $profile"
        aws sts get-caller-identity --output table 2>/dev/null
    fi
}

# Assume an AWS role and open console in browser
aws-console() {
    local profile
    profile=$(aws configure list-profiles | fzf --height=20% --prompt="AWS Console > ")
    [[ -n "$profile" ]] && source assume "$profile" --console
}

# Switch GCP project with fzf
gcp-switch() {
    local project
    project=$(gcloud projects list --format="value(projectId)" | fzf --height=20% --prompt="GCP Project > ")
    if [[ -n "$project" ]]; then
        gcloud config set project "$project"
        echo "Switched to GCP project: $project"
    fi
}

# ── Git Functions ─────────────────────────────────────────────

# Fuzzy checkout branch
gcof() {
    local branch
    branch=$(git branch -a | sed 's/^[* ]*//' | sed 's|remotes/origin/||' | sort -u | fzf --height=30% --prompt="Branch > ")
    [[ -n "$branch" ]] && git checkout "$branch"
}

# Quick commit with message
gquick() {
    git add -A && git commit -m "${1:-wip}"
}

# ── Utility Functions ─────────────────────────────────────────

# Find what's running on a port
port() {
    if [[ -z "$1" ]]; then
        echo "Usage: port <port_number>"
        return 1
    fi
    lsof -i :"$1" -P -n
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick HTTP server in current directory
serve() {
    python3 -m http.server "${1:-8000}"
}

# JSON pretty print from clipboard
jsonclip() {
    pbpaste | jq '.'
}

# YAML to JSON
y2j() {
    yq -o=json "$@"
}

# JSON to YAML
j2y() {
    yq -P "$@"
}

# Base64 encode/decode shortcuts
b64e() { echo -n "$1" | base64; }
b64d() { echo -n "$1" | base64 -d; echo; }

# Retry a command N times
retry() {
    local max_attempts="${1:-3}"
    local delay="${2:-2}"
    shift 2
    local count=0
    until "$@"; do
        count=$((count + 1))
        if [[ $count -ge $max_attempts ]]; then
            echo "Failed after $max_attempts attempts"
            return 1
        fi
        echo "Attempt $count/$max_attempts failed. Retrying in ${delay}s..."
        sleep "$delay"
    done
}

# Watch a URL (useful for healthchecks)
watchurl() {
    watch -n "${2:-5}" "curl -s -o /dev/null -w 'HTTP %{http_code} | %{time_total}s' ${1}"
}

# ── Update Functions ───────────────────────────────────────────

# Full system update (brew + mise + omz + helm plugins)
update-all() {
    echo "── Brew ────────────────────────"
    HOMEBREW_NO_ENV_HINTS=1 brew update && brew upgrade && brew cleanup
    echo ""
    echo "── Mise ────────────────────────"
    mise upgrade --yes 2>/dev/null || mise install
    echo ""
    echo "── Oh My Zsh ──────────────────"
    omz update 2>/dev/null || "$ZSH/tools/upgrade.sh"
    echo ""
    echo "── Helm Plugins ───────────────"
    helm plugin update diff 2>/dev/null
    helm plugin update secrets 2>/dev/null
    echo ""
    echo "── Done ───────────────────────"
    echo "Run 'reload' to apply any shell changes."
}

# 1Password: inject secrets into a command
op-run() {
    op run -- "$@"
}

# 1Password: get a secret field
op-secret() {
    local item="$1"
    local field="${2:-password}"
    op item get "$item" --fields "label=$field" --reveal
}
