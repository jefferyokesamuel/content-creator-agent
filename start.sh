#!/bin/bash
set -e

echo "=== Content Creator Agent Starting ==="

# Ensure .hermes directory exists
mkdir -p /root/.hermes

# Check for required env vars
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "ERROR: TELEGRAM_BOT_TOKEN is not set"
  exit 1
fi

if [ -z "$DEEPSEEK_API_KEY" ]; then
  echo "ERROR: DEEPSEEK_API_KEY is not set"
  exit 1
fi

# Build the .env file from environment variables
cat > /root/.hermes/.env << EOF
DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
EOF

# Build config.yaml
cat > /root/.hermes/config.yaml << 'CONFIGEOF'
model:
  default: deepseek-chat
  provider: deepseek
  base_url: https://api.deepseek.com

agent:
  max_turns: 90
  gateway_timeout: 1800
  gateway_timeout_warning: 900
  gateway_notify_interval: 180
  tool_use_enforcement: auto
  image_input_mode: auto
  verbose: false
  reasoning_effort: medium
  personalities:
    content-creator: >-
      You are a creative content creation assistant who helps TikTok creators.
      You are warm, supportive, and give actionable feedback. You understand
      TikTok trends, hook formulas, engagement psychology, and content strategy.
      You help with script writing, hook optimization, content planning,
      analytics review, and brand voice consistency across multiple accounts.
      Be specific and practical — give concrete examples, not vague advice.
  system_prompt: >-
    You are a creative content creation assistant who helps TikTok creators
    grow their accounts. You specialize in short-form video strategy, hook
    writing, script optimization, content planning, and growth analytics.

terminal:
  backend: local
  timeout: 180
  cwd: /tmp

gateway:
  enabled: true

platform_toolsets:
  telegram: [hermes-telegram]

platforms:
  telegram:
    reply_to_mode: "first"

memory:
  memory_enabled: true
  user_profile_enabled: true

cron:
  enabled: true
CONFIGEOF

# Copy skills if they exist
SKILLS_SRC="/app/skills"
SKILLS_DST="/root/.hermes/skills"
if [ -d "$SKILLS_SRC" ]; then
  mkdir -p "$SKILLS_DST"
  cp -r "$SKILLS_SRC/"* "$SKILLS_DST/" 2>/dev/null || true
  echo "Skills copied from $SKILLS_SRC"
fi

echo "=== Starting Hermes Gateway ==="
exec hermes gateway run --accept-hooks
