# 🏠 home-server

Self-hosted services on TrueNAS SCALE, deployed via GitOps. Push to `main` → [doco-cd](https://github.com/kimdre/doco-cd) picks it up within 3 minutes. Secrets managed with 1Password.

## 🔐 Secrets

Secrets are stored in 1Password and referenced in `.doco-cd.yaml`:

```yaml
external_secrets:
  MY_SECRET: op://home-server/item/field
```

Then use `${MY_SECRET}` in the compose file.

## 🚀 First-time setup

**1. Create a [1Password service account](https://developer.1password.com/docs/service-accounts/) and save the token:**

```sh
echo "ops_xxxx" > apps/doco-cd/op_token.txt
```

**2. Run the setup script** (as root, edit variables at the top first):

```sh
bash scripts/setup-truenas.sh
```

**3. Place your WireGuard config:**

```
/mnt/fast/apps/qbittorrent/wireguard/wg0.conf
```

**4. Bootstrap doco-cd:**

```sh
cd apps/doco-cd && docker compose up -d
```

Every push to `main` deploys automatically from here on. ✅
