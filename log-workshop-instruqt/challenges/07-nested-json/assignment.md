# Flatten Nested JSON

Payment service logs contain nested `transaction` objects. In this challenge, you'll extract these nested attributes for easier querying and faceting.

## The Problem

1. Go to **Logs** in Datadog
2. Search for: `service:payment-service`
3. Click on a log and look at the `transaction` attribute - it's a nested object:

```json
"transaction": {
  "id": "txn_abc123",
  "amount": 1500,
  "currency": "USD"
}
```

You can't easily create facets or filter on `transaction.id` without flattening it first.

## The Solution

Add a **Remapper** processor to flatten nested attributes.

1. Go to **Logs → Configuration → Pipelines**
2. Open your workshop pipeline (or create one with filter `env:workshop`)
3. Click **Add Processor**
4. Select **Remapper**
5. Configure:
   - **Name**: `Flatten Transaction`
   - **Source attribute**: `transaction.id`
   - **Target attribute**: `transaction_id`
6. Repeat for other fields:
   - `transaction.amount` → `amount`
   - `transaction.currency` → `currency`

## Verification

After adding the remapper:
1. Search for new logs: `service:payment-service`
2. Check that `transaction_id`, `amount`, and `currency` appear as top-level attributes
3. Try creating a facet on `@amount`

## Success Criteria

Click **Check** when nested transaction fields are accessible as top-level attributes.
