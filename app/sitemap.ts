import type { MetadataRoute } from 'next';
import { SITE_URL } from '../lib/site';

export default function sitemap(): MetadataRoute.Sitemap {
  const base = SITE_URL;
  return [
    { url: base, changeFrequency: 'daily', priority: 1 },
    { url: `${base}/my`, changeFrequency: 'daily', priority: 0.8 },
    { url: `${base}/id`, changeFrequency: 'daily', priority: 0.8 },
    { url: `${base}/ph`, changeFrequency: 'daily', priority: 0.8 },
    { url: `${base}/live-draft`, changeFrequency: 'daily', priority: 0.9 },
    { url: `${base}/privacy`, changeFrequency: 'monthly', priority: 0.3 },
    { url: `${base}/terms`, changeFrequency: 'monthly', priority: 0.3 },
    { url: `${base}/rules`, changeFrequency: 'weekly', priority: 0.6 },
    { url: `${base}/community-guidelines`, changeFrequency: 'monthly', priority: 0.4 }
  ];
}
