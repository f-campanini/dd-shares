# Datadog Logs Workshop - Instruqt Version

This folder contains everything needed to create a Datadog Logs Workshop on [Instruqt](https://instruqt.com) using the **web UI only**.

## Why Instruqt?

Instruqt provides real VMs (not containers), which means:
- **Remote Agent Management works** - Participants can use Fleet Automation to modify agent config from the Datadog UI
- **No local setup** - Participants only need a browser
- **Challenge-based structure** - Perfect for guided workshops
- **Progress tracking** - See how participants are doing

---

## Creating the Workshop in Instruqt UI

### Step 1: Create a New Track

1. Log in to [Instruqt](https://play.instruqt.com) 
2. Go to your organization's dashboard
3. Look for **"Create Track"** or **"New Track"** button (usually top-right or in a Tracks section)
4. Fill in the basic info:
   - **Title**: `Datadog Logs Workshop`
   - **Slug**: `datadog-logs-workshop` (auto-generated from title)
   - **Teaser**: `Learn to parse, transform, and manage logs with Datadog`
5. Click **Create** or **Save**

### Step 2: Find the Track Configuration

After creating the track, you should be in the track editor. Look for these tabs/sections (UI varies):

- **"Config"** or **"track.yml"** - Track-level settings
- **"Challenges"** - Where you add challenges
- **"Sandbox"** or **"Infrastructure"** or **"Hosts"** - Where you define VMs

If you see a code/YAML editor, that's the `track.yml` view. If you see a visual editor, look for tabs.

### Step 3: Add the Virtual Machine (Sandbox/Infrastructure)

**If you see a visual editor:**
1. Look for a tab called **"Sandbox"**, **"Infrastructure"**, **"Hosts"**, or **"Environment"**
2. Click **"Add Host"** or **"Add Container"** or **"+"**
3. Configure:
   - **Name/Hostname**: `workshop-vm`
   - **Image**: Choose `ubuntu 2404-noble-amd64-v20241004` (or similar Ubuntu image)
   - **Machine Type**: `n1-standard-2` or any 2-CPU option
4. Look for a **"Setup Script"** or **"Lifecycle Scripts"** section
5. Paste the setup script (see Step 6 below)
6. **Important: Add a Terminal tab** so participants can access the VM:
   - Look for a **"Tabs"** section in the host configuration
   - Add a new tab with:
     - **Title**: `Terminal`
     - **Type**: `terminal`
     - **Hostname**: `workshop-vm` (must match your VM name)

**If you see a YAML editor (track.yml):**
Add this to your track.yml:
```yaml
virtualmachines:
  - name: workshop-vm
    image: ubuntu-2404-noble-amd64-v20241004
    machine_type: n1-standard-2

tabs:
  - title: Terminal
    type: terminal
    hostname: workshop-vm
```

### Step 4: Track Variables

No sensitive variables needed! Participants will provide their own Datadog API key during Challenge 1.

This approach:
- Is more secure (no API keys stored in track config)
- Allows each participant to use their own Datadog account
- Works for workshops where participants bring their own credentials

### Step 5: Configure Track Settings

Look for:
- **Time limit**: Set to `3600` (1 hour) or leave default
- **Visibility**: Private or Public

### Step 6: The VM Setup Script

This is the most important part. You need to paste this script into the VM's setup/lifecycle script.

**Where to paste it:**
- In visual editor: Look for "Setup Script" or "Lifecycle Scripts" → "Setup" for the workshop-vm host
- In YAML: The setup script path would be referenced in the host configuration

**The complete setup script** - copy from `#!/bin/bash` to the last `echo` line (do NOT include the ``` markers, those are just markdown formatting):

```bash
#!/bin/bash
set -e

echo "============================================"
echo "  Setting up Datadog Logs Workshop VM"
echo "============================================"

# Install bash-completion for tab autocomplete
apt-get update && apt-get install -y bash-completion
echo 'source /etc/bash_completion' >> /root/.bashrc

# Create log directory (log generator runs without agent)
mkdir -p /var/log/workshop
chmod 777 /var/log/workshop

# Create simplified log generator
cat > /opt/log-generator.sh << 'GENEOF'
#!/bin/bash
LOG_DIR="${LOG_DIR:-/var/log/workshop}"
USERS=("alice" "bob" "charlie" "diana" "eve")
ENDPOINTS=("/api/v1/users" "/api/v1/orders" "/api/v1/products")
METHODS=("GET" "POST" "PUT" "DELETE")

while true; do
    ts=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    ts_log4j=$(date +"%Y-%m-%d %H:%M:%S,%3N")
    user=${USERS[$RANDOM % ${#USERS[@]}]}
    endpoint=${ENDPOINTS[$RANDOM % ${#ENDPOINTS[@]}]}
    method=${METHODS[$RANDOM % ${#METHODS[@]}]}
    
    # API Gateway - JSON
    echo "{\"timestamp\":\"$ts\",\"level\":\"INFO\",\"service\":\"api-gateway\",\"user\":\"$user\",\"method\":\"$method\",\"endpoint\":\"$endpoint\",\"status\":200}" >> "$LOG_DIR/api-gateway.log"
    
    # Payment Service - JSON with nested object
    echo "{\"timestamp\":\"$ts\",\"level\":\"INFO\",\"service\":\"payment-service\",\"transaction\":{\"id\":\"txn_$RANDOM\",\"amount\":$((RANDOM % 5000 + 100)),\"currency\":\"USD\"},\"status\":\"COMPLETED\"}" >> "$LOG_DIR/payment-service.log"
    
    # User Service - XML (sometimes multiline)
    if [ $((RANDOM % 3)) -eq 0 ]; then
        cat >> "$LOG_DIR/user-service.log" << XMLEOF
<log>
  <timestamp>$ts</timestamp>
  <level>INFO</level>
  <service>user-service</service>
  <user><name>$user</name><id>usr_$RANDOM</id></user>
  <action>LOGIN</action>
  <status>SUCCESS</status>
</log>
XMLEOF
    else
        echo "<log><timestamp>$ts</timestamp><level>INFO</level><service>user-service</service><user><name>$user</name><id>usr_$RANDOM</id></user><action>LOGIN</action><status>SUCCESS</status></log>" >> "$LOG_DIR/user-service.log"
    fi
    
    # Legacy Monolith - Plain text (sometimes with stack trace)
    if [ $((RANDOM % 8)) -eq 0 ]; then
        cat >> "$LOG_DIR/legacy-monolith.log" << STACKEOF
$ts_log4j [ERROR] [thread-$RANDOM] UserController.processRequest - Database connection lost
SQLException: Database connection lost
	at com.mycompany.repository.DatabaseConnection.executeQuery(DatabaseConnection.java:$((RANDOM % 200)))
	at com.mycompany.service.UserController.processRequest(UserController.java:$((RANDOM % 200)))
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
Caused by: java.lang.RuntimeException: Connection timeout
	at com.mycompany.util.Helper.connect(Helper.java:42)
	... 15 more
STACKEOF
    else
        echo "$ts_log4j [INFO] [thread-$RANDOM] UserController.processRequest - Request processed successfully" >> "$LOG_DIR/legacy-monolith.log"
    fi
    
    sleep 2
done
GENEOF

chmod +x /opt/log-generator.sh

# Create systemd service for log generator
cat > /etc/systemd/system/log-generator.service << 'EOF'
[Unit]
Description=Workshop Log Generator
After=network.target

[Service]
Type=simple
ExecStart=/opt/log-generator.sh
Restart=always
Environment=LOG_DIR=/var/log/workshop

[Install]
WantedBy=multi-user.target
EOF

# Start log generator (works without agent)
systemctl daemon-reload
systemctl enable log-generator
systemctl start log-generator

# Create helper script for participants to configure the agent
cat > /opt/setup-datadog-agent.sh << 'SETUPEOF'
#!/bin/bash
# Helper script to install and configure Datadog Agent

if [ -z "$1" ]; then
    echo "Usage: ./setup-datadog-agent.sh <DD_API_KEY> [DD_SITE]"
    echo "Example: ./setup-datadog-agent.sh abc123def456 datadoghq.com"
    exit 1
fi

DD_API_KEY="$1"
DD_SITE="${2:-datadoghq.com}"

echo "Installing Datadog Agent..."
DD_API_KEY="$DD_API_KEY" \
DD_SITE="$DD_SITE" \
DD_LOGS_ENABLED=true \
DD_HOSTNAME="instruqt-workshop-vm" \
bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"

# Enable Remote Configuration for Fleet Automation
echo "" >> /etc/datadog-agent/datadog.yaml
echo "remote_configuration:" >> /etc/datadog-agent/datadog.yaml
echo "  enabled: true" >> /etc/datadog-agent/datadog.yaml
echo "remote_updates: true" >> /etc/datadog-agent/datadog.yaml

# Configure agent to collect workshop logs
mkdir -p /etc/datadog-agent/conf.d/workshop-logs.d
cat > /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml << 'EOF'
logs:
  - type: file
    path: /var/log/workshop/api-gateway.log
    service: api-gateway
    source: api-gateway
    tags: ["env:workshop"]

  - type: file
    path: /var/log/workshop/payment-service.log
    service: payment-service
    source: payment-service
    tags: ["env:workshop"]

  - type: file
    path: /var/log/workshop/user-service.log
    service: user-service
    source: user-service
    tags: ["env:workshop"]

  - type: file
    path: /var/log/workshop/legacy-monolith.log
    service: legacy-monolith
    source: legacy-monolith
    tags: ["env:workshop"]
EOF

chown -R dd-agent:dd-agent /etc/datadog-agent/conf.d/workshop-logs.d
chown dd-agent:dd-agent /var/log/workshop

# Restart agent
systemctl restart datadog-agent

echo ""
echo "============================================"
echo "  Datadog Agent installed and configured!"
echo "============================================"
echo "Hostname: instruqt-workshop-vm"
echo "Site: $DD_SITE"
echo ""
echo "Check status: sudo datadog-agent status"
SETUPEOF

chmod +x /opt/setup-datadog-agent.sh

echo ""
echo "============================================"
echo "  VM Setup Complete!"
echo "============================================"
echo ""
echo "Log generator is running."
echo "Participants will install the Datadog Agent"
echo "in Challenge 1 using their own API key."
echo ""
echo "Command for Challenge 1:"
echo "  sudo /opt/setup-datadog-agent.sh <API_KEY> [SITE]"
echo ""
```

### Step 7: Create the Challenges

Look for a **"Challenges"** tab or section in the track editor. For each challenge below:

1. Click **"Add Challenge"** or **"+"**
2. Fill in the fields (slug, title, teaser, time limit)
3. Find the **Assignment** section/tab → paste the assignment content
4. Find the **Check Script** section/tab → paste the check script
5. (Optional) Setup Script → paste if provided
6. Save the challenge

#### Challenge 1: Setup and Explore

| Field | Value |
|-------|-------|
| Slug | `setup-and-explore` |
| Title | `Setup and Explore the Environment` |
| Teaser | `Configure the Datadog Agent and observe log issues` |
| Time Limit | 600 seconds |

**Assignment:**
```markdown
# Setup and Explore the Environment

In this challenge, you'll configure the Datadog Agent and verify logs are flowing.

## Step 1: Install the Datadog Agent

Run the setup script with your Datadog API key:

~~~bash
sudo /opt/setup-datadog-agent.sh YOUR_API_KEY
~~~

**For EU site**, add the site parameter:
~~~bash
sudo /opt/setup-datadog-agent.sh YOUR_API_KEY datadoghq.eu
~~~

## Step 2: Verify the Agent is Running

~~~bash
sudo datadog-agent status
~~~

You should see the agent running and "Logs Agent" section showing it's collecting logs.

## Step 3: Check Log Files

~~~bash
ls -la /var/log/workshop/
tail /var/log/workshop/api-gateway.log
~~~

## Step 4: View Logs in Datadog

1. Open Datadog in your browser
2. Go to **Logs**
3. Search for: `env:workshop`
4. You should see logs from all four services

## Step 5: Observe the Issues

Look for these problems:

**Multiline Issues** (Challenges 2 & 3):
- `service:legacy-monolith` - Java stack traces split into separate entries
- `service:user-service` - XML logs split across multiple entries

**Parsing Issues** (Challenges 4-8):
- Inconsistent timestamp formats
- Missing fields
- Nested JSON objects

Click **Check** when logs are flowing to Datadog.
```

**Check Script:**
```bash
#!/bin/bash
set -e
if ! systemctl is-active --quiet datadog-agent; then
    fail-message "Datadog agent is not running. Run: sudo /opt/setup-datadog-agent.sh YOUR_API_KEY"
    exit 1
fi
for service in api-gateway payment-service user-service legacy-monolith; do
    if [ ! -s "/var/log/workshop/${service}.log" ]; then
        fail-message "Log file /var/log/workshop/${service}.log not found or empty"
        exit 1
    fi
done
echo "All checks passed! Agent is running and logs are being generated."
```

#### Challenge 2: Fix Multiline Java Stack Traces

| Field | Value |
|-------|-------|
| Slug | `fix-multiline-java` |
| Title | `Fix Multiline Java Stack Traces` |
| Teaser | `Use Fleet Automation to fix Java stack traces` |
| Time Limit | 600 seconds |

**Assignment** - paste from `challenges/02-multiline-java/assignment.md`

**Check Script:**
```bash
#!/bin/bash
set -e
CONFIG="/etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml"
if ! grep -A 20 "legacy-monolith" "$CONFIG" | grep -q "log_processing_rules"; then
    fail-message "log_processing_rules not found for legacy-monolith. Add it via Fleet Automation."
    exit 1
fi
if ! grep -A 25 "legacy-monolith" "$CONFIG" | grep -q "multi_line"; then
    fail-message "multi_line type not found"
    exit 1
fi
echo "Multiline processing configured correctly!"
```

#### Challenge 3: Fix Multiline XML Logs

| Field | Value |
|-------|-------|
| Slug | `fix-multiline-xml` |
| Title | `Fix Multiline XML Logs` |
| Teaser | `Fix XML logs spanning multiple lines` |
| Time Limit | 600 seconds |

**Assignment** - paste from `challenges/03-multiline-xml/assignment.md`

**Check Script:**
```bash
#!/bin/bash
set -e
CONFIG="/etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml"
if ! grep -A 15 "user-service" "$CONFIG" | grep -q "log_processing_rules"; then
    fail-message "log_processing_rules not found for user-service"
    exit 1
fi
echo "XML multiline processing configured!"
```

#### Challenges 4-8: Pipeline Challenges

These challenges are solved in the Datadog UI (Logs → Pipelines), so the check scripts just pass. Create each one:

| # | Slug | Title | Teaser |
|---|------|-------|--------|
| 4 | `normalize-timestamps` | Normalize Timestamp Formats | Create a pipeline to handle inconsistent timestamps |
| 5 | `handle-missing-fields` | Handle Missing Fields | Track and manage logs with missing attributes |
| 6 | `parse-mixed-formats` | Parse Mixed Log Formats | Handle plain text errors in JSON log files |
| 7 | `flatten-nested-json` | Flatten Nested JSON | Extract attributes from nested JSON objects |
| 8 | `parse-xml-logs` | Extract Data from XML Logs | Parse XML logs to extract meaningful attributes |

**Time Limit for all**: 600 seconds

**Check Script for all** (pipelines are in Datadog UI, so just pass):
```bash
#!/bin/bash
echo "Pipeline configuration is done in the Datadog UI."
echo "Verify your pipeline is working by checking the logs."
```

**Assignment content** - paste from corresponding `challenges/0X-.../assignment.md` files, or use these:

<details>
<summary>Challenge 4: Normalize Timestamps (click to expand)</summary>

```markdown
# Normalize Timestamp Formats

Different services use different timestamp formats. Create a Log Pipeline to normalize them.

## The Problem

Look at logs from different services - timestamps vary:
- ISO 8601: 2024-01-15T10:30:45.000Z
- Log4j: 2024-01-15 10:30:45,123

## The Solution

1. Go to **Logs → Configuration → Pipelines**
2. Click **New Pipeline**
3. Set Filter: `env:workshop`
4. Add a **Date Remapper** processor
5. Set Date attribute: `timestamp`

Click Check when done.
```
</details>

<details>
<summary>Challenge 5: Handle Missing Fields (click to expand)</summary>

```markdown
# Handle Missing Fields

Some logs are missing `user_id` or `trace_id`.

## The Problem

1. Search for: `service:api-gateway`
2. Notice some logs are missing `user_id`

## The Solution

Option A: Create a facet on `@user_id` to track missing fields
Option B: Add a Category Processor to tag logs with missing fields

Click Check when done.
```
</details>

<details>
<summary>Challenge 6: Parse Mixed Formats (click to expand)</summary>

```markdown
# Parse Mixed Log Formats

Payment service sometimes logs plain text errors mixed with JSON.

## The Solution

1. Add a **Grok Parser** to your pipeline
2. Filter: `service:payment-service`
3. Add a rule for plain text:
   ```
   rule_text \[%{date("yyyy-MM-dd'T'HH:mm:ss.SSSZ"):timestamp}\] %{word:level} - %{data:message}
   ```

Click Check when done.
```
</details>

<details>
<summary>Challenge 7: Flatten Nested JSON (click to expand)</summary>

```markdown
# Flatten Nested JSON

Payment service logs contain nested `transaction` objects.

## The Problem

Search for: `service:payment-service`
Look at the `transaction` attribute - it's a nested object.

## The Solution

1. Add a **Remapper** processor to your pipeline
2. Create mappings:
   - Source: transaction.id → Target: transaction_id
   - Source: transaction.amount → Target: amount

Click Check when done.
```
</details>

<details>
<summary>Challenge 8: Extract Data from XML Logs (click to expand)</summary>

```markdown
# Extract Data from XML Logs

Parse XML logs to extract useful attributes.

## The Solution

1. Add a **Grok Parser** to your pipeline
2. Filter: `service:user-service`
3. Parsing rule:
   ```
   rule_xml <log>.*<timestamp>%{data:timestamp}</timestamp>.*<level>%{word:level}</level>.*<action>%{word:action}</action>.*</log>
   ```

Click Check when done.
```
</details>

---

### Step 8: Test Your Track

1. Look for a **"Test"** or **"Play"** button in the Instruqt UI
2. This launches a test instance of your track
3. Go through each challenge to verify:
   - VM starts correctly (wait 2-3 minutes for setup)
   - Agent is running: `sudo datadog-agent status`
   - Logs flow to Datadog
   - Fleet Automation shows the agent
   - Check scripts pass when challenges are completed

### Step 9: Publish (Optional)

1. Look for **"Settings"** or **"Publishing"** section
2. Set visibility (Private, Organization, or Public)
3. Click **Publish**

---

## Files Reference

This folder contains ready-to-paste content:

```
log-workshop-instruqt/
├── README.md                    # This file (contains the VM setup script)
└── challenges/
    ├── 01-explore/
    │   ├── assignment.md        # Paste into Assignment tab
    │   ├── setup.sh
    │   └── check.sh             # Paste into Check Script tab
    ├── 02-multiline-java/
    │   ├── assignment.md
    │   ├── setup.sh
    │   └── check.sh
    ├── 03-multiline-xml/
    │   ├── assignment.md
    │   ├── setup.sh
    │   └── check.sh
    ├── 04-timestamps/
    │   ├── assignment.md
    │   ├── setup.sh
    │   └── check.sh
    ├── 05-missing-fields/
    │   ├── assignment.md
    │   ├── setup.sh
    │   └── check.sh
    ├── 06-mixed-formats/
    │   ├── assignment.md
    │   ├── setup.sh
    │   └── check.sh
    ├── 07-nested-json/
    │   ├── assignment.md
    │   ├── setup.sh
    │   └── check.sh
    └── 08-xml-parsing/
        ├── assignment.md
        ├── setup.sh
        └── check.sh
```

**Note**: The VM setup script is embedded directly in this README (Step 6). No separate scripts folder needed.

---

## Troubleshooting

### Logs not appearing
- Check agent status: `sudo datadog-agent status`
- Check log generator: `sudo systemctl status log-generator`
- View logs: `tail -f /var/log/workshop/*.log`

### Fleet Automation not showing agent
- Verify `remote_configuration` and `remote_updates` are enabled
- Wait 2-3 minutes for agent to register
- Check: `sudo cat /etc/datadog-agent/datadog.yaml | grep remote`
