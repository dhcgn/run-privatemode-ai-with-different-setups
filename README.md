# run-privatemode-ai-with-different-setups

Small collection of demo setups showing how to run [Privatemode.ai](https://privatemode.ai) by [Edgeless Systems](https://edgeless.systems).

> **For demonstration purposes only.**

## What is Privatemode.ai?

Privatemode.ai provides end-to-end encrypted AI inference. A local proxy verifies the remote deployment and transparently encrypts your prompts before they leave your machine.

## Setups

### Open WebUI + Privatemode Proxy

A single-user local chat UI backed by the Privatemode proxy.

**Location:** `open-webui-single-user/docker-compose`

**Features:**

- No login required (single-user mode)
- No Hugging Face / internet downloads (fully offline except for the Privatemode API)
- Default model: `kimi-latest`
- Optional Speech-to-Text (OpenAI-compatible) routed through Privatemode proxy

**Prerequisites:** Docker, a [Privatemode API key](https://portal.privatemode.ai/api-keys)

**Usage:**

1. Set your API key in `.env`:

   ```dotenv
   PM_API_KEY=your-api-key-here
   ```

2. (Optional) Enable Speech-to-Text (OpenAI) through `privatemode-proxy` by setting these variables in `open-webui-single-user/docker-compose/docker-compose.yml`:

   ```yaml
   AUDIO_STT_ENGINE: openai
   AUDIO_STT_MODEL: whisper-large-v3
   AUDIO_STT_OPENAI_API_BASE_URL: http://privatemode-proxy:8080/v1
   AUDIO_STT_OPENAI_API_KEY: ${PM_API_KEY}
   ```

   Reference: [Open WebUI Speech-to-Text OpenAI](https://docs.openwebui.com/reference/env-configuration/#speech-to-text-openai)

3. Start:

   ```powershell
   .\start.ps1
   ```

4. Reset to a clean state:

   ```powershell
   .\clear-state.ps1
   ```
