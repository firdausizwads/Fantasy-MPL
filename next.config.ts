import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // Arena development previews use rotating secure subdomains.
  // Production Vercel deployments are unaffected by this development-only allowlist.
  allowedDevOrigins: ['*.e2b.app']
};

export default nextConfig;
