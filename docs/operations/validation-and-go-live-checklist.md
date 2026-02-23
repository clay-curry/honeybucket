---
title: "Validation and Go-Live Checklist"
---

# Validation and Go-Live Checklist

## Automated checks

1. Run `sudo /usr/local/libexec/openclaw/validate-go-live.sh` and ensure all checks pass.

## Manual validation tests

1. Service survives reboot:
   - Reboot host and verify `openclaw-gateway.service` is active.
2. Channel round-trip:
   - Send task from primary channel and verify assistant response.
3. Pairing gate:
   - Verify unpaired sender is blocked until approved.
4. Tool safety:
   - Attempt risky command and verify denial or approval gating.
5. Auth safety:
   - Verify invalid token cannot access gateway control plane.
6. Resilience:
   - Kill gateway process and verify automatic restart by systemd.
7. Backup restore:
   - Restore latest snapshot to staging path and verify files are usable.
8. Rollback:
   - Perform rollback drill using known-good OpenClaw version.

## Burn-in acceptance criteria (7-day)

1. Zero critical incidents for 7 consecutive days.
2. No public exposure of gateway port.
3. Pairing and mention gating continuously enforced.
4. Security audit shows no unresolved critical findings.
5. Health checks and alerts fire and clear correctly.
6. Backup and restore rehearsal completed at least once.

## Go-live signoff

1. Operator runbook updated with final versions and paths.
2. Known-good version pin documented for rollback.
3. On-call and escalation channel confirmed.
4. Post-go-live review date scheduled.
