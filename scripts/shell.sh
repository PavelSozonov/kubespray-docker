#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
KUBESPRAY_IMAGE=${KUBESPRAY_IMAGE:-quay.io/kubespray/kubespray:v2.29.1}
SSH_KEY_PATH=${SSH_KEY_PATH:-"$HOME/.ssh/id_ed25519"}
KNOWN_HOSTS_PATH=${KNOWN_HOSTS_PATH:-"$HOME/.ssh/known_hosts"}

if [[ ! -f "$SSH_KEY_PATH" ]]; then
  echo "SSH key not found: $SSH_KEY_PATH" >&2
  exit 1
fi

KNOWN_HOSTS_MOUNT=()
if [[ -f "$KNOWN_HOSTS_PATH" ]]; then
  # mount RW so ssh inside container can append host keys if needed
  KNOWN_HOSTS_MOUNT=(-v "$KNOWN_HOSTS_PATH:/root/.ssh/known_hosts")
fi

exec docker run --rm -it \
  -v "$ROOT_DIR/inventory:/kubespray/inventory" \
  -v "$SSH_KEY_PATH:/root/.ssh/id_ed25519:ro" \
  "${KNOWN_HOSTS_MOUNT[@]}" \
  -e ANSIBLE_HOST_KEY_CHECKING=False \
  --workdir /kubespray \
  "$KUBESPRAY_IMAGE" \
  bash
