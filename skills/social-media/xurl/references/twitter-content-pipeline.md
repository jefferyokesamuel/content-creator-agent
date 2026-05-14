# Twitter Content Automation Pipeline (Coinomad)

A scheduled tweet publishing system with Google Sheets review buffer.

## Architecture

Two layers powered by cron jobs:

### Layer 1 — Daily Batch Generation (6:00 AM WAT)
Generates all tweets for the day using an AI content prompt, writes them to a
Google Sheet as "draft" status. User opens the sheet, reviews, edits, and flips
to "approved".

### Layer 2 — Scheduled Posting (8am, 12:30pm, 5pm, 8pm WAT)
Per-slot cron jobs check the sheet. If status = "approved", post via xurl and
mark as "posted". If "draft", skip — nothing posts without approval.

## Google Sheet Columns

| Date | Time | Pillar | Format | Content | Status | Posted At | Tweet URL |

Status values: draft → approved → posted

## Content Schedule (WAT)

| Time | Pillar | Format |
|------|--------|--------|
| 8:00 AM | Macro insight | Single tweet |
| 12:30 PM | OTC Desk / RWA / Consultant | Single tweet |
| 5:00 PM | Founder story / Hot take | Single tweet |
| 8:00 PM | Thought leadership | Single tweet or max 3-tweet thread |

## Content Pillars

1. **Stablecoin Utility & Africa Macro** — Africa's FX crisis, dollar scarcity,
   USDT/USDC adoption, remittance cost destruction, CBN restrictions,
   stablecoin as merchant rails
2. **Coinomad OTC Desk (soft promo)** — Naira ↔ USDC/USDT flows, liquidity,
   rate dynamics, importer/merchant/treasury use cases
3. **Founder Journey & Building in Public** — Solo-building a fintech,
   fundraising in Africa, hard product decisions, African market lessons
4. **RWA & Institutional Adoption** — Tokenised US treasuries, real estate
   tokenisation, private credit on-chain, institutional settlement, Africa as
   RWA yield market
5. **Stablecoins & RWA Infrastructure Consultant** — Architecture decisions,
   tokenisation stack trade-offs, wallet infra, compliance, smart contract
   patterns
6. **Thought Leadership** — Where money infrastructure is heading, Africa's
   financial leapfrog, stablecoins as correspondent banking layer, death of
   high-fee remittance

## Tone Rules

- Direct, no fluff. Africa-first lens. Insight-led, not aspirational.
- Technical depth welcome. Contrarian when earned. Zero startup clichés.
- First-person POV, not company PR. Short sentences. Teach, don't sell.
- Coinomad/OTC mentions should be contextual, not promotional headlines.
- No decorative emojis. No hashtags in body (one optional at end).
- No trading advice.

## Prerequisites

1. Google Workspace OAuth (Sheets access) — via google-workspace skill
2. X API OAuth (posting rights) — via xurl skill:
   - **Free tier:** `xurl auth oauth1` with Consumer Key/Secret + Access Token/Secret
   - **Basic+ tier:** `xurl auth oauth2 --app my-app` (OAuth 2.0 PKCE)
3. Cron jobs configured at the 4 posting times (use the Hermes cron tool)
4. AI content prompt saved for generation (see the full prompt below)
5. A Google Sheet created with the exact columns listed above

## Setup Steps

1. Set up Google Sheets OAuth (setup.py from google-workspace skill)
2. Set up xurl auth:
   - **Free tier:** `xurl auth oauth1` with Consumer Key/Secret + Access Token/Secret
   - **Basic+ tier:** `xurl auth apps add my-app --client-id ... --client-secret ...` then `xurl auth oauth2 --app my-app`
3. Create the Google Sheet with the columns above
4. Save the content prompt (see `templates/twitter-content-prompt.md` in the xurl skill directory for the full approved prompt)
5. Set up cron jobs via Hermes agent

## Full Content Prompt

Below is the approved prompt used for tweet generation. Modify as needed.
