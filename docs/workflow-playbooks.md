---
title: "Workflow Playbooks"
---

## Workflow #4: Daily OpenClaw Power Users, Updates, and Trends

### Purpose

Produce a daily snapshot of high-value OpenClaw activity so you can see who the power users are, what changed, and which trends need action.

### Cadence

- Daily at 08:30 local time.

### Inputs

- Last 24 hours of assistant interaction logs.
- OpenClaw update and release notes feed.
- Workflow success/failure events.

### Output

- Daily report with:
  - top power users by volume and completion success
  - key OpenClaw updates or release notes
  - trend signals (up, flat, down) vs prior 7-day baseline
  - recommended actions for today

### Acceptance Criteria

1. Report runs 3 consecutive days without manual retry.
2. Report includes all 4 sections listed above.
3. Trend direction is calculated against a rolling 7-day baseline.

## Workflow #5: Project Dashboard and Daily Event Replay

### Purpose

Provide a dashboard for current system status and a timeline view to review historical daily events.

### Cadence

- Refresh hourly.
- Support on-demand replay for any date in the prior 7 days.

### Inputs

- Gateway health status.
- Channel connectivity status.
- Approval queue and action logs.
- Workflow completion and error events.

### Output

- Dashboard sections:
  - current system status (healthy/degraded/down)
  - open approvals and pending risks
  - latest workflow outcomes
  - event timeline with day-by-day replay

### Acceptance Criteria

1. Current status updates within 60 minutes.
2. Daily replay works for each of the prior 7 days.
3. Critical failures are visible in the latest event window.
