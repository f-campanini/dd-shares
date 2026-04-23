# Handle Missing Fields

Some logs are missing important fields like `user_id` or `trace_id`. In this challenge, you'll learn to identify and handle these missing fields.

## The Problem

1. Go to **Logs** in Datadog
2. Search for: `service:api-gateway`
3. Click on several logs and check the attributes
4. Notice that some logs are missing `user_id` or `trace_id`

## The Solution

### Option A: Create a Facet to Track Missing Fields

1. Go to **Logs → Configuration → Facets**
2. Create a facet on `@user_id`
3. In the Logs explorer, use: `service:api-gateway -@user_id:*` to find logs without user_id

### Option B: Add a Category Processor

1. Open your workshop pipeline
2. Add a **Category Processor**
3. Set rules to tag logs with missing fields:
   - **Name**: `Tag Missing Fields`
   - **Category**: `missing_user_id` when `NOT @user_id:*`

### Option C: Add Default Values

1. Add a **Remapper** processor
2. Set a default value for missing fields

## Success Criteria

Click **Check** when you can identify logs with missing fields using facets or category tags.
