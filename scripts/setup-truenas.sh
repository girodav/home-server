#!/bin/bash
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
APPDATA_POOL="fast"
APPDATA_DATASET="apps"

DATA_POOL="tank"

PUID=1000
PGID=1000
# ─────────────────────────────────────────────────────────────────────────────

MOUNT_PREFIX="/mnt"
APPDATA_ROOT="${MOUNT_PREFIX}/${APPDATA_POOL}/${APPDATA_DATASET}"
DATA_ROOT="${MOUNT_PREFIX}/${DATA_POOL}/data"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCO_CD_DIR="${REPO_ROOT}/apps/doco-cd"

# ── Create ZFS datasets ───────────────────────────────────────────────────────
datasets=(
  "${APPDATA_POOL}/${APPDATA_DATASET}"
  "${APPDATA_POOL}/${APPDATA_DATASET}/jellyfin"
  "${APPDATA_POOL}/${APPDATA_DATASET}/seerr"
  "${APPDATA_POOL}/${APPDATA_DATASET}/prowlarr"
  "${APPDATA_POOL}/${APPDATA_DATASET}/radarr"
  "${APPDATA_POOL}/${APPDATA_DATASET}/sonarr"
  "${APPDATA_POOL}/${APPDATA_DATASET}/qbittorrent"
  "${APPDATA_POOL}/${APPDATA_DATASET}/qui"
  "${DATA_POOL}/data"
)

echo "Creating ZFS datasets..."
for dataset in "${datasets[@]}"; do
  if zfs list "${dataset}" &>/dev/null; then
    echo "  [skip] ${dataset} already exists"
  else
    zfs create "${dataset}"
    echo "  [ok]   ${dataset}"
  fi
done

# ── Set ownership ─────────────────────────────────────────────────────────────
echo "Setting ownership to ${PUID}:${PGID}..."
chown -R "${PUID}:${PGID}" "${APPDATA_ROOT}"
chown -R "${PUID}:${PGID}" "${DATA_ROOT}"

# ── Check bootstrap secret files ──────────────────────────────────────────────
missing=0

if [[ ! -f "${DOCO_CD_DIR}/op_token.txt" ]]; then
  echo ""
  echo "Missing: ${DOCO_CD_DIR}/op_token.txt"
  echo "  Create a 1Password service account token and write it to that file."
  missing=1
fi

echo ""
if [[ "${missing}" -eq 0 ]]; then
  echo "Done. Bootstrap doco-cd with:"
  echo "  cd ${DOCO_CD_DIR} && docker compose up -d"
else
  echo "Fill in the missing files above, then bootstrap doco-cd with:"
  echo "  cd ${DOCO_CD_DIR} && docker compose up -d"
fi

echo ""
echo "Place your WireGuard config at:"
echo "  ${APPDATA_ROOT}/qbittorrent/wireguard/wg0.conf"
