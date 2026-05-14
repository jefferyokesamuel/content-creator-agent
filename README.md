# Deployment package for Hermes Content Creator Agent

## Quick Deploy to Railway

1. Install the Railway CLI:
   ```bash
   npm i -g @railway/cli
   ```

2. Login:
   ```bash
   railway login
   ```

3. From this directory:
   ```bash
   railway init
   railway up
   ```

4. Set environment variables in Railway Dashboard:
   - `TELEGRAM_BOT_TOKEN` = your bot token
   - `DEEPSEEK_API_KEY` = your DeepSeek API key

## Environment Variables Needed

| Variable | Description |
|---|---|
| `TELEGRAM_BOT_TOKEN` | Bot token from @BotFather |
| `DEEPSEEK_API_KEY` | DeepSeek API key |

## Local Testing

```bash
# Build
docker build -t content-agent .

# Run with env vars
docker run -e TELEGRAM_BOT_TOKEN="your_token" -e DEEPSEEK_API_KEY="your_key" content-agent
```

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Container build |
| `start.sh` | Entrypoint that configures Hermes and starts gateway |
| `skills/` | All content/SM skills pre-loaded |
