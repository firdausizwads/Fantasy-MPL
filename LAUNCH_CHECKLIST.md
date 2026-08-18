# Fantasy MPL launch checklist

Items marked **Owner action** require access to your Vercel, Supabase, domain or legal accounts and cannot be completed from source code alone.

## Required before merging this update

- [ ] **Owner action — Vercel:** Add `SUPABASE_SERVICE_ROLE_KEY` as a server-only secret.
- [ ] **Owner action — Vercel:** Add `NEXT_PUBLIC_PRIVACY_EMAIL` with the exact public support/privacy address. A placeholder was intentionally not invented.
- [ ] **Owner action — Vercel:** Confirm the existing Supabase, PandaScore and cron variables match `.env.example`.
- [ ] Deploy the updated application before applying migration 030 so registration sends the required acceptance metadata.
- [ ] **Owner action — Supabase:** Run migrations 029 and 030 in order after the application deployment.
- [ ] Create a test account, confirm the age/guardian checkbox is required and confirm email verification works.
- [ ] Sign in with an older test account and confirm the updated-terms acceptance screen appears once.
- [ ] Sign in as an administrator and run PandaScore Sync once.

## Supabase production settings

- [ ] Require email confirmation for new accounts.
- [ ] Configure a production SMTP provider and branded confirmation/recovery emails.
- [ ] Add the production and preview URLs under Authentication URL Configuration.
- [ ] Enable CAPTCHA or equivalent bot protection on signup if public registration is open.
- [ ] Review Auth rate limits and password-security settings.
- [ ] Verify the Security Advisor and Performance Advisor after migrations.
- [ ] Verify backups and recovery options appropriate to the launch risk.
- [ ] Keep the service-role/secret key only in Vercel server environment variables.

## Legal and community

- [ ] Obtain permission or an appropriate licence for MPL, team, player and competition assets before commercial use.
- [ ] Have the 13+ guardian language and privacy/retention wording reviewed for the territories where the service will operate. The source update is technical assistance, not legal advice.
- [ ] Publish a private support path for guardians, deletion requests, safety reports and appeals.
- [ ] Publish separate prize rules—including age, identity, territory, dates and funding—before promising a prize.
- [ ] Train moderators and define evidence retention for reports and appeals.

## Domain and branding

You selected **no custom domain yet**, so the patch keeps the Vercel URL while making metadata domain-ready.

When a domain is purchased:

- [ ] Add it under Vercel Domains.
- [ ] Set `NEXT_PUBLIC_SITE_URL` to the HTTPS custom domain.
- [ ] Add it to Supabase Auth URL Configuration.
- [ ] Redeploy and verify canonical, sitemap and redirect output.

## Final release verification

```bash
npm ci
npm run typecheck
npm run build
npm run test:e2e
npm run test:production
```

- [ ] `/api/health` reports `status: ok`.
- [ ] GitHub Quality checks pass.
- [ ] Vercel Preview is tested on a physical iPhone/Android device.
- [ ] Registration, confirmation, sign-in, sign-out, export and account deletion work.
- [ ] A normal user cannot access administrator operations.
- [ ] `/favicon.ico`, `/robots.txt`, `/sitemap.xml` and `/manifest.webmanifest` return 200.
