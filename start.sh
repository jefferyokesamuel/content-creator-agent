#!/bin/bash
set -e

echo "=== Content Creator Agent Starting ==="

mkdir -p /root/.hermes

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

# Start a minimal health server so Railway knows the container is alive
# (the gateway uses outbound polling, not inbound HTTP)
echo "=== Starting health server on port 8080 ==="
python3 -c "
import http.server, threading

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')
    def log_message(self, *a):
        pass

server = http.server.HTTPServer(('0.0.0.0', 8080), HealthHandler)
threading.Thread(target=server.serve_forever, daemon=True).start()
" &

echo "=== Starting Hermes Gateway ==="
exec hermes gateway run --accept-hooks
