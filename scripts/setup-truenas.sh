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
DOWNLOADS_ROOT="${MOUNT_PREFIX}/${APPDATA_POOL}/downloads"
DATA_ROOT="${MOUNT_PREFIX}/${DATA_POOL}/data"

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
  "${APPDATA_POOL}/${APPDATA_DATASET}/profilarr"
  "${APPDATA_POOL}/downloads"
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
chown -R "${PUID}:${PGID}" "${DOWNLOADS_ROOT}"

echo "Creating media folders..."
mkdir -p "${DATA_ROOT}/media/movies"
mkdir -p "${DATA_ROOT}/media/tv"
mkdir -p "${DATA_ROOT}/torrents"
chown -R "${PUID}:${PGID}" "${DATA_ROOT}"

echo ""
echo "Done. Place your WireGuard config at:"
echo "  ${APPDATA_ROOT}/qbittorrent/wireguard/wg0.conf"
