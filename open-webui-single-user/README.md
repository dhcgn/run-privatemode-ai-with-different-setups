# open-webui-single-user

## Optional: Speech-to-Text via privatemode-proxy

To route Open WebUI's OpenAI-compatible Speech-to-Text traffic through `privatemode-proxy`, add the following environment variables to the `open-webui` service in `docker-compose/docker-compose.yml`.

```yaml
AUDIO_STT_ENGINE: openai
AUDIO_STT_MODEL: whisper-large-v3
AUDIO_STT_OPENAI_API_BASE_URL: http://privatemode-proxy:8080/v1
AUDIO_STT_OPENAI_API_KEY: ${PM_API_KEY}
```

These should sit alongside `OPENAI_API_BASE_URL` and `OPENAI_API_KEY` so both chat completions and STT use the same proxy endpoint.

Reference: [Open WebUI Speech-to-Text OpenAI](https://docs.openwebui.com/reference/env-configuration/#speech-to-text-openai)

## Models

> 15.05.2026

| Model                                                                                                    | Model ID                   | Type           | Input       | Context / limit | Endpoints                                                 |
| -------------------------------------------------------------------------------------------------------- | -------------------------- | -------------- | ----------- | --------------- | --------------------------------------------------------- |
| [Gemma 3 27B](https://huggingface.co/leon-se/gemma-3-27b-it-FP8-Dynamic) *(deprecated)*                  | `gemma-3-27b`              | Chat           | Text, image | 128k tokens     | `/v1/chat/completions`                                    |
| [Gemma 4 31B](https://huggingface.co/nvidia/Gemma-4-31B-IT-NVFP4)                                        | `gemma-4-31b`              | Chat           | Text, image | 256k tokens     | `/v1/chat/completions`, `/v1/completions`, `/v1/messages` |
| [gpt-oss-120b](https://huggingface.co/openai/gpt-oss-120b)                                               | `gpt-oss-120b`             | Chat           | Text        | 128k tokens     | `/v1/chat/completions`, `/v1/completions`, `/v1/messages` |
| [Kimi K2.6](https://huggingface.co/moonshotai/Kimi-K2.6)                                                 | `kimi-k2.6`, `kimi-latest` | Chat           | Text, image | 256k tokens     | `/v1/chat/completions`, `/v1/completions`, `/v1/messages` |
| [Qwen3-Coder 30B-A3B](https://huggingface.co/stelterlab/Qwen3-Coder-30B-A3B-Instruct-AWQ) *(deprecated)* | `qwen3-coder-30b-a3b`      | Chat           | Text        | 128k tokens     | `/v1/chat/completions`, `/v1/completions`                 |
| [Qwen3-Embedding 4B](https://huggingface.co/boboliu/Qwen3-Embedding-4B-W4A16-G128)                       | `qwen3-embedding-4b`       | Embedding      | Text        | 32k tokens      | `/v1/embeddings`                                          |
| [Voxtral Mini 3B](https://huggingface.co/mistralai/Voxtral-Mini-3B-2507)                                 | `voxtral-mini-3b`          | Speech-to-text | Audio       | 50 MB           | `/v1/audio/transcriptions`                                |
| [Whisper large-v3](https://huggingface.co/openai/whisper-large-v3)                                       | `whisper-large-v3`         | Speech-to-text | Audio       | 50 MB           | `/v1/audio/transcriptions`                                |

## Run

```plain
 .\start.ps1
Pulling latest Docker images...
[+] pull 2/2
 ✔ Image ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest Pulled                                                                                                                                                                                                                                                                                 0.9s
 ✔ Image ghcr.io/open-webui/open-webui:main-slim                  Pulled                                                                                                                                                                                                                                                                                 2.7s
Starting Privatemode Proxy + Open WebUI...
[+] up 2/2
 ✔ Container docker-compose-privatemode-proxy-1 Started                                                                                                                                                                                                                                                                                                  0.3s
 ✔ Container docker-compose-open-webui-1        Started                                                                                                                                                                                                                                                                                                  0.2s
Waiting for Open WebUI to become ready...
  ...still waiting
  ...still waiting
  ...still waiting
Open WebUI is ready and will open in your default browser in 1 second...                                                

Open WebUI is ready at:
  http://localhost:3000/?model=kimi-latest
```
