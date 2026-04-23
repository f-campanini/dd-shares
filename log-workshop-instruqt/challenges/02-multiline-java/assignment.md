# Fix Multiline Java Stack Traces

Java applications often log exceptions with stack traces that span multiple lines. By default, each line appears as a separate log entry in Datadog, making it hard to understand errors.

In this challenge, you'll use **Fleet Automation** to fix this issue directly from the Datadog UI.

## The Problem

1. Go to **Logs** in Datadog
2. Search for: `service:legacy-monolith status:error`
3. Notice that stack trace lines like `at com.mycompany...` appear as **separate entries**

Example of what you'll see (broken):
```
2024-01-15 10:30:45,123 [ERROR] [thread-42] UserController.processRequest - Failed to process request
```
And then separate entries for:
```
NullPointerException: Failed to process request
```
```
    at com.mycompany.api.UserController.processRequest(UserController.java:127)
```

## The Solution

We need to tell the agent to aggregate lines that don't start with a timestamp.

### Step 1: Open Fleet Automation

1. Go to **Infrastructure → Fleet Automation**
2. Find the agent named **`instruqt-workshop-vm`**
3. Click on the agent to open its details

### Step 2: Edit logs_config

1. Navigate to the **logs_config** section
2. Find the configuration for `legacy-monolith`
3. Add a `log_processing_rules` section:

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

### Step 3: Deploy the Configuration

1. Save the changes
2. Wait for the agent to apply the new configuration (usually under 30 seconds)

### Step 4: Verify the Fix

1. Go back to **Logs**
2. Search for: `service:legacy-monolith status:error`
3. Stack traces should now appear as **single log entries**

## How It Works

The `pattern` regex matches the start of a new log line (various timestamp formats):
- `^\d{4}-\d{2}-\d{2}\s` - Matches `2024-01-15 ...` (Log4j style)
- `^\d{2}/\w{3}/\d{4}:` - Matches `15/Jan/2024:...` (Apache style)
- `^\w{3}\s+\d{1,2}\s+` - Matches `Jan 15 ...` (Syslog style)

Any line that does NOT match this pattern is appended to the previous log entry.

## Success Criteria

Click **Check** when Java stack traces appear as single, aggregated log entries in Datadog.
