# HashiCorp Vault on AWS EC2

A production-ready HashiCorp Vault deployment on AWS EC2, running as a Docker container with Raft integrated storage, fronted by an Nginx reverse proxy.

## Architecture

```
Internet → Elastic IP → Nginx (port 80) → Vault (port 8200, Docker) → Raft Storage (local disk)
```

- **Instance:** EC2 t3.small (Ubuntu 22.04 LTS), `us-east-1`
- **Vault:** Runs in Docker using the official `hashicorp/vault` image
- **Storage:** Raft integrated storage (single-node, local `/opt/vault/data`)
- **Proxy:** Nginx on port 80 proxying to Vault on `localhost:8200`
- **IaC:** Terraform (AWS provider)
- **Config:** Ansible

## First-Time Initialization

After the first successful deployment, Vault must be **initialized and unsealed**. This is a one-time operation.

### 1. SSH into the instance

```bash
ssh -i <your-private-key> ubuntu@<INSTANCE_IP>
```

### 2. Initialize Vault

```bash
# Set the Vault address
export VAULT_ADDR='http://127.0.0.1:8200'

# Initialize Vault (produces unseal keys + root token)
docker exec -it vault vault operator init
```

Save the **unseal keys** and **root token** securely — they will NOT be shown again.

### 3. Unseal Vault

Vault requires 3 of 5 keys to unseal by default:

```bash
docker exec -it vault vault operator unseal <Unseal_Key_1>
docker exec -it vault vault operator unseal <Unseal_Key_2>
docker exec -it vault vault operator unseal <Unseal_Key_3>
```

### 4. Access the Vault UI

Open your browser and navigate to:

```
http://<INSTANCE_IP>/ui/
```

Log in with the root token.

## Re-sealing / Restart

⚠️ **Important:** Vault seals itself on every restart. After a reboot or redeploy, you must **unseal it manually** using the same process above.

Consider setting up [AWS KMS Auto-Unseal](https://developer.hashicorp.com/vault/docs/configuration/seal/awskms) to automate this.

## Pipeline Stages

| Stage       | Description                                      |
|-------------|--------------------------------------------------|
| `lint`      | Terraform format check and validate              |
| `provision` | Create EC2, EIP, Security Group via Terraform    |
| `configure` | Install Docker + Vault + Nginx via Ansible       |
| `verify`    | Health-check Vault UI via HTTP                   |

## Optional Enhancements

- **TLS/HTTPS** — Add Let's Encrypt via certbot with a custom domain
- **AWS KMS Auto-Unseal** — Eliminate manual unsealing on restart
- **Vault Audit Logging** — Send audit logs to CloudWatch
- **HA Cluster** — 3-node Raft cluster for high availability
- **S3 Snapshots** — Automated Vault data backups to S3

## Cost Estimate

| Resource        | Cost/month (~) |
|-----------------|----------------|
| EC2 t3.small    | ~$15           |
| Elastic IP      | ~$3.60         |
| EBS gp3 (20 GB) | ~$1.60         |
| **Total**       | **~$20**       |
