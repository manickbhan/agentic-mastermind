# /send-slack

Post a message to Slack via an Incoming Webhook.

## Instructions

### Prerequisites

The user must have `SLACK_WEBHOOK_URL` set in their `.env` file. If not configured, direct them to:
1. Go to https://api.slack.com/messaging/webhooks
2. Create an Incoming Webhook for their workspace/channel
3. Add the webhook URL to `.env`

### Step 1: Compose Message

Ask the user what they want to post. Common patterns:
- Results from a workflow (e.g., "post the SEO report we just ran")
- Custom update or announcement
- Client status summary

### Step 2: Format Message

Format the message using Slack's mrkdwn syntax:
- `*bold*` for emphasis
- Bullet lists with `-` or `•`
- Links: `<url|text>`
- Emoji: `:white_check_mark:`, `:chart_with_upwards_trend:`, etc.

### Step 3: Send

Use the `integrations/slack/send-message.sh` script:

```bash
source .env
bash integrations/slack/send-message.sh "$SLACK_WEBHOOK_URL" "Your formatted message here"
```

Or send directly via curl:

```bash
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"text": "Your message here"}'
```

### Step 4: Confirm

Show the user what was sent and confirm delivery.

## Output Format

```
✅ Message sent to Slack

📨 Channel: {channel_name} (from webhook config)
📝 Preview:
   {message preview}
```

## Golden Rules

- Never expose the webhook URL in output
- Always show a preview before sending
- Format for Slack's mrkdwn, not regular markdown
