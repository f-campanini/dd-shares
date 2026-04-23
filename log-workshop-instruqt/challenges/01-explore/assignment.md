# Setup and Explore the Environment

In this challenge, you'll configure the Datadog Agent and verify logs are flowing.

## Step 1: Install the Datadog Agent

Run the setup script with your Datadog API key:

```bash
sudo /opt/setup-datadog-agent.sh YOUR_API_KEY
```

Replace `YOUR_API_KEY` with your actual Datadog API key.

**For EU site**, add the site parameter:
```bash
sudo /opt/setup-datadog-agent.sh YOUR_API_KEY datadoghq.eu
```

## Step 2: Verify the Agent is Running

```bash
sudo datadog-agent status
```

You should see the agent running and a "Logs Agent" section showing it's collecting logs.

## Step 3: Check Log Files are Being Generated

```bash
ls -la /var/log/workshop/
tail /var/log/workshop/api-gateway.log
```

You should see four log files being continuously updated.

## Step 4: View Logs in Datadog

1. Open Datadog in your browser
2. Go to **Logs**
3. Search for: `env:workshop`
4. You should see logs from all four services:
   - `api-gateway` (JSON)
   - `payment-service` (JSON with nested objects)
   - `user-service` (XML)
   - `legacy-monolith` (plain text)

## Step 5: Observe the Issues

Look for these problems that we'll fix in the following challenges:

**Multiline Issues** (Challenges 2 & 3):
- Filter by `service:legacy-monolith status:error`
- Notice Java stack traces appear as **separate** log entries
- Filter by `service:user-service`
- Notice some XML logs are split across multiple entries

**Parsing Issues** (Challenges 4-8):
- Inconsistent timestamp formats
- Missing fields (`user_id`, `trace_id`)
- Nested JSON objects not extracted
- XML attributes not parsed

## Success Criteria

Click **Check** when:
- Datadog Agent is running
- Logs are visible in Datadog with `env:workshop`
