const base=(process.env.BASE_URL||'https://fantasy-mpl-phi.vercel.app').replace(/\/$/,'');
const routes=['/','/my','/id','/ph','/live-draft','/privacy','/terms','/rules','/community-guidelines','/robots.txt','/sitemap.xml','/manifest.webmanifest','/api/region-status?region=MY','/api/region-status?region=ID','/api/region-status?region=PH','/api/draft-model?region=MY','/api/draft-model?region=ID','/api/draft-model?region=PH','/api/health'];
let failed=false;
for(const route of routes){
 const started=Date.now();
 try{
  const response=await fetch(base+route,{headers:{'user-agent':'FantasyMPL-Production-Smoke/1.0'}});
  const duration=Date.now()-started;
  if(!response.ok){console.error(`FAIL ${response.status} ${route} ${duration}ms`);failed=true;continue}
  if(route==='/'){const csp=response.headers.get('content-security-policy')||'';if(!csp.includes("default-src 'self'")){console.error('FAIL missing CSP');failed=true}}
  if(route==='/api/health'){const health=await response.json();if(health.status!=='ok'){console.error(`FAIL health=${health.status}`);failed=true}}
  console.log(`PASS ${response.status} ${route} ${duration}ms`);
 }catch(error){console.error(`FAIL ${route} ${error instanceof Error?error.message:error}`);failed=true}
}
if(failed)process.exit(1);
console.log(`Production smoke passed: ${routes.length} checks.`);
