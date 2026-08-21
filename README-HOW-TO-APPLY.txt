Fantasy MPL mobile cinematic fix

This package contains 2 fixed files:

app/guest-entry.tsx
app/guest-entry.css

How to apply using GitHub Desktop:

1. Download and unzip this package.
2. Open your Fantasy-MPL project folder on your computer.
3. Open the app folder.
4. Replace these two files with the fixed versions from this package:
   - guest-entry.tsx
   - guest-entry.css
5. Open GitHub Desktop.
6. You should see 2 changed files.
7. Commit with this message:
   Fix mobile guest cinematic visuals
8. Push origin.
9. Wait for Vercel to redeploy.

What was fixed:

- Removed the yellow glow leak at the bottom of mobile screens.
- Preloaded the MLBB logo and regional cinematic assets.
- Removed the slight final MLBB logo animation delay after the MPL Philippines slide.
- Added smoother rendering hints for the final MLBB logo animation.

After Vercel finishes deploying, test on your phone in an incognito/private tab.
