# open-webui-single-user

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
