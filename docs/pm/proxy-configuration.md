---
image: https://docs.privatemode.ai/img/preview.png
title: Privatemode
description: Deploy and configure the Privatemode proxy: Docker, Helm, TLS, API keys, prompt caching, HTTP proxy, and manifest management.
---

[Skip to main content](#%5F%5Fdocusaurus%5FskipToContent%5Ffallback)

Version: 1.40

On this page

The Privatemode proxy is a service that you must deploy to use the Privatemode API. Once started, the proxy serves as your API endpoint, handling all the heavy lifting to guarantee end-to-end encryption for you.

The Privatemode proxy does two things:

1. Verifies the Privatemode deployment at `api.privatemode.ai`. This is where your encrypted prompts are processed by the GenAI. The verification process is described in the [attestation section](/architecture/attestation/overview/).
2. Transparently encrypts user prompts and decrypts responses from the Privatemode API.

The Privatemode proxy is published as a [Docker image on GitHub](https://github.com/orgs/edgelesssys/packages/container/package/privatemode%2Fprivatemode-proxy).

## Running the container[​](#running-the-container "Direct link to Running the container")

The following command starts the Privatemode proxy and exposes it on host port 8080:

```

docker run -p 8080:8080 ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest


```

info

Supply chain security best practices recommend pinning containers by their hash. This means specifying the exact cryptographic digest of the container image, rather than relying on tags like `latest` or version labels. By doing so, you ensure that the exact, verified version of the container is used, which helps prevent issues like unexpected updates or potential compromise.

## CLI flags[​](#cli-flags "Direct link to CLI flags")

To see all available CLI option flags, use:

```

docker run ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest --help


```

### Options[​](#options "Direct link to Options")

```

      --apiEndpoint string                 The endpoint for the Privatemode API (default "api.privatemode.ai:443")

      --apiKey string                      The API key for the Privatemode API. Accepts either a direct literal or a file path prefixed with '@'. If no key is set, the proxy will not authenticate with the API.

      --dumpRequests                       If set, the proxy dumps request and response logs to the '/requests' sub‑directory of the workspace. Leaving this flag unset disables request and response dumping.

  -h, --help                               help for privatemode-proxy

      --log-format string                  set logging format (json or text) (default "text")

  -l, --log-level string                   set logging level (debug, info, warn, error, or a number) (default "info")

      --manifestPath string                The path for the manifest file. If not provided, the manifest will be read from the remote source.

      --nvidiaOCSPAllowUnknown             Whether it should be tolerated if the NVIDIA OCSP service cannot be reached. (default true)

      --nvidiaOCSPRevokedGracePeriod int   The grace period (in hours) for which to accept NVIDIA attestation certificates that are revoked according to the OCSP service. Supplying a value of 0 disables the grace period, meaning that revoked certificates are rejected immediately. (default 48)

      --port string                        The port on which the proxy listens for incoming API requests. (default "8080")

      --promptCacheSalt string             The salt used to isolate prompt caches. If empty (default), the same random salt is used for all requests, enabling sharing the cache between all users of the same proxy. Requires 'sharedPromptCache' to be enabled!

      --sharedPromptCache                  If set, caching of prompts between all users of the proxy is enabled. This reduces response times for long conversations or common documents.

      --tlsCertPath string                 The path to the TLS certificate. If not provided, the server will start without TLS.

      --tlsKeyPath string                  The path to the TLS key. If not provided, the server will start without TLS.

      --workspace string                   The path into which the binary writes files. This includes the manifest log data in the 'manifests' subdirectory. (default ".")


```

## Extract a static binary[​](#extract-a-static-binary "Direct link to Extract a static binary")

If you want to run the proxy as a binary, you can extract it from the container image. Depending on your architecture (`arm64` or `amd64`), insert the `<arch>` variable below to obtain a static Linux binary like this:

```

containerID=$(docker create --platform linux/<arch> ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest)

docker cp -L "${containerID}":/bin/privatemode-proxy ./privatemode-proxy

docker rm "${containerID}"


```

## Outbound network traffic[​](#outbound-network-traffic "Direct link to Outbound network traffic")

When running the Privatemode proxy in an environment with restricted firewall settings, you might need to allow the following domains and ports:

* **cdn.confidential.cloud:443**: for fetching the latest manifest
* **api.privatemode.ai:443**: for communication with the Privatemode backend

## Setting up TLS[​](#setting-up-tls "Direct link to Setting up TLS")

If you run the Privatemode proxy on another machine and access it over a network, you must configure TLS to encrypt the network traffic.

To enable TLS, you need to provide a certificate and a private key to the container. You must mount the directory containing these files into the container so the proxy can access them.

Use the following flags to specify the paths _inside_ the container:

* `--tlsCertPath`: Path to the TLS certificate file.
* `--tlsKeyPath`: Path to the private key file.

For example, if your certificates are in the current directory on your host, you can mount it to `/certs` inside the container:

```

docker run \

  -p 8080:8080 \

  -v "$(pwd):/certs" \

  ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest \

  --tlsCertPath /certs/server.crt \

  --tlsKeyPath /certs/server.key


```

By providing these, the Privatemode proxy will serve traffic from and to your application client via HTTPS, ensuring secure communication. If these flags aren't set, the Privatemode proxy will fall back to serving traffic over HTTP.

## TLS inspection / MitM appliances[​](#tls-inspection--mitm-appliances "Direct link to TLS inspection / MitM appliances")

If your network uses a TLS inspection or Man-in-the-Middle (MitM) appliance, the Privatemode proxy might fail to verify the appliance-issued certificates for outbound connections to `cdn.confidential.cloud` or `api.privatemode.ai`.

In this case, mount a CA bundle into the container and point `SSL_CERT_FILE` to it.

### Docker[​](#docker "Direct link to Docker")

Create or obtain a PEM bundle, then mount it into the container:

```

docker run \

  -p 8080:8080 \

  -v /path/to/ca-bundle.crt:/etc/ssl/certs/custom-ca-bundle.crt:ro \

  -e SSL_CERT_FILE=/etc/ssl/certs/custom-ca-bundle.crt \

  ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest


```

To verify that the configuration works, restart the container and check its logs. Startup should include `Coordinator manifest fetched successfully`, and errors like `x509: certificate signed by unknown authority` should no longer appear.

## API key[​](#api-key "Direct link to API key")

The Privatemode API requires authentication with the API key you received when you signed up. You should use the `--apiKey` flag to provide it to the proxy and let it handle authentication.

### Using multiple API keys[​](#using-multiple-api-keys "Direct link to Using multiple API keys")

If you need to support multiple API keys (e.g., for different departments or cost centers), you have two options:

1. **Pass the API key in the request**: Start the proxy without the `--apiKey` flag. In this mode, the proxy will forward the Authorization header from your client's request to the Privatemode API. This allows each client to provide their own API key.  
```  
from openai import OpenAI  
client = OpenAI(  
    # Point to your local proxy instance  
    base_url="http://localhost:8080/v1",  
    # Pass the API key here  
    api_key="<api-key>"  
)  
completion = client.chat.completions.create(  
    model="gpt-oss-120b",  
    messages=[{"role": "user", "content": "Hello Privatemode!"}]  
)  
```
2. **Run multiple proxy instances**: Deploy a separate proxy instance for each API key, configuring each with a different `--apiKey` and listening on a different port.

## Prompt caching[​](#prompt-caching "Direct link to Prompt caching")

Privatemode supports prompt caching to reduce response latency when the first part of a prompt can be reused across requests. This is especially relevant for requests with long shared context or long conversation history.

### Modes of operation[​](#modes-of-operation "Direct link to Modes of operation")

By default, prompt caching is disabled to ensure maximum privacy when the Privatemode proxy is used by multiple users. You can configure it to enable sharing across clients (e.g., to share long documents between multiple users).

The following proxy configurations are supported:

* **Default (no cache sharing):** No prompt caching.
* **Shared per proxy (`--sharedPromptCache`):** All clients connected to the same proxy instance share a prompt cache. A stable random cache salt is kept in proxy memory until restart. At proxy restart, access to the cache is lost.
* **Shared across proxies (`--promptCacheSalt`):** Providing a cache salt via `--promptCacheSalt` at proxy start enables sharing across multiple proxies and allows to keep cache entries across proxy restart. The argument must be a string of at least 32 bytes.

Regardless of the mode, clients can always control cache sharing via the `cache_salt` field in each [chat completion request](/api/chat-completions/#prompt-caching). This allows to reuse the cache for long conversations while isolating it from other users.

### Security[​](#security "Direct link to Security")

The cache is stored in the Privatemode AI worker in GPU memory and encrypted CPU memory. Caches with different salts are isolated from each other.

Custom cache salts (via `--promptCacheSalt` or per request) should be kept private, should be random, and be at least 256 bits long. You can generate a secure salt with `openssl rand -base64 32`.

## NVIDIA OCSP[​](#nvidia-ocsp "Direct link to NVIDIA OCSP")

You can set the policy for handling responses of the NVIDIA OCSP using the following flags:

* `nvidiaOCSPAllowUnknown`: Whether the "unknown" OCSP status (i.e., OCSP is unreachable or doesn't provide information about this certificate) should be tolerated. (Default: `true`)
* `nvidiaOCSPRevokedGracePeriod`: How long "revoked" OCSP responses should be accepted for after the revocation time, in hours. A value of `0` means that "revoked" OCSP responses aren't accepted at all. (Default: `48`)

For a more detailed explanation of the policy, see the documentation on [certificate revocation](/architecture/attestation/certificate-revocation/).

## Proxy updates[​](#proxy-updates "Direct link to Proxy updates")

It’s possible that an update to the Privatemode API introduces a new [manifest](/architecture/attestation/contrast-integration/#contrast-manifest) that's incompatible with your current version of the Privatemode proxy. In such cases, you may encounter issues where the updated manifest can't be processed by the Privatemode proxy. This is known as an "unmarshaling" error.

When this happens, please update the Privatemode proxy (the Docker image) to the latest version.

In the future, we will provide documentation on how to implement automatic updates, which will help mitigate these types of issues.

## HTTP proxy[​](#http-proxy "Direct link to HTTP proxy")

You can run the Privatemode proxy behind an HTTP proxy that supports HTTP CONNECT. Set the `https_proxy` environment variable like this:

```

docker run -p 8080:8080 -e https_proxy=<proxy-address> ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest


```

## Manifest management[​](#manifest-management "Direct link to Manifest management")

Whenever the Privatemode proxy verifies the Privatemode deployment, it relies on a [manifest](/architecture/attestation/contrast-integration/#contrast-manifest) to determine whether the services should be trusted. The manifest contains fingerprints of expected configurations and states of trusted endpoints. If they differ from the actual configurations and states, the services aren't to be trusted.

By default, the manifest is managed automatically. Manual control requires extra work each time an update to the Privatemode API is rolled out.

### Automatically[​](#automatically "Direct link to Automatically")

By default, the Privatemode proxy fetches a manifest from a file service managed by Edgeless Systems (you can get it [here](https://cdn.confidential.cloud/privatemode/v2/manifest.json)). Whenever validation of the Privatemode deployment fails, the Privatemode proxy fetches the latest manifest from the file service and retries validation. This allows the proxy to continue working without manual intervention, even if the deployment changes.

To ensure auditability of the enforced manifests over time, changes to the manifest are logged to the local file system. These logs serve as a transparency log, recording which manifest was used at what point in time to verify the Privatemode deployment.

The proxy writes a file called `log.txt`. For each manifest that's enforced by the proxy, `log.txt` contains a new line with the timestamp at which enforcement began and the filename of the manifest that was enforced.

`log.txt` and the corresponding manifests are stored in a folder `manifests`. You can use the CLI flag `--workspace` to control where the folder `manifests` is stored.

You should mount the workspace to the Docker host to ensure this transparency log isn't lost when the container is removed:

```

docker run -p 8080:8080 -v proxy-logs:/app/privatemode-proxy ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest --workspace /app/privatemode-proxy


```

### Manually[​](#manually "Direct link to Manually")

You can [generate a manifest manually](/guides/verify-source/) and provide the file path to the Privatemode proxy via its `--manifestPath` CLI flag.

warning

This approach isn’t recommended for production because updates to the Privatemode API are continuously rolled out. Each update includes a new manifest, which invalidates the current manifest and prevents successful validation through the Privatemode proxy. As a result, the manifest needs to be manually updated with each Privatemode API update.

## Helm chart[​](#helm-chart "Direct link to Helm chart")

You can use the `privatemode-proxy` Helm chart for easy deployment to Kubernetes.

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* Kubernetes 1.16+
* Helm 3+
* (Optional) Persistent Volume for workspace
* (Optional) ConfigMap for manifest file
* (Optional) TLS secret for certificates

### Installation[​](#installation "Direct link to Installation")

You can install the chart with the following commands:

```

helm repo add edgeless https://helm.edgeless.systems/stable

helm repo update


helm install privatemode-proxy edgeless/privatemode-proxy


```

### Configuration[​](#configuration "Direct link to Configuration")

#### API key[​](#api-key-1 "Direct link to API key")

You should store the API key in a Kubernetes secret. Create it using:

```

kubectl create secret generic privatemode-api-key --from-literal=apiKey=your-api-key


```

#### Persistent volume[​](#persistent-volume "Direct link to Persistent volume")

To persist the application’s data beyond the lifetime of the current deployment, you can configure a Persistent Volume. The data includes the transparency log and manifests that allow you to [audit the enforced manifests over time](#automatically).

First, create a PersistentVolumeClaim:

```

kubectl apply -f - <<EOF

apiVersion: v1

kind: PersistentVolumeClaim

metadata:

  name: privatemode-proxy-pvc

spec:

  accessModes:

    - ReadWriteOnce

  resources:

    requests:

      storage: 1Gi

EOF


```

Then, configure these values for your chart:

```

config:

  workspace:

    enabled: true

    volumeClaimName: "privatemode-proxy-pvc"


```

#### TLS configuration[​](#tls-configuration "Direct link to TLS configuration")

To enable TLS for communication between your application and the Privatemode proxy, provide the TLS certificate and key through a Kubernetes secret:

You can use cert-manager to manage the TLS secret. Or you can create it manually as follows:

```

kubectl create secret tls privatemode-proxy-tls \

  --cert=<path-to-cert> --key=<path-to-key>


```

Then, configure these values for your chart:

```

config:

  tls:

    enabled: true

    secretName: "privatemode-proxy-tls"


```

#### TLS inspection / MitM appliance CA bundle[​](#tls-inspection--mitm-appliance-ca-bundle "Direct link to TLS inspection / MitM appliance CA bundle")

If your cluster reaches Privatemode through a TLS inspection appliance, create a secret that contains a PEM CA bundle:

```

kubectl create secret generic privatemode-proxy-custom-ca \

  --from-file=ca-bundle.crt=/path/to/ca-bundle.crt


```

Then, configure these values for your chart:

```

config:

  customCA:

    enabled: true

    secretName: "privatemode-proxy-custom-ca"

    fileName: "ca-bundle.crt"


```

When enabled, the chart mounts the bundle and sets `SSL_CERT_FILE` for the container.

#### HTTP proxy configuration[​](#http-proxy-configuration "Direct link to HTTP proxy configuration")

You can run the Privatemode proxy behind an HTTP proxy that supports HTTP CONNECT. To this end, set the `https_proxy` environment variable for your chart:

```

config:

  extraEnv:

    - name: https_proxy

      value: <proxy-address>


```

#### Manifest file configuration[​](#manifest-file-configuration "Direct link to Manifest file configuration")

While manually managing manifests isn't recommended (see [Manifest management](#manually)), you can pass in the manifest via a ConfigMap:

Create the ConfigMap from your manifest file:

```

kubectl create configmap privatemode-proxy-config --from-file=manifest.json=/path/to/your/manifest.json


```

Then, configure these values for your chart:

```

config:

  manifest:

    enabled: true

    configMapName: "privatemode-proxy-config"

    fileName: "manifest.json"

    mountPath: "/etc/config/manifest.json"


```

### Accessing the proxy[​](#accessing-the-proxy "Direct link to Accessing the proxy")

Once the deployment is complete, you can configure your application to access the API through the Privatemode proxy service’s domain.

By default, the proxy can be accessed at the following URL:

```

http://privatemode-proxy-privatemode-proxy.default.svc.cluster.local:8080/v1


```

This URL is constructed as follows:

```

http://{helm-release}-privatemode-proxy.{namespace}.svc.cluster.local:{port}/v1


```

* `{helm-release}`: The name of your Helm release.
* `{namespace}`: The Kubernetes namespace where the proxy is deployed.
* `{port}`: The port configured for the proxy service (default is `8080`).

If you configured a custom DNS entry in your cluster, adjust the URL accordingly. Replace the default service domain with your custom domain, ensuring that your application can correctly resolve and communicate with the Privatemode proxy service.

### Uninstallation[​](#uninstallation "Direct link to Uninstallation")

You can uninstall the chart as follows:

```

helm uninstall privatemode-proxy


```

- [Running the container​](#running-the-container)
- [CLI flags​](#cli-flags)
  - [Options​](#options)
- [Extract a static binary​](#extract-a-static-binary)
- [Outbound network traffic​](#outbound-network-traffic)
- [Setting up TLS​](#setting-up-tls)
- [TLS inspection / MitM appliances​](#tls-inspection--mitm-appliances)
  - [Docker​](#docker)
- [API key​](#api-key)
  - [Using multiple API keys​](#using-multiple-api-keys)
- [Prompt caching​](#prompt-caching)
  - [Modes of operation​](#modes-of-operation)
  - [Security​](#security)
- [NVIDIA OCSP​](#nvidia-ocsp)
- [Proxy updates​](#proxy-updates)
- [HTTP proxy​](#http-proxy)
- [Manifest management​](#manifest-management)
  - [Automatically​](#automatically)
  - [Manually​](#manually)
- [Helm chart​](#helm-chart)
  - [Prerequisites​](#prerequisites)
  - [Installation​](#installation)
  - [Configuration​](#configuration)
    - [API key​](#api-key-1)
    - [Persistent volume​](#persistent-volume)
    - [TLS configuration​](#tls-configuration)
    - [TLS inspection / MitM appliance CA bundle​](#tls-inspection--mitm-appliance-ca-bundle)
    - [HTTP proxy configuration​](#http-proxy-configuration)
    - [Manifest file configuration​](#manifest-file-configuration)
  - [Accessing the proxy​](#accessing-the-proxy)
  - [Uninstallation​](#uninstallation)

```json
{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"Proxy configuration","item":"https://docs.privatemode.ai/api/proxy-configuration"}]}
```
