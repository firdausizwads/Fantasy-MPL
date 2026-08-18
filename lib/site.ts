const configuredSiteUrl = process.env.NEXT_PUBLIC_SITE_URL?.trim();
const vercelProductionUrl = process.env.VERCEL_PROJECT_PRODUCTION_URL?.trim();

function normalizeSiteUrl(value: string) {
  const withProtocol = /^https?:\/\//i.test(value) ? value : `https://${value}`;
  return withProtocol.replace(/\/$/, '');
}

export const SITE_URL = normalizeSiteUrl(
  configuredSiteUrl || vercelProductionUrl || 'https://fantasy-mpl-phi.vercel.app'
);
