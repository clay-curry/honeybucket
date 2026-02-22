# Host Provisioning Checklist (Ubuntu 24.04 VPS)

1. Run `sudo bash ops/linux/provision-ubuntu.sh`.
2. Confirm package installs (`curl`, `jq`, `ufw`, `fail2ban`, `restic`).
3. Confirm Node 22+ and npm installed.
4. Confirm `openclaw` service account exists and owns:
   - `/var/lib/openclaw`
   - `/var/log/openclaw`
   - `/tmp/openclaw`
5. Confirm `/etc/openclaw` exists with mode `750`.
6. Confirm firewall policy:
   - default deny incoming
   - OpenSSH allowed
7. Confirm port `18789` is not exposed publicly.
8. If used, confirm Tailscale is connected and SSH access tested.
