import Link from 'next/link';

export default function NotFound() {
  return (
    <main className="recoveryPage">
      <img src="/brand/fantasy-mpl-emblem-display.webp" alt="Fantasy MPL" />
      <span>404 · MAP NOT FOUND</span>
      <h1>THIS ROUTE IS OUT OF BOUNDS.</h1>
      <p>The page may have moved, or the link may be incorrect.</p>
      <div><Link href="/">RETURN TO FANTASY MPL</Link></div>
    </main>
  );
}
