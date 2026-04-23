# Extract Data from XML Logs

The `user-service` logs are in XML format. While they're now properly aggregated as single entries (thanks to Challenge 3), the XML content isn't parsed into searchable attributes.

## The Problem

1. Go to **Logs** in Datadog
2. Search for: `service:user-service`
3. Click on a log - you'll see the raw XML in the message, but attributes like `user.name`, `action`, etc. aren't extracted

Example log:
```xml
<log>
  <timestamp>2024-01-15T10:30:45.000Z</timestamp>
  <level>INFO</level>
  <service>user-service</service>
  <user>
    <name>alice</name>
    <id>usr_1001</id>
  </user>
  <action>LOGIN</action>
  <status>SUCCESS</status>
</log>
```

## The Solution

Add a **Grok Parser** to extract data from XML.

1. Go to **Logs → Configuration → Pipelines**
2. Open your workshop pipeline
3. Click **Add Processor**
4. Select **Grok Parser**
5. Configure:
   - **Name**: `Parse XML User Service`
   - **Filter**: `service:user-service` (only apply to user-service logs)
   - **Parsing rules**:
   ```
   rule_xml <log>.*<level>%{word:level}</level>.*<user>.*<name>%{data:user.name}</name>.*<id>%{data:user.id}</id>.*</user>.*<action>%{word:action}</action>.*<status>%{word:status}</status>.*</log>
   ```

## Verification

After adding the parser:
1. Search for new logs: `service:user-service`
2. Check that `user.name`, `user.id`, `action`, and `status` appear as attributes
3. Try filtering: `@action:LOGIN`

## Success Criteria

Click **Check** when XML attributes like `user.name`, `action`, etc. are extracted as searchable attributes.
