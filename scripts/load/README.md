# Regional read-load test

Run only against a Vercel Preview or dedicated staging deployment. The script intentionally blocks the production URL.

## Windows setup

```powershell
winget install k6.k6
```

Close and reopen PowerShell, then verify:

```powershell
k6 version
```

## Run

```powershell
$env:BASE_URL="https://YOUR-PREVIEW-DEPLOYMENT.vercel.app"
npm run load:regional
```

The default profile ramps from 10 to 50 to 100 virtual users over two minutes. It tests regional pages, regional status and the CDN Draft Model bundle. It performs no authentication and no database writes.

Success thresholds:

- HTTP failure rate below 1%
- p95 response duration below 1.5 seconds

Do not raise traffic levels until Vercel and Supabase monitoring show stable latency and error rates. Never target production without explicit operational approval.
