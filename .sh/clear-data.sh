#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yaml"
DATA_VOLUME_FILE="$SCRIPT_DIR/.clear-data-volumes"

if [[ "${1:-}" != "" && "${1:-}" != "--yes" ]]; then
  printf 'Uso: bash .sh/clear-data.sh [--yes]\n' >&2
  exit 2
fi

if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' "Error: Docker no está instalado o no está disponible en PATH." >&2
  exit 1
fi

if [[ ! -f "$COMPOSE_FILE" ]]; then
  printf 'Error: no se encontró el archivo Compose: %s\n' "$COMPOSE_FILE" >&2
  exit 1
fi

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

temporary_file="$(mktemp "$DATA_VOLUME_FILE.XXXXXX")"
if [[ -f "$DATA_VOLUME_FILE" ]]; then
  cat "$DATA_VOLUME_FILE" > "$temporary_file"
fi
new_volumes="$(collect_compose_data_volumes)"
if [[ -n "$new_volumes" ]]; then
  printf '%s\n' "$new_volumes" >> "$temporary_file"
fi
sort -u "$temporary_file" -o "$temporary_file"
mv "$temporary_file" "$DATA_VOLUME_FILE"

all_volumes=$'\n'"$(docker volume ls --quiet)"$'\n'
volume_names=()
while IFS= read -r volume_name; do
  [[ -n "$volume_name" ]] || continue
  if [[ "$all_volumes" == *$'\n'"$volume_name"$'\n'* ]]; then
    volume_names+=("$volume_name")
  fi
done < "$DATA_VOLUME_FILE"

if [[ "${#volume_names[@]}" -eq 0 ]]; then
  rm -f "$DATA_VOLUME_FILE"
  printf '%s\n' "No se encontraron volúmenes de datos de estas bases para eliminar."
  exit 0
fi

if [[ "${1:-}" != "--yes" ]]; then
  printf '%s\n' "Se detendrán y eliminarán los contenedores Compose y se borrarán permanentemente los datos de sus bases. Las imágenes se conservarán. ¿Continuar? [y/N] "
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) printf '%s\n' "Cancelado."; exit 1 ;;
  esac
fi

docker compose --file "$COMPOSE_FILE" down
docker volume rm "${volume_names[@]}"
rm -f "$DATA_VOLUME_FILE"
