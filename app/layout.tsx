import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Fantasy MPL — Own the Meta',
  description: 'Regional fantasy and prediction competitions for MPL MY, ID and PH.'
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
