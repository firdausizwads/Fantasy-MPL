import http from 'k6/http';
import { check, sleep } from 'k6';

const base=(__ENV.BASE_URL||'').replace(/\/$/,'');
if(!base)throw new Error('BASE_URL is required. Use a Vercel Preview deployment URL.');
if(base.includes('fantasy-mpl-phi.vercel.app')&&__ENV.ALLOW_PRODUCTION_LOAD_TEST!=='I_UNDERSTAND')throw new Error('Production load testing is blocked. Use a Preview URL.');

export const options={stages:[{duration:'20s',target:10},{duration:'40s',target:50},{duration:'40s',target:100},{duration:'20s',target:0}],thresholds:{http_req_failed:['rate<0.01'],http_req_duration:['p(95)<1500']}};
const regions=['MY','ID','PH'];
const paths=['/my','/id','/ph','/live-draft'];
export default function(){
 const region=regions[Math.floor(Math.random()*regions.length)];
 const path=paths[Math.floor(Math.random()*paths.length)];
 const responses=http.batch([
  ['GET',`${base}${path}`,null,{tags:{kind:'page'}}],
  ['GET',`${base}/api/region-status?region=${region}`,null,{tags:{kind:'status'}}],
  ['GET',`${base}/api/draft-model?region=${region}`,null,{tags:{kind:'model'}}]
 ]);
 responses.forEach(response=>check(response,{'status is 200':item=>item.status===200}));
 sleep(1+Math.random()*2);
}
