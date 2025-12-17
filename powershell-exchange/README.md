# Exchange Email Queue Metrics for Datadog

A PowerShell script that monitors Microsoft Exchange Server email queue counts and sends the metrics to Datadog.

## Overview

This script queries the Exchange Server mail queue, counts the total number of messages (excluding shadow queues), and sends the metric to Datadog. It supports two methods for sending metrics:

- **Datadog API** - Direct HTTP submission to the Datadog metrics API
- **DogStatsD** - UDP submission to a local Datadog Agent

## Requirements

- PowerShell 5.1 or later
- Microsoft Exchange Server (for production mode)
- Datadog API key (for API mode) or Datadog Agent with DogStatsD enabled (for DogStatsD mode)

## Configuration

Edit the following variables in the script to customize behavior:

### Datadog API Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `$datadogApiKey` | Datadog API key | Reads from `DD_API_KEY` environment variable |
| `$datadogSite` | Datadog site | Reads from `DD_SITE` env var, defaults to `datadoghq.com` |
| `$metricName` | Name of the metric sent to Datadog | `exchange.email.queue.count` |

### DogStatsD Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `$dogstatsdHost` | DogStatsD host address | Reads from `DD_AGENT_HOST` env var, defaults to `127.0.0.1` |
| `$dogstatsdPort` | DogStatsD UDP port | Reads from `DD_DOGSTATSD_PORT` env var, defaults to `8125` |

### General Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `$queueThreshold` | Only send metric if queue count exceeds this value (0 = always send) | `0` |
| `$sendMethod` | Metric sending method: `api` or `dogstatsd` | `api` |
| `$metricTags` | Tags to attach to the metric | `@("source:exchange", "metric_type:queue")` |

### Test Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `$testMinQueue` | Minimum random queue value for test mode | `0` |
| `$testMaxQueue` | Maximum random queue value for test mode | `20` |

## Usage

### Production Mode

Queries the real Exchange Server email queue:

```powershell
.\exchange-queue-metrics.ps1
```

### Test Mode

Uses random queue values (useful for testing without an Exchange Server):

```powershell
.\exchange-queue-metrics.ps1 -Test
```

## Environment Variables

Set these environment variables before running the script:

```powershell
# Required for API mode
$env:DD_API_KEY = "your-datadog-api-key"

# Optional
$env:DD_SITE = "datadoghq.eu"           # For EU region
$env:DD_AGENT_HOST = "192.168.1.100"    # For remote DogStatsD agent
$env:DD_DOGSTATSD_PORT = "8125"         # Custom DogStatsD port
```

## Examples

### Send metrics via Datadog API

```powershell
$env:DD_API_KEY = "your-api-key"
.\exchange-queue-metrics.ps1
```

### Send metrics via DogStatsD

Edit the script to set `$sendMethod = "dogstatsd"`, then run:

```powershell
.\exchange-queue-metrics.ps1
```

### Test with random values via API

```powershell
$env:DD_API_KEY = "your-api-key"
.\exchange-queue-metrics.ps1 -Test
```

### Set a threshold (only send when queue > 5)

Edit the script to set `$queueThreshold = 5`, then run:

```powershell
.\exchange-queue-metrics.ps1
```

## Scheduling

To run this script periodically, you can use Windows Task Scheduler:

1. Open Task Scheduler
2. Create a new task
3. Set the trigger (e.g., every 5 minutes)
4. Set the action to run PowerShell with the script:
   ```
   Program: powershell.exe
   Arguments: -ExecutionPolicy Bypass -File "C:\path\to\exchange-queue-metrics.ps1"
   ```

## Metric Details

- **Metric Name**: `exchange.email.queue.count`
- **Type**: Gauge
- **Default Tags**: `source:exchange`, `metric_type:queue`

