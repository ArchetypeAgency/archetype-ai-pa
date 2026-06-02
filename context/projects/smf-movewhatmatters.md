# SMF — Move What Matters

**Status:** Active — phased implementation
**Local path:** ./smf-movewhatmatters
**Stack:** Next.js, Aurora MySQL, AWS S3 (CV uploads), AWS SES (email), Google Analytics

## Background
Interactive microsite for Singapore Maritime Foundation (SMF). A game/campaign with company sign-up forms. Deployed in Singapore region (ap-southeast-1). Integrates with MCO (MaritimeONE) Portal.

## Phases
Controlled by NEXT_PUBLIC_PHASE env var on deployment:
- 0 = Career Real Talk active (sign-up form)
- 1 = Pre-VIP buffer (coming soon, scrolls to Maritime Reels)
- 2 = VIP Pass active (sign-up form, VIP variant)
- 3 = Career Real Talk 2 buffer (coming soon)
- 4 = Campaign end (sign-ups closed)

4th draggable item (AET Tankers) gated behind NEXT_PUBLIC_ENABLE_OBJ4 — not yet enabled.

## Environments
- **Prod:** Phase 0 (Career Real Talk sign-up active)
- **Staging (Render.com):** Phase 1 (Pre-VIP buffer)

## Outstanding
- [ ] Next phase transition date/trigger for prod → phase 1?
- [ ] MCO_ENDPOINT and MCO_TOKEN — configured in prod?
- [ ] AET Tankers video ready yet?

## Notes
