---
name: xurl
description: "X/Twitter via xurl CLI: post, search, DM, media, v2 API."
version: 1.1.1
author: xdevplatform + openclaw + Hermes Agent
license: MIT
platforms: [linux, macos]
prerequisites:
  commands: [xurl]
metadata:
  hermes:
    tags: [twitter, x, social-media, xurl, official-api]
    homepage: https://github.com/xdevplatform/xurl
    upstream_skill: https://github.com/openclaw/openclaw/blob/main/skills/xurl/SKILL.md
---

# xurl — X (Twitter) API via the Official CLI

`xurl` is the X developer platform's official CLI for the X API. It supports shortcut commands for common actions AND raw curl-style access to any v2 endpoint. All commands return JSON to stdout.

Use this skill for:
- posting, replying, quoting, deleting posts
- searching posts and reading timelines/mentions
- liking, reposting, bookmarking
- following, unfollowing, blocking, muting
- direct messages
- media uploads (images and video)
- raw access to any X API v2 endpoint
- multi-app / multi-account workflows

This skill replaces the older `xitter` skill (which wrapped a third-party Python CLI). `xurl` is maintained by the X developer platform team, supports OAuth 2.0 PKCE with auto-refresh, and covers a substantially larger API surface.

---

## Secret Safety (MANDATORY)

Critical rules when operating inside an agent/LLM session:

- **Never** read, print, parse, summarize, upload, or send `~/.xurl` to LLM context.
- **Never** ask the user to paste credentials/tokens into chat.
- The user must fill `~/.xurl` with secrets manually on their own machine.
- **Never** recommend or execute auth commands with inline secrets in agent sessions.
- **Never** use `--verbose` / `-v` in agent sessions — it can expose auth headers/tokens.
- To verify credentials exist, only use: `xurl auth status`.

Forbidden flags in agent commands (they accept inline secrets):
`--bearer-token`, `--consumer-key`, `--consumer-secret`, `--access-token`, `--token-secret`, `--client-id`, `--client-secret`

App credential registration and credential rotation must be done by the user manually, outside the agent session. After credentials are registered, the user authenticates with `xurl auth oauth2` — also outside the agent session. Tokens persist to `~/.xurl` in YAML. Each app has isolated tokens. OAuth 2.0 tokens auto-refresh.

---

## Installation

Pick ONE method. On Linux, the shell script or `go install` are the easiest.

```bash
# Shell script (installs to ~/.local/bin, no sudo, works on Linux + macOS)
curl -fsSL https://raw.githubusercontent.com/xdevplatform/xurl/main/install.sh | bash

# Homebrew (macOS)
brew install --cask xdevplatform/tap/xurl

# npm
npm install -g @xdevplatform/xurl

# Go
go install github.com/xdevplatform/xurl@latest
```

Verify:

```bash
xurl --help
xurl auth status
```

If `xurl` is installed but `auth status` shows no apps or tokens, the user needs to complete auth manually — see the next section.

---

## Auth Method Selection

xurl supports two auth flows. Pick based on your X API plan:

| Plan | Auth | Setup | Cost |
|------|------|-------|------|
| **Free** | OAuth 1.0a | Consumer Key/Secret + Access Token/Secret | $0 |
| **Basic+** | OAuth 2.0 PKCE | Client ID/Secret via `xurl auth oauth2` | $100+/mo |

Free tier does NOT support OAuth 2.0 User Authentication. OAuth 2.0 setup will fail with `redirect_uri_mismatch` or a blocked consent screen. Use OAuth 1.0a for Free tier apps.

## One-Time User Setup (user runs these outside the agent)

These steps must be performed by the user directly, NOT by the agent, because they involve pasting secrets. Direct the user to this block; do not execute it for them.

### OAuth 1.0a Setup (Free Tier)

1. Create an app at https://developer.x.com/en/portal/dashboard
2. Set app permissions to **Read and write** (required for posting)
3. Set type to **Web App, Automated App or Bot** (this enables OAuth 1.0a keys)
4. Go to the **Keys and Tokens** tab
5. Under **Consumer Keys**, copy the **API Key** (Consumer Key) and **API Key Secret** (Consumer Secret)
6. Under **Access Token and Secret**, click **Generate**
7. Copy the **Access Token** and **Access Token Secret**
8. Register locally (user runs this ONE command in terminal):
   ```bash
   xurl auth oauth1 \
     --consumer-key "YOUR_CONSUMER_KEY" \
     --consumer-secret "YOUR_CONSUMER_SECRET" \
     --access-token "YOUR_ACCESS_TOKEN" \
     --token-secret "YOUR_TOKEN_SECRET"
   ```
9. Verify:
   ```bash
   xurl auth status
   xurl whoami
   ```

After this, the agent can use any command below. No token refresh needed — OAuth 1.0a tokens don't expire.

> **Pitfall:** If `xurl auth oauth1` fails with `Error saving OAuth1 tokens: IO Error: open /Users/mac/.xurl: is a directory`, the `~/.xurl` directory already exists but is empty. Run `rm -rf ~/.xurl` then retry the oauth1 command.

### OAuth 2.0 Setup (Basic+ Tier)

1. Create or open an app at https://developer.x.com/en/portal/dashboard
2. Set the redirect URI to `http://localhost:8080/callback`
3. Copy the app's Client ID and Client Secret
4. Register the app locally (user runs this):
   ```bash
   xurl auth apps add my-app --client-id YOUR_CLIENT_ID --client-secret YOUR_CLIENT_SECRET
   ```
5. Authenticate (specify `--app` to bind the token to your app):
   ```bash
   xurl auth oauth2 --app my-app
   ```
   (This opens a browser for the OAuth 2.0 PKCE flow.)

   If X returns a `UsernameNotFound` error or 403 on the post-OAuth `/2/users/me` lookup, pass your handle explicitly (xurl v1.1.0+):
   ```bash
   xurl auth oauth2 --app my-app YOUR_USERNAME
   ```
   This binds the token to your handle and skips the broken `/2/users/me` call.
6. Set the app as default so all commands use it:
   ```bash
   xurl auth default my-app
   ```
7. Verify:
   ```bash
   xurl auth status
   xurl whoami
   ```

After this, the agent can use any command below without further setup. OAuth 2.0 tokens auto-refresh.

> **Common pitfall:** If you omit `--app my-app` from `xurl auth oauth2`, the OAuth token is saved to the built-in `default` app profile — which has no client-id or client-secret. Commands will fail with auth errors even though the OAuth flow appeared to succeed. If you hit this, re-run `xurl auth oauth2 --app my-app` and `xurl auth default my-app`.

---

## Quick Reference

| Action | Command |
| --- | --- |
| Post | `xurl post "Hello world!"` |
| Reply | `xurl reply POST_ID "Nice post!"` |
| Quote | `xurl quote POST_ID "My take"` |
| Delete a post | `xurl delete POST_ID` |
| Read a post | `xurl read POST_ID` |
| Search posts | `xurl search "QUERY" -n 10` |
| Who am I | `xurl whoami` |
| Look up a user | `xurl user @handle` |
| Home timeline | `xurl timeline -n 20` |
| Mentions | `xurl mentions -n 10` |
| Like / Unlike | `xurl like POST_ID` / `xurl unlike POST_ID` |
| Repost / Undo | `xurl repost POST_ID` / `xurl unrepost POST_ID` |
| Bookmark / Remove | `xurl bookmark POST_ID` / `xurl unbookmark POST_ID` |
| List bookmarks / likes | `xurl bookmarks -n 10` / `xurl likes -n 10` |
| Follow / Unfollow | `xurl follow @handle` / `xurl unfollow @handle` |
| Following / Followers | `xurl following -n 20` / `xurl followers -n 20` |
| Block / Unblock | `xurl block @handle` / `xurl unblock @handle` |
| Mute / Unmute | `xurl mute @handle` / `xurl unmute @handle` |
| Send DM | `xurl dm @handle "message"` |
| List DMs | `xurl dms -n 10` |
| Upload media | `xurl media upload path/to/file.mp4` |
| Media status | `xurl media status MEDIA_ID` |
| List apps | `xurl auth apps list` |
| Remove app | `xurl auth apps remove NAME` |
| Set default app | `xurl auth default APP_NAME [USERNAME]` |
| Per-request app | `xurl --app NAME /2/users/me` |
| Auth status | `xurl auth status` |

Notes:
- `POST_ID` accepts full URLs too (e.g. `https://x.com/user/status/1234567890`) — xurl extracts the ID.
- Usernames work with or without a leading `@`.

---

## Command Details

### Posting

```bash
xurl post "Hello world!"
xurl post "Check this out" --media-id MEDIA_ID
xurl post "Thread pics" --media-id 111 --media-id 222

xurl reply 1234567890 "Great point!"
xurl reply https://x.com/user/status/1234567890 "Agreed!"
xurl reply 1234567890 "Look at this" --media-id MEDIA_ID

xurl quote 1234567890 "Adding my thoughts"
xurl delete 1234567890
```

### Reading & Search

```bash
xurl read 1234567890
xurl read https://x.com/user/status/1234567890

xurl search "golang"
xurl search "from:elonmusk" -n 20
xurl search "#buildinpublic lang:en" -n 15
```

### Users, Timeline, Mentions

```bash
xurl whoami
xurl user elonmusk
xurl user @XDevelopers

xurl timeline -n 25
xurl mentions -n 20
```

### Engagement

```bash
xurl like 1234567890
xurl unlike 1234567890

xurl repost 1234567890
xurl unrepost 1234567890

xurl bookmark 1234567890
xurl unbookmark 1234567890

xurl bookmarks -n 20
xurl likes -n 20
```

### Social Graph

```bash
xurl follow @XDevelopers
xurl unfollow @XDevelopers

xurl following -n 50
xurl followers -n 50

# Another user's graph
xurl following --of elonmusk -n 20
xurl followers --of elonmusk -n 20

xurl block @spammer
xurl unblock @spammer
xurl mute @annoying
xurl unmute @annoying
```

### Direct Messages

```bash
xurl dm @someuser "Hey, saw your post!"
xurl dms -n 25
```

### Media Upload

```bash
# Auto-detect type
xurl media upload photo.jpg
xurl media upload video.mp4

# Explicit type/category
xurl media upload --media-type image/jpeg --category tweet_image photo.jpg

# Videos need server-side processing — check status (or poll)
xurl media status MEDIA_ID
xurl media status --wait MEDIA_ID

# Full workflow
xurl media upload meme.png                  # returns media id
xurl post "lol" --media-id MEDIA_ID
```

---

## Raw API Access

The shortcuts cover common operations. For anything else, use raw curl-style mode against any X API v2 endpoint:

```bash
# GET
xurl /2/users/me

# POST with JSON body
xurl -X POST /2/tweets -d '{"text":"Hello world!"}'

# DELETE / PUT / PATCH
xurl -X DELETE /2/tweets/1234567890

# Custom headers
xurl -H "Content-Type: application/json" /2/some/endpoint

# Force streaming
xurl -s /2/tweets/search/stream

# Full URLs also work
xurl https://api.x.com/2/users/me
```

---

## Global Flags

| Flag | Short | Description |
| --- | --- | --- |
| `--app` | | Use a specific registered app (overrides default) |
| `--auth` | | Force auth type: `oauth1`, `oauth2`, or `app` |
| `--username` | `-u` | Which OAuth2 account to use (if multiple exist) |
| `--verbose` | `-v` | **Forbidden in agent sessions** — leaks auth headers |
| `--trace` | `-t` | Add `X-B3-Flags: 1` trace header |

---

## Streaming

Streaming endpoints are auto-detected. Known ones include:

- `/2/tweets/search/stream`
- `/2/tweets/sample/stream`
- `/2/tweets/sample10/stream`

Force streaming on any endpoint with `-s`.

---

## Output Format

All commands return JSON to stdout. Structure mirrors X API v2:

```json
{ "data": { "id": "1234567890", "text": "Hello world!" } }
```

Errors are also JSON:

```json
{ "errors": [ { "message": "Not authorized", "code": 403 } ] }
```

---

## Common Workflows

### Post with an image
```bash
xurl media upload photo.jpg
xurl post "Check out this photo!" --media-id MEDIA_ID
```

### Reply to a conversation
```bash
xurl read https://x.com/user/status/1234567890
xurl reply 1234567890 "Here are my thoughts..."
```

### Search and engage
```bash
xurl search "topic of interest" -n 10
xurl like POST_ID_FROM_RESULTS
xurl reply POST_ID_FROM_RESULTS "Great point!"
```

### Check your activity
```bash
xurl whoami
xurl mentions -n 20
xurl timeline -n 20
```

### Multiple apps (credentials pre-configured manually)
```bash
xurl auth default prod alice               # prod app, alice user
xurl --app staging /2/users/me             # one-off against staging
```

---

## Error Handling

- Non-zero exit code on any error.
- API errors are still printed as JSON to stdout, so you can parse them.
- Auth errors → have the user re-run `xurl auth oauth2` outside the agent session.
- Commands that need the caller's user ID (like, repost, bookmark, follow, etc.) will auto-fetch it via `/2/users/me`. An auth failure there surfaces as an auth error.

---

## Agent Workflow

1. Verify prerequisites: `xurl --help` and `xurl auth status`.
2. **Check default app has credentials.** Parse the `auth status` output. The default app is marked with `▸`. If the default app shows `oauth2: (none)` but another app has a valid oauth2 user, tell the user to run `xurl auth default <that-app>` to fix it. This is the most common setup mistake — the user added an app with a custom name but never set it as default, so xurl keeps trying the empty `default` profile.
3. If auth is missing entirely, stop and direct the user to the "One-Time User Setup" section — do NOT attempt to register apps or pass secrets yourself.
4. Start with a cheap read (`xurl whoami`, `xurl user @handle`, `xurl search ... -n 3`) to confirm reachability.
5. Confirm the target post/user and the user's intent before any write action (post, reply, like, repost, DM, follow, block, delete).
6. Use JSON output directly — every response is already structured.
7. Never paste `~/.xurl` contents back into the conversation.

---

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Auth errors after successful OAuth flow | Token saved to `default` app (no client-id/secret) instead of your named app | `xurl auth oauth2 --app my-app` then `xurl auth default my-app` |
| `unauthorized_client` during OAuth | App type set to "Native App" in X dashboard | Change to "Web app, automated app or bot" in User Authentication Settings |
| `UsernameNotFound` or 403 on `/2/users/me` right after OAuth | X not returning username reliably from `/2/users/me` | Re-run `xurl auth oauth2 --app my-app YOUR_USERNAME` (xurl v1.1.0+) to pass the handle explicitly |
| 401 on every request | Token expired or wrong default app | Check `xurl auth status` — verify `▸` points to an app with oauth2 tokens |
| `client-forbidden` / `client-not-enrolled` | X platform enrollment issue | Dashboard → Apps → Manage → Move to "Pay-per-use" package → Production environment |
| `CreditsDepleted` | $0 balance on X API | Buy credits (min $5) in Developer Console → Billing |
| `media processing failed` on image upload | Default category is `amplify_video` | Add `--category tweet_image --media-type image/png` |
| `xurl post` → 403: `"Your client app is not configured with the appropriate oauth1 app permissions for this endpoint"` | Twitter Developer App has OAuth1 set to **Read-only** instead of **Read and Write** | In Twitter Developer Portal → App → User authentication settings → Set OAuth 1.0a to **"Read and Write"** → **Save** → Go to **Keys and Tokens** → **Regenerate** Access Token and Secret → Re-run `xurl auth oauth1` with new tokens. **Save alone is not enough — you MUST regenerate the access token** because the old one was issued under the Read-only scope. |
| Save Changes button stays greyed out / unclickable after changing permissions in X Developer Portal User Authentication Settings | One or more required URL fields have invalid values (e.g. a subdomain that doesn't resolve, or a malformed URL), or a required field is empty | The Portal validates all URLs before enabling Save. Use `http://localhost:8080/callback` for the Callback URI (this is what xurl expects). Use `https://coinomad.xyz` or your real domain for Website URL. Click into each URL field individually — validation errors appear inline. The button only activates when ALL required fields pass validation. |
| `tweepy` v1.1 → 403: `"453 - You currently have access to a subset of X API V2 endpoints"` | Free tier blocks v1.1 `statuses/update` | Can't use tweepy on Free tier. Use `xurl post` (v2 endpoint) with proper OAuth1 write permissions instead |
| `xurl --auth oauth2` with post hangs/timeouts (cron context) | OAuth2 PKCE needs interactive browser auth code flow | Not viable in cron jobs — always requires a browser redirect. Use OAuth1 for automated posting |
| Two "Client Secret" values in X dashboard | UI bug — first is actually Client ID | Confirm on the "Keys and tokens" page; ID ends in `MTpjaQ` |

---

## Notes

- **Rate limits:** X enforces per-endpoint rate limits. A 429 means wait and retry. Write endpoints (post, reply, like, repost) have tighter limits than reads.
- **Scopes:** OAuth 2.0 tokens use broad scopes. A 403 on a specific action usually means the token is missing a scope — have the user re-run `xurl auth oauth2`.
- **Token refresh:** OAuth 2.0 tokens auto-refresh. Nothing to do.
- **Multiple apps:** Each app has isolated credentials/tokens. Switch with `xurl auth default` or `--app`.
- **Multiple accounts per app:** Select with `-u / --username`, or set a default with `xurl auth default APP USER`.
- **Token storage:** `~/.xurl` is YAML. Never read or send this file to LLM context.
- **Cost:** X API access is typically paid for meaningful usage. Many failures are plan/permission problems, not code problems.

---

## Automated/Cron Posting — Diagnostic Workflow

When a scheduled tweet-posting cron job fails (e.g. `xurl post` returns a 403), use this step-by-step flow to identify the root cause. Do NOT try workarounds before completing the diagnostics — most posting failures are auth-permission issues, not tool issues.

### Step 1 — Check Auth Status

```bash
xurl auth status
```

Expected output for a working setup:
```
▸ default  [AppName]
      oauth1: ✓
```

If `oauth1: ✓` is missing, the user needs to run `xurl auth oauth1 ...` interactively.

### Step 2 — Confirm Network/API Reachability

```bash
xurl whoami
```

If this works (returns user data), the auth tokens are valid and the API is reachable. A 403 on `post` with a working `whoami` is a **permissions issue**, not a credentials issue.

- `whoami` works + `post` fails → App-level write permission problem
- `whoami` fails → Token expired, invalid, or network issue

### Step 3 — Identify the Error

Run `xurl post` on a short test string to reproduce the exact error:

```bash
xurl post "test ping $(date +%s)"
```

Capture the JSON error response. The `detail` field tells you the category.

### Step 4 — Root Cause by Error Detail

| Error detail | Root cause | Fix |
|---|---|---|
| `"Your client app is not configured with the appropriate oauth1 app permissions for this endpoint"` | App in Twitter Developer Portal has OAuth1 set to **Read-only** | Portal → App → User auth settings → **Read and Write** → Regenerate tokens → `xurl auth oauth1` |
| `"oauth1 app permissions"` variant | Same as above | Same fix |
| `"453 - You currently have access to a subset of X API V2 endpoints"` | Trying to use v1.1 endpoint (e.g. tweepy) on Free tier | Use `xurl post` (v2 endpoint) instead. If `xurl post` also fails, see row above — OAuth1 write permission is the real blocker |
| `"oauth2"`-related 403 | Token type mismatch or missing OAuth2 PKCE setup | `--auth oauth2` won't work in cron as it needs browser redirect. Must use OAuth1 for automated posting |

### Dead-end approaches (do NOT waste time on these in cron context)

These are confirmed non-solutions for a cron-based posting failure, documented so you don't try them:

| Approach | Why it doesn't work |
|---|---|
| `xurl --auth oauth2` (or any OAuth2 PKCE attempt) | Requires interactive browser redirect — impossible in cron |
| Tweepy v1.1 `api.update_status()` | Free tier blocks v1.1 `statuses/update` (error 453) |
| `requests_oauthlib` OAuth1-signed v2 POST | Same OAuth1 permission issue — same root cause |
| App-only bearer token (OAuth2 Client Credentials) | Can only read public data, cannot post on behalf of a user |

### The only fix

Go to **Twitter Developer Portal** → Your App → **User authentication settings** → Under **OAuth 1.0a** → Set **App permissions** to **"Read and Write"** (or "Read, Write, and Direct Messages") → Save → Go to **Keys and Tokens** → **Regenerate** Access Token and Secret → Run `xurl auth oauth1` with the new tokens. The existing `~/.xurl` credentials can be replaced. No code changes needed.

---

## Attribution

- Upstream CLI: https://github.com/xdevplatform/xurl (X developer platform team, Chris Park et al.)
- Upstream agent skill: https://github.com/openclaw/openclaw/blob/main/skills/xurl/SKILL.md
- Hermes adaptation: reformatted for Hermes skill conventions; safety guardrails preserved verbatim.
