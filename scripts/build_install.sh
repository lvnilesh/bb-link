#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  printf 'Usage: %s [build | install PORT | monitor PORT]\n' "${0##*/}"
}

action="${1:-build}"
case "$action" in
  -h|--help|help)
    usage
    exit 0
    ;;
  build)
    if [[ $# -gt 1 ]]; then
      usage >&2
      exit 2
    fi
    ;;
  install|monitor)
    if [[ $# -ne 2 ]]; then
      usage >&2
      exit 2
    fi
    port="$2"
    if [[ ! -c "$port" || ! -r "$port" || ! -w "$port" ]]; then
      printf 'Serial port must be a readable, writable character device: %s\n' "$port" >&2
      exit 1
    fi
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

if command -v pio >/dev/null 2>&1; then
  platformio_cmd=pio
elif command -v platformio >/dev/null 2>&1; then
  platformio_cmd=platformio
else
  printf 'PlatformIO Core is required: https://docs.platformio.org/en/latest/core/installation/\n' >&2
  exit 127
fi

case "$action" in
  build)
    exec "$platformio_cmd" run --project-dir "$project_dir" --environment atom-lite
    ;;
  install)
    exec "$platformio_cmd" run --project-dir "$project_dir" --environment atom-lite --target upload --upload-port "$port"
    ;;
  monitor)
    exec "$platformio_cmd" device monitor --project-dir "$project_dir" --environment atom-lite --port "$port"
    ;;
esac
