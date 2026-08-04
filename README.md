# home-server

GitOps home server managed with [doco-cd](https://github.com/kimdre/doco-cd). Secrets are stored in 1Password and injected at deploy time.

## Structure

```
apps/
  doco-cd/        # GitOps CD agent
  media-center/   # Jellyfin, Sonarr, Radarr, Prowlarr, Seerr, qBittorrent+VPN, qui
scripts/
  setup-truenas.sh
```

## How secrets work

- Non-sensitive config (paths, timezone, etc.) is committed to git in each service's `.env`
- Actual secrets are stored in 1Password and declared in `.doco-cd.yaml` as `op://` URIs
- doco-cd fetches and injects them at deploy time via a 1Password service account
- The only file that lives on disk outside the repo is `op_token.txt` inside `apps/doco-cd/`

## Adding a secret

1. Add the secret to 1Password under the `home-server` vault
2. Reference it in `.doco-cd.yaml` under `external_secrets`:
   ```yaml
   external_secrets:
     MY_SECRET: op://home-server/item-name/field-name
   ```
3. Use `${MY_SECRET}` in the compose file
4. Push — doco-cd deploys within 3 minutes

## First-time setup (TrueNAS SCALE)

### 1. Create bootstrap secret file

```sh
# 1Password service account token (ops_xxxx)
# Create at: https://developer.1password.com/docs/service-accounts/
echo "ops_xxxx" > apps/doco-cd/op_token.txt
```

### 2. Run the setup script (as root on TrueNAS)

Edit the variables at the top of the script, then:

```sh
bash scripts/setup-truenas.sh
```

| Variable | Description |
|---|---|
| `APPDATA_POOL` | ZFS pool for app config (default: `fast`) |
| `APPDATA_DATASET` | Dataset name under the pool (default: `apps`) |
| `DATA_POOL` | ZFS pool for media and downloads (default: `tank`) |
| `PUID` / `PGID` | UID/GID containers run as (default: `1000`) |

### 3. Place WireGuard config

```
/fast/apps/qbittorrent/wireguard/wg0.conf
```

### 4. Bootstrap doco-cd (one-time)

```sh
cd apps/doco-cd && docker compose up -d
```

doco-cd polls the repo every 3 minutes and deploys all stacks on every push. It also manages its own updates.
