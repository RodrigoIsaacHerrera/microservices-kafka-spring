#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yaml"

if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' "Error: Docker no está instalado o no está disponible en PATH." >&2
  exit 1
fi

if [[ ! -f "$COMPOSE_FILE" ]]; then
  printf 'Error: no se encontró el archivo Compose: %s\n' "$COMPOSE_FILE" >&2
  exit 1
fi

printf '%s\n' "Ejecutando docker compose build. El Compose actual solo referencia imágenes públicas y no define targets build; no se construyen imágenes de aplicación."
docker compose --file "$COMPOSE_FILE" build
