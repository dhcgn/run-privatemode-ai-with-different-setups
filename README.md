# run-privatemode-ai-with-different-setups

Small collection of demo setups showing how to run [Privatemode.ai](https://privatemode.ai) by [Edgeless Systems](https://edgeless.systems).

> **For demonstration purposes only.**

## What is Privatemode.ai?

Privatemode.ai provides end-to-end encrypted AI inference. A local proxy verifies the remote deployment and transparently encrypts your prompts before they leave your machine.

## Setups

### Open WebUI + Privatemode Proxy

A single-user local chat UI backed by the Privatemode proxy.

**Location:** `open-webui/docker-compose/`

**Features:**
- No login required (single-user mode)
- No Hugging Face / internet downloads (fully offline except for the Privatemode API)
- Default model: `kimi-latest`

**Prerequisites:** Docker, a [Privatemode API key](https://privatemode.ai)

**Usage:**

1. Set your API key in `.env`:
   ```
   PM_API_KEY=your-api-key-here
   ```
2. Start:
   ```powershell
   .\start.ps1
   ```
3. Reset to a clean state:
   ```powershell
   .\clear-state.ps1
   ```


