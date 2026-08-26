import type { Metadata, Viewport } from 'next';
import localFont from 'next/font/local';
import { Analytics } from '@vercel/analytics/next';
import { SpeedInsights } from '@vercel/speed-insights/next';
import './globals.css';
import './dashboard-real.css';
import './prediction-windows.css';
import './draft-lab.css';
import './draft-tool-redesign.css';
import './draft-mobile-finish.css';
import './draft-side-branding.css';
import './draft-intelligence.css';
import './regional-operations.css';
import './profile-reliability.css';
import './pandascore-sync.css';
import './live-admin.css';
import './regional-fantasy.css';
import './live-meta.css';
import './mobile-polish-playoffs.css';
import './playoff-experience.css';
import './hero-portraits.css';
import './dark-mode.css';
import './dark-mode-hardening.css';
import './admin-console-modern.css';
import './draft-final-fixes.css';
import './guest-entry.css';
import { SITE_URL } from '../lib/site';

const jakarta = localFont({
  src: './fonts/PlusJakartaSans-Variable-Latin.woff2',
  variable: '--font-body',
  display: 'swap',
  weight: '200 800',
  style: 'normal'
});

const sora = localFont({
  src: './fonts/Sora-Variable-Latin.woff2',
  variable: '--font-display',
  display: 'swap',
  weight: '100 800',
  style: 'normal'
});

const vercelObservabilityEnabled = process.env.VERCEL === '1';

export const viewport: Viewport = {
  themeColor: '#050d17',
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
  colorScheme: 'dark'
};

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  applicationName: 'Fantasy MPL',
  alternates: { canonical: '/' },
  title: {
    default: 'Fantasy MPL — Regional Fantasy Esports',
    template: '%s · Fantasy MPL'
  },
  description: 'Build fantasy rosters and predict MPL Malaysia, MPL Indonesia, and MPL Philippines competitions.',
  manifest: '/manifest.webmanifest',
  icons: {
    icon: [{ url: '/icon.png', type: 'image/png' }],
    apple: [{ url: '/apple-icon.png', type: 'image/png' }]
  },
  openGraph: {
    type: 'website',
    url: '/',
    siteName: 'Fantasy MPL',
    title: 'Fantasy MPL — Build Your Roster. Back Your Region.',
    description: 'Regional fantasy rosters, predictions, leagues, Meta Lab, and playoff brackets for MPL fans.',
    images: [{ url: '/brand/og-image.png', width: 1200, height: 630, alt: 'Fantasy MPL regional fantasy esports' }]
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Fantasy MPL — Regional Fantasy Esports',
    description: 'Build fantasy rosters, make predictions, and compete with the MPL community.',
    images: ['/brand/og-image.png']
  },
  robots: { index: true, follow: true }
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className={`${jakarta.variable} ${sora.variable}`}>
        {children}
        {vercelObservabilityEnabled && <Analytics />}
        {vercelObservabilityEnabled && <SpeedInsights />}
      </body>
    </html>
  );
}
