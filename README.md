# Fantasy MPL

A mobile-first fantasy and prediction platform concept for separate MPL Malaysia, MPL Indonesia, and MPL Philippines competitions.

## Current public-preview scope

- Local manager profile
- Separate regional onboarding and switching
- Match and exact-score predictions
- Weekly MVP picks
- Prediction submission and points history
- Private league creation and invite codes
- Demonstration snake draft
- Fantasy roster and transfer market
- Regional leaderboards
- Demonstration admin console
- Browser persistence through `localStorage`

## Important

This frontend release uses sample data and browser-local storage. It is suitable for product testing, not a real public competition. A later Supabase integration will provide secure accounts, multi-user leagues, permanent records, server-side deadlines, and authoritative scoring.

League logos and related marks belong to their respective owners. Obtain the necessary permission and follow official brand guidelines before commercial launch. This project must not imply official affiliation without authorization.

## Local development

```bash
npm install
npm run dev
```

Open `http://localhost:3000`.

## Production build

```bash
npm install
npm run build
npm start
```

## Deployment

See [`DEPLOYMENT.md`](DEPLOYMENT.md).
