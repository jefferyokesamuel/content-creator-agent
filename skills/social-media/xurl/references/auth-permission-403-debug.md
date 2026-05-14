# OAuth1 Permission 403 Debug — Real Session Trace

This file documents a real debugging session where `xurl post` returned a 403
with `"Your client app is not configured with the appropriate oauth1 app
permissions for this endpoint"`. The root cause was the Twitter Developer App
having OAuth1 set to **Read-only** instead of **Read and Write**.

## Full Diagnostic Trace

### Initial state
- `xurl auth status` → `oauth1: ✓` (tokens present)
- `xurl whoami` → ✅ Works (returns user data for @web3jeffery)

### First attempt
```bash
xurl post "Africa has no correspondent banking problem..."  # FAILS
```
Response:
```json
{
  "title": "Forbidden",
  "status": 403,
  "detail": "Your client app is not configured with the appropriate oauth1 app permissions for this endpoint.",
  "type": "https://api.twitter.com/2/problems/oauth1-permissions"
}
```

### Config inspected
`~/.xurl` had:
- ✅ OAuth1 tokens present (access_token, token_secret, consumer_key, consumer_secret)
- ❌ client_id and client_secret empty (OAuth2 not configured)

### Dead-end attempts (all documented as non-solutions for cron)

| Attempt | Result | Why |
|---|---|---|
| `xurl -X POST /2/tweets -d '...' --auth oauth1` | Same 403 | Same OAuth1 permission issue |
| `xurl post --auth oauth2` | Timed out | OAuth2 PKCE needs interactive browser redirect |
| `tweepy.api.update_status()` (v1.1) | 403 "453 - Free tier subset" | Free tier blocks v1.1 statuses/update |
| `requests_oauthlib` OAuth1-signed POST to v2 | Same 403 | Same OAuth1 permission issue |
| Environment variables / bearer tokens | None found | Not configured |

### Root cause confirmed

The Twitter Developer Portal App:
1. Had OAuth1 enabled
2. But OAuth1 permissions were set to **Read only** 
3. `whoami` works (read) while `post` fails (write) is the telltale symptom

### Required fix

**Twitter Developer Portal** → App → **User authentication settings** →
- Set OAuth 1.0a permission to **"Read and Write"** (or "Read, Write, and Direct Messages")
- Save
- **Keys and Tokens** tab → Regenerate Access Token and Secret
- Re-run `xurl auth oauth1` with new tokens

### Pitfall: Token Regeneration Required After Permission Change

Even after changing OAuth1 permissions from "Read only" to "Read and Write" and
clicking **Save**, posting will still 403. **You must also regenerate the Access
Token and Secret** in **Keys and Tokens**, because the existing token was issued
under the old Read-only scope. The permission change only affects future tokens.

## Pitfall: "Save Changes" Button Won't Activate

When editing User Authentication Settings in the X Developer Portal, the Save
Changes button stays greyed/unclickable if any required URL field has an invalid
value or is empty. Common causes:

| Issue | Fix |
|---|---|
| Callback URI set to a non-resolving subdomain (e.g. `https://developers.coinomad.xyz/callback`) | Use `http://localhost:8080/callback` — this is what xurl expects for the OAuth redirect |
| Website URL doesn't resolve or is missing | Use `https://coinomad.xyz` or a valid, reachable domain |
| Any required field empty | Fill all fields with red asterisks |

The Portal validates URLs before enabling the button. Validation errors appear
as inline text next to each field (e.g. "Only valid HTTP(S) urls are allowed").
Click into each field to trigger the validation message.

If `xurl whoami` works but `xurl post` 403s, do NOT troubleshoot networking,
token expiry, or tool alternatives. The app permissions in the Twitter
Developer Portal are wrong — specifically OAuth1 write permission is missing.
The only fix is portal-side. All other approaches (OAuth2, tweepy, raw HTTP)
will also fail.
