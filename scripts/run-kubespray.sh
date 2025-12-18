#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
INVENTORY_NAME=${INVENTORY_NAME:-timeweb}
KUBESPRAY_IMAGE=${KUBESPRAY_IMAGE:-quay.io/kubespray/kubespray:v2.29.1}
SSH_KEY_PATH=${SSH_KEY_PATH:-$HOME/.ssh/id_rsa}
KNOWN_HOSTS_PATH=${KNOWN_HOSTS_PATH:-$HOME/.ssh/known_hosts}

if [[ ! -f "$SSH_KEY_PATH" ]]; then
  echo "SSH key not found: $SSH_KEY_PATH" >&2
  exit 1
fi

if [[ ! -d "$ROOT_DIR/inventory/$INVENTORY_NAME" ]]; then
  echo "Inventory not found: $ROOT_DIR/inventory/$INVENTORY_NAME" >&2
  exit 1
fi

KNOWN_HOSTS_MOUNT=()
if [[ -f "$KNOWN_HOSTS_PATH" ]]; then
  KNOWN_HOSTS_MOUNT=(-v "$KNOWN_HOSTS_PATH:/root/.ssh/known_hosts:ro")
fi

docker run --rm -it \
  -v "$ROOT_DIR/inventory:/kubespray/inventory" \
  -v "$SSH_KEY_PATH:/root/.ssh/id_rsa:ro" \
  "${KNOWN_HOSTS_MOUNT[@]}" \
  --workdir /kubespray \
  "$KUBESPRAY_IMAGE" \
  ansible-playbook -i "inventory/$INVENTORY_NAME/hosts.yaml" --become --become-user=root cluster.yml "$@"
