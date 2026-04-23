# Datadog Logs Workshop - Log Generator

A self-contained Docker environment for Datadog logs workshops. Generates realistic logs with intentional issues for hands-on learning.

## Table of Contents

- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Workshop Guide](#workshop-guide)
  - [Challenge 1: Multiline Java Stack Traces](#challenge-1-multiline-java-stack-traces)
  - [Challenge 2: Multiline XML Logs](#challenge-2-multiline-xml-logs)
  - [Challenge 3: Inconsistent Timestamp Formats](#challenge-3-inconsistent-timestamp-formats)
  - [Challenge 4: Missing Fields](#challenge-4-missing-fields)
  - [Challenge 5: Mixed Log Formats](#challenge-5-mixed-log-formats)
  - [Challenge 6: Parsing Nested JSON](#challenge-6-parsing-nested-json)
  - [Challenge 7: Extracting Data from XML](#challenge-7-extracting-data-from-xml)
- [Simulated Services](#simulated-services)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### Prerequisites

- Docker installed on your Mac
- Datadog API key

### 1. Set your API key

```bash
export DD_API_KEY=your_api_key_here

# For EU site:
export DD_SITE=datadoghq.eu
```

### 2. Start the workshop

```bash
cd log-workshop

# Using docker-compose (recommended)
docker-compose up --build

# Or using docker directly
docker build -t dd-logs-workshop .
docker run -e DD_API_KEY=$DD_API_KEY -e DD_SITE=${DD_SITE:-datadoghq.com} dd-logs-workshop
```

### 3. View logs in Datadog

Go to **Logs** and search for:
```
service:api-gateway OR service:payment-service OR service:user-service OR service:legacy-monolith
```

That's it! Logs will start flowing within seconds.

---

## What's in the Container

The container runs:
1. **Datadog Agent** - Configured to collect logs from `/var/log/workshop/`
2. **Log Generator** - Creates realistic logs for 4 different services

| Service | Format | Intentional Issues |
|---------|--------|-------------------|
| `api-gateway` | JSON | Broken timestamps, missing fields |
| `payment-service` | JSON (nested) | Plain text errors mixed in, nested objects |
| `user-service` | XML | Multiline XML documents |
| `legacy-monolith` | Plain text | Java stack traces (multiline) |

### Agent Configuration

The containerized agent collects logs from `/var/log/workshop/` and sends them to Datadog.

**Important limitation**: Remote Agent Management (Fleet Automation) is **not supported** for containerized Datadog agents. To modify agent-level settings (like multiline log processing), you must:

1. Shell into the container
2. Edit the config file
3. Restart the agent

See [How to Edit Agent Config Inside the Container](#how-to-edit-agent-config-inside-the-container) for step-by-step instructions.

> **Want Fleet Automation support?** Use the [Instruqt version](../log-workshop-instruqt/) of this workshop, which runs on a real VM where Remote Agent Management works.

---

## Configuration

### Environment Variables

Pass these when starting the container:

| Variable | Default | Description |
|----------|---------|-------------|
| `DD_API_KEY` | *required* | Your Datadog API key |
| `DD_SITE` | `datadoghq.com` | Datadog site (eu, us3, us5, etc.) |
| `API_GATEWAY_RATE` | `30` | Logs per minute |
| `PAYMENT_SERVICE_RATE` | `20` | Logs per minute |
| `USER_SERVICE_RATE` | `25` | Logs per minute |
| `LEGACY_MONOLITH_RATE` | `15` | Logs per minute |
| `ERROR_RATE` | `10` | Percentage of error logs |
| `BURST_PROBABILITY` | `5` | Chance of log burst (%) |
| `ENABLE_BROKEN_TIMESTAMPS` | `true` | Generate inconsistent timestamps |
| `ENABLE_MISSING_FIELDS` | `true` | Generate logs with missing fields |
| `ENABLE_MULTILINE_ISSUES` | `true` | Generate multiline logs |
| `ENABLE_MIXED_FORMATS` | `true` | Mix plain text in JSON files |

### Example: Higher error rate

```bash
docker-compose up --build -e ERROR_RATE=30
```

### Example: Clean logs (no issues)

```bash
ENABLE_BROKEN_TIMESTAMPS=false \
ENABLE_MISSING_FIELDS=false \
ENABLE_MULTILINE_ISSUES=false \
ENABLE_MIXED_FORMATS=false \
docker-compose up --build
```

---

## Workshop Guide

### Pre-Workshop Setup

1. **Start the container** (5 minutes before workshop):
   ```bash
   docker-compose up --build -d
   ```

2. **Verify logs are flowing to Datadog**:
   - Go to Datadog → Logs
   - Search for `env:workshop`

3. **Ensure participants can see the issues**:
   - Multiline logs appearing as separate entries
   - Timestamps not being parsed correctly
   - Missing attributes

### Where to Apply Fixes

| Challenge | Fix Location | How to Apply |
|-----------|--------------|--------------|
| 1. Multiline Java Stack Traces | **Agent** | Edit config inside container + restart agent |
| 2. Multiline XML Logs | **Agent** | Edit config inside container + restart agent |
| 3. Inconsistent Timestamps | **Pipeline** | Logs → Configuration → Pipelines |
| 4. Missing Fields | **Pipeline** | Logs → Configuration → Pipelines |
| 5. Mixed Log Formats | **Pipeline** | Logs → Configuration → Pipelines |
| 6. Parsing Nested JSON | **Pipeline** | Logs → Configuration → Pipelines |
| 7. Extracting Data from XML | **Pipeline** | Logs → Configuration → Pipelines |

**Key insight for participants**: Multiline aggregation MUST happen at the agent level before logs are sent. All other parsing and enrichment can be done in backend pipelines.

> **Note**: Fleet Automation / Remote Agent Management is not supported for containerized agents. For agent-level fixes in this workshop, we'll edit the configuration inside the container and restart the agent. See the [Instruqt version](../log-workshop-instruqt/) if you want a VM-based workshop where Fleet Automation works.

### How to Edit Agent Config Inside the Container

For Challenges 1 & 2, you'll need to edit the agent configuration manually.

#### Option A: Using nano (inside container)

```bash
# 1. Open a shell inside the container
docker exec -it dd-logs-workshop bash

# 2. Edit the log collection config with nano
nano /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml

# 3. Save: Ctrl+O, Enter, then Ctrl+X to exit

# 4. Exit the container shell
exit

# 5. Restart the container to apply changes
docker restart dd-logs-workshop

# 6. Verify the new config is loaded
docker exec dd-logs-workshop agent configcheck
```

#### Option B: Edit from host and copy into container (Recommended)

```bash
# 1. Copy config out of container
docker cp dd-logs-workshop:/etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml ./conf.yaml

# 2. Edit with your favorite editor on your Mac
code ./conf.yaml   # or: nano ./conf.yaml

# 3. Copy back into container
docker cp ./conf.yaml dd-logs-workshop:/etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml

# 4. Restart the container to apply changes
docker restart dd-logs-workshop

# 5. Verify config is loaded
docker exec dd-logs-workshop agent configcheck
```

#### Option C: Use cat to append (for quick additions)

```bash
# Example: This appends to the end of the file
# (For precise editing in the middle of the file, use Option A or B)
docker exec dd-logs-workshop bash -c "cat >> /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml << 'EOF'
# Your additional config here
EOF"

# Restart container to apply
docker restart dd-logs-workshop
```

**Tip**: View the current config:
```bash
docker exec dd-logs-workshop cat /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml
```

---

### Challenge 1: Multiline Java Stack Traces

**Problem**: Java exceptions with stack traces appear as separate log entries.

**Where to see it**: Filter logs by `service:legacy-monolith` and look for ERROR level logs. The stack trace lines (`at com.mycompany...`) appear as separate entries.

**Example broken log**:
```
2024-01-15 10:30:45,123 [ERROR] [thread-42] UserController.processRequest - Failed to process request
NullPointerException: Failed to process request
	at com.mycompany.api.UserController.processRequest(UserController.java:127)
	at com.mycompany.service.OrderService.validateInput(OrderService.java:84)
```

**Why this is an Agent-level fix**: Multiline aggregation must happen at the agent level *before* logs are sent to Datadog. Once logs arrive as separate entries, they cannot be merged in the backend pipelines.

**Solution - Edit Agent Config**:

1. Open a shell inside the container:
   ```bash
   docker exec -it dd-logs-workshop bash
   ```

2. Edit the log collection config:
   ```bash
   nano /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml
   ```

3. Find the `legacy-monolith` section and add the `log_processing_rules`:
   ```yaml
   - type: file
     path: /var/log/workshop/legacy-monolith.log
     service: legacy-monolith
     source: legacy-monolith
     tags:
       - env:workshop
       - format:plaintext
     log_processing_rules:
       - type: multi_line
         name: java_stacktrace
         pattern: '^\d{4}-\d{2}-\d{2}\s|^\d{2}/\w{3}/\d{4}:|^\w{3}\s+\d{1,2}\s+'
   ```

4. Save and exit nano (Ctrl+O, Enter, Ctrl+X), then exit the container:
   ```bash
   exit
   ```

5. Restart the container to apply changes:
   ```bash
   docker restart dd-logs-workshop
   ```

6. Verify the config is loaded:
   ```bash
   docker exec dd-logs-workshop agent configcheck
   ```

**Explanation**: The pattern matches the start of a new log line (timestamp), so any line NOT matching becomes part of the previous entry.

---

### Challenge 2: Multiline XML Logs

**Problem**: XML logs spanning multiple lines appear as separate entries.

**Where to see it**: Filter by `service:user-service`. Look for logs that show only `<log>` or individual XML elements.

**Example broken log**:
```xml
<log>
  <timestamp>2024-01-15T10:30:45.000Z</timestamp>
  <level>INFO</level>
  <service>user-service</service>
  ...
</log>
```

**Why this is an Agent-level fix**: Like Java stack traces, multiline aggregation must happen at the agent before logs are sent.

**Solution - Edit Agent Config**:

1. Open a shell inside the container (if not already):
   ```bash
   docker exec -it dd-logs-workshop bash
   ```

2. Edit the log collection config:
   ```bash
   nano /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml
   ```

3. Find the `user-service` section and add the `log_processing_rules`:
   ```yaml
   - type: file
     path: /var/log/workshop/user-service.log
     service: user-service
     source: user-service
     tags:
       - env:workshop
       - format:xml
     log_processing_rules:
       - type: multi_line
         name: xml_multiline
         pattern: '<log>'
   ```

4. Save, exit nano, and exit the container:
   ```bash
   # In nano: Ctrl+O, Enter, Ctrl+X
   exit
   ```

5. Restart the container to apply changes:
   ```bash
   docker restart dd-logs-workshop
   ```

**Explanation**: The pattern `<log>` marks the start of a new log entry, so all subsequent lines until the next `<log>` are aggregated together.

---

### Challenge 3: Inconsistent Timestamp Formats

**Problem**: Different services use different timestamp formats, making time-based correlation difficult.

**Formats you'll see**:
- ISO 8601: `2024-01-15T10:30:45.000Z`
- Log4j: `2024-01-15 10:30:45,123`
- European: `15-01-2024 10:30:45`
- Slashes: `2024/01/15 10:30:45`
- Unix: `1705315845`

**Solution - Logs Pipeline (Datadog UI)**:

1. Go to **Logs → Configuration → Pipelines**
2. Create a new pipeline for each source or a global one
3. Add a **Date Remapper** processor:
   - For JSON logs: Map `timestamp` field
   - For plain text: Use Grok parser first to extract timestamp

**Grok Pattern for legacy-monolith**:
```
%{date("yyyy-MM-dd HH:mm:ss,SSS"):timestamp} \[%{word:level}\] \[%{data:thread}\] %{data:class}\.%{word:method} - %{data:message}
```

---

### Challenge 4: Missing Fields

**Problem**: Some logs are missing `user_id` or `trace_id`, making correlation difficult.

**Where to see it**: Filter by `service:api-gateway` and check attributes. Some logs won't have `user_id` or `trace_id`.

**Solution - Logs Pipeline**:

Option A: **Add default values**
1. Add a **Remapper** processor to set defaults
2. Or use a **Category Processor** to tag logs with missing fields

Option B: **Create a facet for tracking**
1. Create a facet on `user_id`
2. Use `NOT @user_id:*` to find logs without it

---

### Challenge 5: Mixed Log Formats

**Problem**: The payment service occasionally writes plain text errors in a JSON log file.

**Example**:
```
[2024-01-15T10:30:45.000Z] ERROR - Payment failed for transaction txn_abc123: Gateway timeout
```

Mixed with:
```json
{"timestamp":"2024-01-15T10:30:45.000Z","level":"INFO",...}
```

**Solution - Logs Pipeline**:

1. Create a pipeline for `source:payment-service`
2. Add a **Grok Parser** as the first processor with multiple parsing rules:

```
# Rule 1: JSON format (will auto-parse)
rule_json %{data:json_data}

# Rule 2: Plain text fallback
rule_text \[%{date("yyyy-MM-dd'T'HH:mm:ss.SSSZ"):timestamp}\] %{word:level} - %{data:message}
```

---

### Challenge 6: Parsing Nested JSON

**Problem**: Payment service logs contain nested `transaction` objects that aren't automatically extracted as attributes.

**Example log**:
```json
{
  "timestamp": "2024-01-15T10:30:45.000Z",
  "level": "INFO",
  "service": "payment-service",
  "transaction": {
    "id": "txn_abc123xyz",
    "amount": 1500,
    "currency": "USD",
    "method": "credit_card"
  },
  "user_id": "usr_1001",
  "status": "COMPLETED"
}
```

**Solution - Logs Pipeline**:

1. Add a **Remapper** processor to flatten nested attributes:
   - Source: `transaction.id` → Target: `transaction_id`
   - Source: `transaction.amount` → Target: `amount`
   - Source: `transaction.currency` → Target: `currency`

2. Or use an **Attribute Remapper** to create facets directly on nested paths.

---

### Challenge 7: Extracting Data from XML

**Problem**: XML logs need to be parsed to extract meaningful attributes.

**Solution - Logs Pipeline**:

1. Add a **Grok Parser** for XML:
```
rule_xml <log>.*<timestamp>%{data:timestamp}</timestamp>.*<level>%{word:level}</level>.*<service>%{data:service}</service>.*<user>.*<name>%{data:user.name}</name>.*<id>%{data:user.id}</id>.*</user>.*<action>%{word:action}</action>.*<session_id>%{data:session_id}</session_id>.*<ip_address>%{ip:client.ip}</ip_address>.*<status>%{word:status}</status>.*</log>
```

2. Or use a **String Builder** processor with regex to extract specific fields.

---

## Simulated Services

### api-gateway (JSON)
Modern API gateway handling incoming HTTP requests.

**Sample log**:
```json
{
  "timestamp": "2024-01-15T10:30:45.000Z",
  "level": "INFO",
  "service": "api-gateway",
  "user": "alice",
  "user_id": "usr_1001",
  "method": "POST",
  "endpoint": "/api/v1/orders",
  "status": 201,
  "duration_ms": 145,
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "trace_id": "abc123def456",
  "message": "Request processed"
}
```

### payment-service (JSON with nested objects)
Payment processing microservice.

**Sample log**:
```json
{
  "timestamp": "2024-01-15T10:30:45.000Z",
  "level": "INFO",
  "service": "payment-service",
  "transaction": {
    "id": "txn_xyz789",
    "amount": 2500,
    "currency": "EUR",
    "method": "paypal"
  },
  "user_id": "usr_1003",
  "trace_id": "def789ghi012",
  "status": "COMPLETED",
  "message": "Payment COMPLETED"
}
```

### user-service (XML)
User authentication and session management.

**Sample log (single line)**:
```xml
<log><timestamp>2024-01-15T10:30:45.000Z</timestamp><level>INFO</level><service>user-service</service><user><name>bob</name><id>usr_1002</id></user><action>LOGIN</action><session_id>sess_abc123</session_id><ip_address>192.168.1.100</ip_address><status>SUCCESS</status></log>
```

### legacy-monolith (Plain text with Java stack traces)
Legacy Java application.

**Sample log (normal)**:
```
2024-01-15 10:30:45,123 [INFO] [thread-42] UserController.processRequest - Processing request - duration: 234ms
```

**Sample log (error with stack trace)**:
```
2024-01-15 10:30:45,123 [ERROR] [thread-42] PaymentProcessor.handlePayment - Database connection lost
SQLException: Database connection lost
	at com.mycompany.repository.DatabaseConnection.executeQuery(DatabaseConnection.java:89)
	at com.mycompany.service.PaymentProcessor.handlePayment(PaymentProcessor.java:156)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:234)
Caused by: java.lang.RuntimeException: Underlying cause
	at com.mycompany.util.Helper.doSomething(Helper.java:42)
	... 15 more
```

---

## Troubleshooting

### Container not starting

```bash
# Check container logs
docker-compose logs

# Or
docker logs dd-logs-workshop
```

### Logs not appearing in Datadog

1. **Verify API key**:
   ```bash
   echo $DD_API_KEY
   ```

2. **Check agent status inside container**:
   ```bash
   docker exec dd-logs-workshop agent status
   ```

3. **Check if logs are being generated**:
   ```bash
   docker exec dd-logs-workshop ls -la /var/log/workshop/
   docker exec dd-logs-workshop tail /var/log/workshop/api-gateway.log
   ```

4. **Check agent log collection status**:
   ```bash
   docker exec dd-logs-workshop agent status | grep -A 30 "Logs Agent"
   ```

### Stop the workshop

```bash
docker-compose down

# Or
docker stop dd-logs-workshop && docker rm dd-logs-workshop
```

### View live logs from generator

```bash
docker exec dd-logs-workshop tail -f /var/log/workshop/api-gateway.log
```

---

## Running Locally (Without Docker)

If you prefer to run directly on your Mac:

```bash
chmod +x log-generator.sh
./log-generator.sh
```

Logs will be created in `~/workshop-logs/`. You'll need a Datadog Agent installed and configured separately.

---

## Resetting to Original (Broken) Configuration

To reset the workshop and restore the original configuration with all the intentional issues:

### Option A: Rebuild the container (cleanest)

```bash
docker-compose down
docker-compose up --build
```

This rebuilds the container from scratch with the original broken configuration.

### Option B: Restore config file manually

```bash
# Copy the original config back into the container
docker cp datadog/conf.d/workshop-logs-docker.yaml \
  dd-logs-workshop:/etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml

# Restart to apply
docker restart dd-logs-workshop

# Verify it's back to original (no log_processing_rules)
docker exec dd-logs-workshop cat /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml
```

### Option C: Overwrite with original config inline

```bash
docker exec dd-logs-workshop bash -c 'cat > /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml << "EOF"
logs:
  - type: file
    path: /var/log/workshop/api-gateway.log
    service: api-gateway
    source: api-gateway
    tags:
      - env:workshop
      - format:json

  - type: file
    path: /var/log/workshop/payment-service.log
    service: payment-service
    source: payment-service
    tags:
      - env:workshop
      - format:json

  - type: file
    path: /var/log/workshop/user-service.log
    service: user-service
    source: user-service
    tags:
      - env:workshop
      - format:xml

  - type: file
    path: /var/log/workshop/legacy-monolith.log
    service: legacy-monolith
    source: legacy-monolith
    tags:
      - env:workshop
      - format:plaintext
EOF'

# Restart to apply
docker restart dd-logs-workshop
```

After resetting, the multiline issues will reappear in Datadog:
- Java stack traces split across multiple log entries
- XML logs appearing as separate lines

---

## License

MIT License - Feel free to use and modify for your workshops!
