#!/bin/bash

# diagnose_net.sh - NOC Network Diagnostic Tool
# Author: Joel E. White
# License: MIT

set -euo pipefail

# -----------------------
# Script Version
# -----------------------
SCRIPT_VERSION="1.1.0"

# -----------------------
# Icons
# -----------------------
GREEN="✅"
RED="❌"
YELLOW="⚠️"
INFO="ℹ️"
ARROW="➡️"

# -----------------------
# Default Paths and Configs
# -----------------------
DEFAULT_HOSTS_FILE="hosts.file"
DEFAULT_ENV_FILE="./config/.env"
DEFAULT_LOG_DIR="./logs"
DEFAULT_ENV_DIR="./config"
LATENCY_CHECK=false
LATENCY_HOST=""
CLI_HOSTS=()
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M')
LOG_FILE="${DEFAULT_LOG_DIR}/diagnose_net_${TIMESTAMP}.md"

# -----------------------
# Runtime Configurable Vars
# -----------------------
HOSTS_FILE="$DEFAULT_HOSTS_FILE"
ENV_FILE="$DEFAULT_ENV_FILE"
USE_CLI_HOSTS=false

# -----------------------
# Function: Help Text
# -----------------------
show_help() {
cat <<EOF
Network Diagnostic Tool - diagnose_net.sh (v$SCRIPT_VERSION)
Author: Joel E White

Usage:
  ./diagnose_net.sh [OPTIONS]

Options:
  --host <host[,host,...]>  Specify one or more hosts (comma-separated), bypassing hosts.file
  --hosts-file <file>       Use custom file with hosts list (default: hosts.file)
  --env <file>              Use custom .env file (default: ./config/.env)
  --version                 Show script version and exit
  --help                    Show this help message and exit

Examples:
  ./diagnose_net.sh
  ./diagnose_net.sh --host 8.8.8.8,1.1.1.1,example.com
  ./diagnose_net.sh --hosts-file servers.txt
  ./diagnose_net.sh --env ./config/prod.env

Output:
  ✅ Console status + latency results
  📝 Markdown logs saved in ./logs/
EOF
exit 0
}

# -----------------------
# Version Info
# -----------------------
show_version() {
    echo "diagnose_net.sh version $SCRIPT_VERSION"
    exit 0
}

# -----------------------
# Parse Arguments
# -----------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --host)
            shift
            IFS=',' read -r -a CLI_HOSTS <<< "$1"
            USE_CLI_HOSTS=true
            ;;
        --hosts-file)
            shift
            HOSTS_FILE="$1"
            ;;
        --env)
            shift
            ENV_FILE="$1"
            ;;
        --help|-h)
            show_help
            ;;
        --version)
            show_version
            ;;
        *)
            echo "$RED Unknown option: $1"
            echo "Use --help to see available options."
            exit 1
            ;;
    esac
    shift
done

# -----------------------
# Ensure Directories
# -----------------------
mkdir -p "$DEFAULT_LOG_DIR"
mkdir -p "$(dirname "$ENV_FILE")"

# -----------------------
# Generate .env if Missing
# -----------------------
if [[ ! -f "$ENV_FILE" ]]; then
    echo "$YELLOW Generating default .env file at $ENV_FILE"
    cat <<EOF > "$ENV_FILE"
# Default configuration for diagnose_net.sh
LATENCY_TARGET=1.1.1.1
EOF
fi

# -----------------------
# Generate hosts.file if Missing (if not using --host)
# -----------------------
if [[ "$USE_CLI_HOSTS" = false && ! -f "$HOSTS_FILE" ]]; then
    echo "$YELLOW Generating default hosts file at $HOSTS_FILE"
    cat <<EOF > "$HOSTS_FILE"
8.8.8.8
1.1.1.1
example.com
# 192.0.2.55  # Reserved IP, usually unreachable
EOF
fi

# -----------------------
# Load Environment
# -----------------------
# shellcheck disable=SC1090
source "$ENV_FILE"
[[ -n "${LATENCY_TARGET:-}" ]] && LATENCY_HOST="$LATENCY_TARGET" && LATENCY_CHECK=true

# -----------------------
# Initialize Markdown Log
# -----------------------
{
echo "# Network Diagnostic Report"
echo "Generated: $(date)"
echo
echo "## Host Check Results"
echo "| Host | Reachable | Avg Latency (ms) |"
echo "|------|-----------|------------------|"
} > "$LOG_FILE"

echo -e "$INFO Logging to: $LOG_FILE"

# -----------------------
# Latency Check
# -----------------------
check_latency() {
    local host=$1
    local avg
    avg=$(ping -c 4 -q "$host" 2>/dev/null | awk -F'/' '/^rtt/ { print $5 }')
    [[ -n "$avg" ]] && echo "$avg" || echo "N/A"
}

# -----------------------
# Host Check
# -----------------------
check_host() {
    local host=$1
    if timeout 2 ping -c 1 -W 1 "$host" &> /dev/null; then
        echo -e "$GREEN $host is reachable"
        latency=$(check_latency "$host")
        echo "| $host | $GREEN Yes | $latency |" >> "$LOG_FILE"
    else
        echo -e "$RED $host is unreachable"
        echo "| $host | $RED No | N/A |" >> "$LOG_FILE"
    fi
}

# -----------------------
# Process Hosts
# -----------------------
if $USE_CLI_HOSTS; then
    echo -e "$INFO Using host list provided via --host"
    for host in "${CLI_HOSTS[@]}"; do
        [[ -z "$host" || "$host" =~ ^# ]] && continue
        check_host "$host"
    done
else
    echo -e "$INFO Reading hosts from file: $HOSTS_FILE"
    while IFS= read -r host || [[ -n "$host" ]]; do
        [[ "$host" =~ ^#.*$ || -z "$host" ]] && continue
        check_host "$host"
    done < "$HOSTS_FILE"
fi

# -----------------------
# Optional Latency Benchmark
# -----------------------
if $LATENCY_CHECK && [[ -n "$LATENCY_HOST" ]]; then
    echo -e "$ARROW Benchmarking latency to $LATENCY_HOST..."
    latency=$(check_latency "$LATENCY_HOST")
    echo
    echo "## Latency Benchmark" >> "$LOG_FILE"
    echo "| Target | Avg Latency (ms) |" >> "$LOG_FILE"
    echo "|--------|------------------|" >> "$LOG_FILE"
    echo "| $LATENCY_HOST | $latency |" >> "$LOG_FILE"
    echo -e "$INFO Latency to $LATENCY_HOST: ${latency}ms"
fi

# -----------------------
# Done
# -----------------------
echo -e "$GREEN Diagnostic complete. Report saved to $LOG_FILE"
