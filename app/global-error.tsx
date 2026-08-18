'use client';

export default function GlobalError({ reset }: { error: Error & { digest?: string }; reset: () => void }) {
  return (
    <html lang="en">
      <body>
        <main style={{ minHeight: '100vh', display: 'grid', placeContent: 'center', textAlign: 'center', padding: 24, background: '#07121f', color: '#fff', fontFamily: 'system-ui' }}>
          <img src="/brand/fantasy-mpl-emblem-display.webp" alt="Fantasy MPL" style={{ width: 86, height: 86, objectFit: 'contain', margin: '0 auto 18px' }} />
          <p style={{ color: '#6fd3c8', fontSize: 12, fontWeight: 800 }}>FANTASY MPL</p>
          <h1 style={{ fontSize: 30, margin: '4px 0 8px' }}>THE APPLICATION COULDN’T START.</h1>
          <p style={{ color: '#9eacba', maxWidth: 520 }}>Retry the application. If the problem continues, return later while the deployment is checked.</p>
          <button onClick={reset} style={{ margin: '20px auto 0', width: 180, padding: 12, border: 0, borderRadius: 8, background: '#69cec3', color: '#07121f', fontWeight: 900, cursor: 'pointer' }}>RETRY APPLICATION</button>
        </main>
      </body>
    </html>
  );
}
