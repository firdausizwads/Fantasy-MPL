'use client';

import { useEffect } from 'react';

export default function ErrorPage({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => {
    // Keep private user data out of logs; only report the error object and digest.
    console.error('Fantasy MPL route error', error);
  }, [error]);

  return (
    <main className="recoveryPage">
      <img src="/brand/fantasy-mpl-emblem.png" alt="Fantasy MPL" />
      <span>CONNECTION INTERRUPTED</span>
      <h1>THIS FEATURE COULDN’T LOAD.</h1>
      <p>Your account data is safe. Retry the feature, or return to the dashboard if the problem continues.</p>
      {error.digest && <small>ERROR REFERENCE · {error.digest}</small>}
      <div>
        <button onClick={reset}>RETRY FEATURE</button>
        <a href="/">RETURN HOME</a>
      </div>
    </main>
  );
}
