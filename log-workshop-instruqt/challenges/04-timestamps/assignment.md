# Normalize Timestamp Formats

Different services use different timestamp formats, making time-based correlation difficult. In this challenge, you'll create a **Log Pipeline** to normalize timestamps.

## The Problem

1. Go to **Logs** in Datadog
2. Look at logs from different services - notice the timestamps vary:
   - ISO 8601: `2024-01-15T10:30:45.000Z`
   - Log4j: `2024-01-15 10:30:45,123`
   - European: `15-01-2024 10:30:45`
   - Unix: `1705315845`

The `@timestamp` attribute might not match the actual log time!

## The Solution

We'll create a Log Pipeline with a **Date Remapper** processor.

### Step 1: Create a Pipeline

1. Go to **Logs → Configuration → Pipelines**
2. Click **New Pipeline**
3. Set:
   - **Filter**: `env:workshop`
   - **Name**: `Workshop Logs Pipeline`
4. Click **Create**

### Step 2: Add a Grok Parser (for plain text logs)

For `legacy-monolith`, we need to extract the timestamp first:

1. Click **Add Processor** inside your pipeline
2. Select **Grok Parser**
3. Set:
   - **Name**: `Parse Legacy Monolith`
   - **Filter**: `service:legacy-monolith`
   - **Parsing rules**:
     ```
     rule %{date("yyyy-MM-dd HH:mm:ss,SSS"):timestamp} \[%{word:level}\] \[%{data:thread}\] %{data:class}\.%{word:method} - %{data:message}
     ```

### Step 3: Add a Date Remapper

1. Click **Add Processor**
2. Select **Date Remapper**
3. Set:
   - **Name**: `Set Log Date`
   - **Date attribute**: `timestamp`
4. Click **Create**

### Step 4: Verify the Fix

1. Go to **Logs**
2. Search for: `env:workshop`
3. Check that log timestamps are correctly parsed and used for ordering

## Success Criteria

Click **Check** when you have a pipeline with a Date Remapper processor that correctly parses timestamps.
