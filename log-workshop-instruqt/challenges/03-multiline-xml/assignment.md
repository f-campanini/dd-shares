# Fix Multiline XML Logs

The `user-service` outputs logs in XML format. When XML is pretty-printed across multiple lines, each line becomes a separate log entry.

In this challenge, you'll use **Fleet Automation** again to fix XML multiline logs.

## The Problem

1. Go to **Logs** in Datadog
2. Search for: `service:user-service`
3. Look for logs that show only partial XML like `<log>` or `</log>` or individual elements

Example of what you'll see (broken):
```
<log>
```
```
  <timestamp>2024-01-15T10:30:45.000Z</timestamp>
```
```
  <level>INFO</level>
```
... and so on

## The Solution

We need to tell the agent that each log entry starts with `<log>`.

### Step 1: Open Fleet Automation

1. Go to **Infrastructure → Fleet Automation**
2. Find the agent named **`instruqt-workshop-vm`**
3. Click on the agent to open its details

### Step 2: Edit logs_config

1. Navigate to the **logs_config** section
2. Find the configuration for `user-service`
3. Add a `log_processing_rules` section:

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

### Step 3: Deploy the Configuration

1. Save the changes
2. Wait for the agent to apply the new configuration

### Step 4: Verify the Fix

1. Go back to **Logs**
2. Search for: `service:user-service`
3. XML logs should now appear as **complete documents**

## How It Works

The `pattern: '<log>'` tells the agent that any line starting with `<log>` marks the beginning of a new log entry. All subsequent lines until the next `<log>` are aggregated together.

## Success Criteria

Click **Check** when XML logs appear as complete, single entries in Datadog.
