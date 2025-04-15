
# Network Diagnostic Script – `diagnose_net.sh`

This Bash script performs a fast and readable diagnosis of network reachability for hosts defined in a `hosts.file`. It uses emojis for clean CLI output, creates a timestamped Markdown log file for reporting, and supports latency benchmarking to a reference host via `.env` or CLI flag.

## 📦 Files Included

- `diagnose_net.sh` – The main script
- `hosts.file` – List of IPs/domains to monitor
- `config/.env` – Optional environment config
- `logs/` – Output Markdown logs (auto-created)

## 🚀 Usage

```bash
./diagnose_net.sh [--latency-host <host>] [--hosts-file <file>] [--env <file>]
```

## 🌐 Example `.env`

```bash
LATENCY_TARGET=1.1.1.1
```

## 📝 Sample `hosts.file`

```text
8.8.8.8
1.1.1.1
example.com
192.0.2.55
# This is a comment line
```

## 📄 Sample Console Output

ℹ️ Starting network diagnostics from hosts file: hosts.file  
ℹ️ Logging to: ./logs/diagnose_net_2025-04-15_18-37.md  
✅ 8.8.8.8 is reachable  
✅ 1.1.1.1 is reachable  
❌ 192.0.2.55 is unreachable  
✅ example.com is reachable  
➡️ Benchmarking latency to 1.1.1.1...  
ℹ️ Latency to 1.1.1.1: 19.67ms  
✅ Diagnostic complete. Report saved to ./logs/diagnose_net_2025-04-15_18-37.md  

## 🔐 Permissions

Make sure the script is executable:

```bash
chmod +x diagnose_net.sh
```

## 📌 Notes

- Requires `ping`, `awk`, `timeout`
- Markdown logs are timestamped to the minute
- Script exits on failure or misconfiguration (safe mode: `set -euo pipefail`)

## ✅ License

MIT License © Joel E White
