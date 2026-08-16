import type { MetadataRoute } from 'next';

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'Fantasy MPL',
    short_name: 'Fantasy MPL',
    description: 'Regional fantasy esports and prediction leagues for MPL fans.',
    start_url: '/',
    display: 'standalone',
    background_color: '#07121f',
    theme_color: '#07121f',
    orientation: 'portrait-primary',
    icons: [
      { src: '/icon.png', sizes: '64x64', type: 'image/png' },
      { src: '/apple-icon.png', sizes: '180x180', type: 'image/png' },
      { src: '/brand/fantasy-mpl-emblem.png', sizes: '1024x1024', type: 'image/png' }
    ]
  };
}
