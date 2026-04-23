# Parse Mixed Log Formats

The `payment-service` occasionally logs plain text errors mixed with JSON logs. In this challenge, you'll create a parser that handles both formats.

## The Problem

1. Go to **Logs** in Datadog
2. Search for: `service:payment-service status:error`
3. Notice some errors are plain text instead of JSON:
   ```
   [2024-01-15T10:30:45.000Z] ERROR - Payment failed for transaction txn_abc123: Gateway timeout
   ```

## The Solution

Add a **Grok Parser** with multiple rules to handle both formats.

### Step 1: Add Grok Parser

1. Open your workshop pipeline
2. Add a **Grok Parser** processor
3. Set:
   - **Name**: `Parse Payment Service`
   - **Filter**: `service:payment-service`
   - **Parsing rules**:
     ```
     rule_text \[%{date("yyyy-MM-dd'T'HH:mm:ss.SSSZ"):timestamp}\] %{word:level} - %{data:message}
     ```

The JSON logs will be auto-parsed, and this rule catches the plain text fallback.

## Success Criteria

Click **Check** when both JSON and plain text payment service logs are properly parsed.
