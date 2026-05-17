#!/usr/bin/env bash
set -euo pipefail

IMAGE="ghcr.io/edgelesssys/privatemode/privatemode-proxy:latest"
PORT="${PORT:-8080}"
API_KEY=""

# If API_KEY is not set, return a error
if [[ -z "$API_KEY" ]]; then
    echo "ERROR: API_KEY environment variable is not set."
    exit 1
fi

# If the host port is already published by a running container, inspect who owns it.
port_containers="$(docker ps --filter "publish=$PORT" --format '{{.Image}}|{{.Names}}|{{.Ports}}')"
if [[ -n "$port_containers" ]]; then
	proxy_container_name=""
	while IFS='|' read -r image name ports; do
		if [[ "$image" == ghcr.io/edgelesssys/privatemode/privatemode-proxy* ]]; then
			proxy_container_name="$name"
			break
		fi
	done <<< "$port_containers"

	if [[ -n "$proxy_container_name" ]]; then
		echo "Port $PORT is already used by privatemode-proxy container: $proxy_container_name"
		exit 0
	fi

	echo "WARNING: Port $PORT is already used, but not by privatemode-proxy."
	echo "Containers publishing port $PORT:"
	docker ps --filter "publish=$PORT" --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
	exit 1
fi

# Fallback check for non-Docker listeners.
if ss -H -ltn "sport = :$PORT" 2>/dev/null | grep -q .; then
	echo "WARNING: Port $PORT is already in use, but no running privatemode-proxy container publishes it."
	ss -ltnp "sport = :$PORT" || true
	exit 1
fi

echo "Pulling image: $IMAGE"
docker pull "$IMAGE"

echo "Starting privatemode-proxy on port $PORT"
docker run -p "$PORT:8080" "$IMAGE" --apiKey "$API_KEY" --sharedPromptCache