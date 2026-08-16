import type { Metadata } from 'next';
import localFont from 'next/font/local';
import { Analytics } from '@vercel/analytics/next';
import { SpeedInsights } from '@vercel/speed-insights/next';
import './globals.css';
import './dashboard-real.css';
import './prediction-windows.css';
import './draft-lab.css';
import './draft-intelligence.css';
import './ordered-draft-import.css';

const jakarta = localFont({
  src: './fonts/PlusJakartaSans-Variable.ttf',
  variable: '--font-body',
  display: 'swap',
  weight: '200 800',
  style: 'normal'
});

const sora = localFont({
  src: './fonts/Sora-Variable.ttf',
  variable: '--font-display',
  display: 'swap',
  weight: '100 800',
  style: 'normal'
});

export const metadata: Metadata = {
  metadataBase: new URL('https://fantasy-mpl-phi.vercel.app'),
  applicationName: 'Fantasy MPL',
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
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
