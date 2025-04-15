# 🛠️ Usage Guide — `diagnose_net.sh`

## ▶️ Basic Syntax

```bash
./diagnose_net.sh [--latency-host <host>] [--hosts-file <file>] [--env <file>]
```

## 🧩 Flags and Descriptions

| Flag             | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `--latency-host` | Override and test average latency to a single reference host                |
| `--hosts-file`   | Provide a custom list of hosts to diagnose (default: `hosts.file`)          |
| `--env`          | Specify a custom `.env` file path (default: `./config/.env`)                |

## 📦 Default Behavior

- Uses `hosts.file` for targets
- Reads `LATENCY_TARGET` from `./config/.env` if available
- Logs results to `./logs/diagnose_net_<timestamp>.md`

## 🧪 Example Commands

```bash
./diagnose_net.sh
./diagnose_net.sh --latency-host 1.1.1.1
./diagnose_net.sh --hosts-file /opt/hosts_prod.txt
./diagnose_net.sh --env /etc/netcheck/env.prod
./diagnose_net.sh --hosts-file servers.txt --latency-host 8.8.8.8 --env ./prod.env
```

## ✅ Output Results

- Console feedback with icons for reachability
- Markdown report saved to `./logs/diagnose_net_<timestamp>.md`
- Latency results included if reference host is set

## 🔒 Requirements

- Bash
- `ping`, `awk`, `timeout`
- Optional: a readable `.env` file
