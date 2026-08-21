# OpenMLBB / RoneAI integration record

This file records the integration conditions supplied directly to the Fantasy MPL owner by RoneAI in August 2026. Keep the original email in the project owner's records.

## Permitted current use

- Production use for Fantasy MPL
- Non-commercial use only
- Server-side caching in Supabase
- Derived recommendation models
- Public display of derived recommendations
- Cached snapshot retention while API access remains active

## Available capabilities

- Pick, ban and win-rate data
- Counter and synergy data
- Mythic, Honor and Glory rank filters
- Documented patch identifiers and time windows
- Token-authenticated requests

## Operational limits

- Approximately 50 requests per day per user unless a separate limit is negotiated
- OpenMLBB has been under-maintained since mid-June 2026
- Public relaunch is currently expected around mid-November 2026
- Cached snapshots must be deleted if API access ends
- Sponsorship, advertising, subscriptions and other revenue-generating use require future commercial permission

## Required attribution

Display this wording anywhere RoneAI-derived data or recommendations are shown:

> Powered by MLBB Public Data API • Data © Moonton (Mobile Legends) • API maintained by ridwaanhall / RoneAI.

## Security requirements

- Store the token only as `RONEAI_API_TOKEN` in Vercel server environment variables.
- Never add a `NEXT_PUBLIC_` prefix to the token.
- Never call RoneAI directly from browser code.
- Fetch through a server job, validate the response and cache a bounded snapshot in Supabase.
- Serve public recommendations from the validated snapshot rather than consuming the daily API limit per visitor.

## Recommended snapshot workflow

1. One administrator or scheduled server job calls RoneAI.
2. The job records endpoint, patch, rank, time window, retrieval time and response hash.
3. Raw responses are validated before any model is activated.
4. Normalized hero metrics and relationships are stored in the existing Draft Intelligence tables.
5. A model activates only after source approval, a minimum sample and an integrity review.
6. Public traffic reads cached `/api/draft-model` responses; it never calls RoneAI directly.
7. If access ends, disable the model and delete RoneAI-derived cached snapshots as required by the agreement.

## Before technical onboarding

Request the full documentation from RoneAI, including:

- exact production base URL;
- header name and token format;
- endpoint schemas;
- pagination rules;
- supported patch/time-window values;
- rank-filter syntax;
- rate-limit headers and reset behavior;
- error and maintenance responses;
- snapshot deletion expectations if access ends.
