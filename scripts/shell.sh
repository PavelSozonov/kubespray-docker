#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
KUBESPRAY_IMAGE=${KUBESPRAY_IMAGE:-quay.io/kubespray/kubespray:v2.29.1}

exec docker run --rm -it \
  -v "$ROOT_DIR/inventory:/kubespray/inventory" \
  --workdir /kubespray \
  "$KUBESPRAY_IMAGE" \
  bash
