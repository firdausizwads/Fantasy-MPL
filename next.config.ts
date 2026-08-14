import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // Allows Arena's secure live-preview proxy during development.
  // This setting does not grant access to private application data.
  allowedDevOrigins: ['3000-i8inmsdfikywtendx0ne8.e2b.app']
};

export default nextConfig;
