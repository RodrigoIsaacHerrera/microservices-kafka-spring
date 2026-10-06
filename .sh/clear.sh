#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yaml"
DATA_VOLUME_FILE="$SCRIPT_DIR/.clear-data-volumes"

collect_compose_data_volumes() {
  local container_ids container_id service mounts volume_name destination
  local -a volume_names=()

  container_ids="$(docker compose --file "$COMPOSE_FILE" ps --all --quiet)"
  for container_id in $container_ids; do
    service="$(docker inspect --format '{{ index .Config.Labels "com.docker.compose.service" }}' "$container_id")"
    case "$service" in
      db-storage|db-items|db-orders) ;;
      *) continue ;;
    esac

    mounts="$(docker inspect --format '{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}}|{{.Destination}}{{"\n"}}{{end}}{{end}}' "$container_id")"
    while IFS='|' read -r volume_name destination; do
      case "$destination" in
        /var/lib/postgresql/data|/var/lib/mysql)
          [[ -n "$volume_name" ]] && volume_names+=("$volume_name")
          ;;
      esac
    done <<< "$mounts"
  done

  if [[ "${#volume_names[@]}" -gt 0 ]]; then
    printf '%s\n' "${volume_names[@]}" | sort -u
  fi
}

if [[ "${1:-}" != "" && "${1:-}" != "--yes" ]]; then
  printf 'Uso: bash .sh/clear.sh [--yes]\n' >&2
  exit 2
fi

if [[ "${1:-}" != "--yes" ]]; then
  printf '%s\n' "Se eliminarán los contenedores Compose y las imágenes que Compose asocie a este proyecto. Los volúmenes anónimos con los datos de las bases se conservarán; usa clear-data.sh para borrarlos. ¿Continuar? [y/N] "
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) printf '%s\n' "Cancelado."; exit 1 ;;
  esac
fi

new_volumes="$(collect_compose_data_volumes)"
if [[ -n "$new_volumes" ]]; then
  temporary_file="$(mktemp "$DATA_VOLUME_FILE.XXXXXX")"
  if [[ -f "$DATA_VOLUME_FILE" ]]; then
    cat "$DATA_VOLUME_FILE" > "$temporary_file"
  fi
  printf '%s\n' "$new_volumes" >> "$temporary_file"
  sort -u "$temporary_file" -o "$temporary_file"
  mv "$temporary_file" "$DATA_VOLUME_FILE"
fi

docker compose --file "$COMPOSE_FILE" down --rmi all
