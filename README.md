# ax-graph

[![CI](https://github.com/SIN-CLIs/ax-graph/actions/workflows/ci.yml/badge.svg)](https://github.com/SIN-CLIs/ax-graph/actions/workflows/ci.yml)

Unified accessibility tree indexer for macOS — snapshot all apps, watch live mutations via AXObserver, resolve clicks by stable SHA256 node_id.

**Part of the [SIN-CLIs Stealth Suite](https://github.com/SIN-CLIs/stealth-runner).**

## Quick Start

```bash
# Build
swift build -c release

# Snapshot all running apps
.build/release/ax-graph snapshot --all

# Snapshot a single process
.build/release/ax-graph snapshot --pid $(pgrep -x "Google Chrome")

# Watch for AX mutations
.build/release/ax-graph watch --pid 12345

# Resolve a node and click
.build/release/ax-graph resolve --pid 12345 --node-id "axg:a3f2..." --press
```

## Commands

| Command | Description |
|---------|-------------|
| `snapshot` | One-shot AX snapshot of one or all running apps |
| `watch` | Live AX mutation streaming via AXObserver |
| `resolve` | Resolve node_id to AX element and press |

## Installation

```bash
git clone https://github.com/SIN-CLIs/ax-graph.git
cd ax-graph
swift build -c release
cp .build/release/ax-graph /usr/local/bin/
```

Requirements: macOS 14+, Swift 5.9+

## Output Schema

```json
{
  "snapshot_id": "snap:a1b2c3d4",
  "timestamp": 1730000000.0,
  "apps": [{
    "pid": 12345,
    "bundle_id": "com.google.Chrome",
    "windows": [{
      "title": "Heypiggy Dashboard",
      "elements": [{
        "node_id": "axg:a3f2...",
        "role": "AXButton",
        "title": "Continue with Google",
        "dom_id": "google-signin-btn",
        "frame": [612, 410, 200, 44],
        "actions": ["AXPress"],
        "path": "AXWindow/AXGroup[0]/AXButton[2]"
      }]
    }]
  }]
}
```

## Architecture

```
Apps (NSWorkspace) ──► ax-graph snapshot ──► JSON output
                           │
                    AXObserver ──► watch ──► JSONL events
                           │
                    node_id ──► resolve ──► AXPress
```

## 🔗 Stealth Suite

Part of the **SIN-CLIs Stealth Suite** — 12 Komponenten für autonome Browser-Automation:

| Layer | Repo | Technologie |
|-------|------|-------------|
| 🧠 Orchestrator | [`stealth-runner`](https://github.com/SIN-CLIs/stealth-runner) | Python |
| 🖱️ ACT (CUA-ONLY) | [`cua-touch`](https://github.com/SIN-CLIs/cua-touch) | Python + Swift Binary |
| 🎭 HIDE | [`playstealth-cli`](https://github.com/SIN-CLIs/playstealth-cli) | Python |
| 👁️ SENSE | [`unmask-cli`](https://github.com/SIN-CLIs/unmask-cli) | TypeScript |
| 📹 VERIFY | [`screen-follow`](https://github.com/SIN-CLIs/screen-follow) | Swift |
| 🔍 SCAN | [`macos-ax-cli`](https://github.com/SIN-CLIs/macos-ax-cli) | Swift |
| 🔒 CAPTCHA | [`stealth-captcha`](https://github.com/SIN-CLIs/stealth-captcha) | Python |
| 🧩 SKILLS | [`stealth-skills`](https://github.com/SIN-CLIs/stealth-skills) | TS/Python |
| 🐙 GRAPH | [`ax-graph`](https://github.com/SIN-CLIs/ax-graph) | Swift |
| 💀 LEGACY | [`computer-use-mcp`](https://github.com/SIN-CLIs/computer-use-mcp) | TypeScript |
| 💀 LEGACY | [`A2A-SIN-Worker-heypiggy`](https://github.com/OpenSIN-AI/A2A-SIN-Worker-heypiggy) | Python |

## License

MIT — see [LICENSE](LICENSE)

---
## 🔗 Stealth Suite

Part of the **SIN-CLIs Stealth Suite** — 16 Komponenten für autonome Browser-Automation:

| Layer | Repo | Technologie |
|-------|------|-------------|
| 🧠 Orchestrator | [stealth-runner](https://github.com/SIN-CLIs/stealth-runner) | Python |
| 🖱️ ACT (CUA-ONLY) | [cua-touch](https://github.com/SIN-CLIs/cua-touch) | Python + Swift |
| 🎭 HIDE | [playstealth-cli](https://github.com/SIN-CLIs/playstealth-cli) | Python |
| 👁️ SENSE | [unmask-cli](https://github.com/SIN-CLIs/unmask-cli) | TypeScript |
| 📹 VERIFY | [screen-follow](https://github.com/SIN-CLIs/screen-follow) | Swift |
| 🔍 SCAN | [macos-ax-cli](https://github.com/SIN-CLIs/macos-ax-cli) | Swift |
| 🐙 AX-INDEXER | [ax-graph](https://github.com/SIN-CLIs/ax-graph) | Swift |
| 🔒 CAPTCHA | [stealth-captcha](https://github.com/SIN-CLIs/stealth-captcha) | Python |
| 🧩 SKILLS | [stealth-skills](https://github.com/SIN-CLIs/stealth-skills) | TS/Python |
| 🧱 CORE | [stealth-core](https://github.com/SIN-CLIs/stealth-core) | Python |
| 🧠 MIND | [stealth-mind](https://github.com/SIN-CLIs/stealth-mind) | Python |
| 🛡️ GUARDIAN | [stealth-guardian](https://github.com/SIN-CLIs/stealth-guardian) | Python |
| 🔄 SYNC | [stealth-sync](https://github.com/SIN-CLIs/stealth-sync) | Python |
| ⚡ SESSION | [stealth-session](https://github.com/SIN-CLIs/stealth-session) | Python |
| 💀 LEGACY | [skylight-cli](https://github.com/SIN-CLIs/skylight-cli) | Swift |
| 💀 LEGACY | [computer-use-mcp](https://github.com/SIN-CLIs/computer-use-mcp) | TypeScript |

---
