# Exchange Server email queue monitoring script

param (
    [switch]$Test  # Use -Test flag to run in test mode with random values
)

# Datadog API configuration
$datadogApiKey = $env:DD_API_KEY
$datadogSite = if ($env:DD_SITE) { $env:DD_SITE } else { "datadoghq.com" }
$metricName = "exchange.email.queue.count"

# DogStatsD configuration
$dogstatsdHost = if ($env:DD_AGENT_HOST) { $env:DD_AGENT_HOST } else { "127.0.0.1" }
$dogstatsdPort = if ($env:DD_DOGSTATSD_PORT) { [int]$env:DD_DOGSTATSD_PORT } else { 8125 }

# Queue threshold - only send metric if queue count exceeds this value (0 = always send)
$queueThreshold = 0

# Metric sending method: "api" for Datadog API, "dogstatsd" for DogStatsD agent
$sendMethod = "api"

# Metric tags
$metricTags = @("source:exchange", "metric_type:queue")

# Test configuration (for Test-EmailQueueMetric function)
$testMinQueue = 0
$testMaxQueue = 20

# Function to send metric to Datadog
function Send-DatadogMetric {
    param (
        [int]$queueCount,
        [string[]]$tags = @()
    )

    $uri = "https://api.$datadogSite/api/v2/series"
    $timestamp = [int][double]::Parse((Get-Date -UFormat %s))

    $payload = @{
        series = @(
            @{
                metric = $metricName
                type = 0  # 0 = unspecified, 1 = count, 2 = rate, 3 = gauge
                points = @(
                    @{
                        timestamp = $timestamp
                        value = $queueCount
                    }
                )
                tags = $tags
            }
        )
    } | ConvertTo-Json -Depth 10

    $headers = @{
        "DD-API-KEY" = $datadogApiKey
        "Content-Type" = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $payload
        Write-Host "Metric '$metricName' sent to Datadog successfully. Value: $queueCount"
    } catch {
        Write-Error "Failed to send metric to Datadog: $_"
    }
}

# Function to send metric to Datadog Agent via DogStatsD (UDP)
function Send-DogStatsDMetric {
    param (
        [int]$queueCount,
        [string[]]$tags = @()
    )

    # Build DogStatsD message format: metric.name:value|g|#tag1:value1,tag2:value2
    $tagsString = if ($tags.Count -gt 0) { "|#" + ($tags -join ",") } else { "" }
    $message = "${metricName}:${queueCount}|g${tagsString}"

    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($message)
        $udpClient.Send($bytes, $bytes.Length, $dogstatsdHost, $dogstatsdPort) | Out-Null
        $udpClient.Close()
        Write-Host "Metric '$metricName' sent to DogStatsD ($dogstatsdHost`:$dogstatsdPort) successfully. Value: $queueCount"
    } catch {
        Write-Error "Failed to send metric to DogStatsD: $_"
    }
}

# Function to check the email queue (production)
function Check-EmailQueue {
    try {
        # Check if the Exchange module is loaded
        if (-not (Get-Command -Name Get-Queue -ErrorAction SilentlyContinue)) {
            Write-Host "Importing Exchange module..."
            Import-Module Exchange
        }

        # Get the total count of messages in the queue
        $queueCount = (Get-Queue | Where-Object { $_.Identity -notlike "*shadow*" } | Measure-Object -Property MessageCount -Sum).Sum
        if (-not $queueCount) {
            $queueCount = 0 # Default to 0 if no queues or messages are found
        }
        Write-Host "Current queue count: $queueCount"

        # Send the metric to Datadog only if queue exceeds threshold
        if ($queueCount -gt $queueThreshold) {
            switch ($sendMethod.ToLower()) {
                "api" {
                    Send-DatadogMetric -queueCount $queueCount -tags $metricTags
                }
                "dogstatsd" {
                    Send-DogStatsDMetric -queueCount $queueCount -tags $metricTags
                }
                default {
                    Write-Error "Invalid send method '$sendMethod'. Use 'api' or 'dogstatsd'."
                }
            }
        } else {
            Write-Host "Queue count ($queueCount) is within threshold ($queueThreshold). Metric not sent."
        }

    } catch {
        Write-Error "Error fetching email queue. Ensure you are running this script with appropriate permissions."
    }
}

# Function to test metric sending with random queue values (testing)
function Test-EmailQueueMetric {
    $queueCount = Get-Random -Minimum $testMinQueue -Maximum ($testMaxQueue + 1)
    Write-Host "[TEST] Generated random queue count: $queueCount"

    # Send the metric to Datadog only if queue exceeds threshold
    if ($queueCount -gt $queueThreshold) {
        switch ($sendMethod.ToLower()) {
            "api" {
                Send-DatadogMetric -queueCount $queueCount -tags $metricTags
            }
            "dogstatsd" {
                Send-DogStatsDMetric -queueCount $queueCount -tags $metricTags
            }
            default {
                Write-Error "Invalid send method '$sendMethod'. Use 'api' or 'dogstatsd'."
            }
        }
    } else {
        Write-Host "Queue count ($queueCount) is within threshold ($queueThreshold). Metric not sent."
    }
}

# Run the check
if ($Test) {
    Test-EmailQueueMetric
} else {
    Check-EmailQueue
}
