# hashicorp-vault-ec2 — Project Notes

## Key Decisions

- **Runtime:** Vault runs in Docker (official hashicorp/vault:latest) — avoids OS-level Vault package management complexity and keeps upgrades simple (pull new tag, restart service).
- **Storage:** Raft integrated storage (single-node) — no external DB dependency at Tier 1. Data lives at /opt/vault/data (20GB gp3 volume).
- **Networking:** Vault binds to `127.0.0.1:8200` inside Docker — NOT exposed publicly. Nginx on port 80 proxies to it. Public ports: 22 (SSH), 80 (HTTP), 443 (reserved for TLS).
- **Proxy:** Nginx fronts Vault — allows future TLS termination, keeps Vault's high port off the public internet.
- **OS:** Ubuntu 22.04 LTS — ssh_user=ubuntu, apt package manager.
- **No auto-unseal:** Tier 1 — manual unseal after first init or restart. AWS KMS auto-unseal listed as optional enhancement.
- **No marketplace template found** — built from scratch.

## Pipeline Notes

- The configure stage re-runs `terraform init` + `terraform output` to get the instance IP (self-sufficient job rule — avoids masked-secret job output issues).
- All three downstream stages (configure, verify) re-init terraform to read the EIP from state.
- Vault health check hits `/ui/` via HTTP with 15 retries × 20s = up to 5 min boot window.

## Secrets Required (set via set_pipeline_secret after repo push)

- `VAULT_UNSEAL_KEY` — set post-init (placeholder until first vault operator init run)
- `VAULT_ROOT_TOKEN` — set post-init (placeholder until first vault operator init run)
- Platform-managed: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, SSH_PUBLIC_KEY, SSH_PRIVATE_KEY, SSH_USER, PROJECT_NAME, TF_STATE_BUCKET

## Status

- [ ] Architecture written (rev 1)
- [ ] Pipeline written (rev 1)
- [ ] Design approved ✓
- [ ] Plan approved ✓
- [ ] Files generated
- [ ] validate_project
- [ ] test_project
- [ ] Repo pushed
- [ ] Deployed
