import fs from 'node:fs';
import path from 'node:path';

const root=process.cwd();
const heroes=JSON.parse(fs.readFileSync(path.join(root,'app/hero-assets.json'),'utf8'));
const players=JSON.parse(fs.readFileSync(path.join(root,'app/official-players.json'),'utf8'));
const sources=JSON.parse(fs.readFileSync(path.join(root,'app/player-photo-sources.json'),'utf8'));
const brandSources=JSON.parse(fs.readFileSync(path.join(root,'app/brand-asset-sources.json'),'utf8'));
let failed=false;
function verifyPublicFile(publicPath,label){
 if(!publicPath?.startsWith('/')){console.error(`FAIL ${label}: invalid public path`);failed=true;return}
 const file=path.join(root,'public',publicPath.slice(1));
 if(!fs.existsSync(file)||fs.statSync(file).size<500){console.error(`FAIL ${label}: missing or empty ${publicPath}`);failed=true}
}
if(heroes.length!==133){console.error(`FAIL hero catalog expected 133, received ${heroes.length}`);failed=true}
const heroNames=new Set();
for(const hero of heroes){
 if(heroNames.has(hero.name)){console.error(`FAIL duplicate hero ${hero.name}`);failed=true}
 heroNames.add(hero.name);verifyPublicFile(hero.photo,`hero ${hero.name}`);
 if(!/^https:\/\//.test(hero.source||'')){console.error(`FAIL hero ${hero.name}: source missing`);failed=true}
}
for(const player of players){if(player.photo)verifyPublicFile(player.photo,`player ${player.region}/${player.team}/${player.name}`)}
for(const asset of brandSources.assets||[]){verifyPublicFile(asset.publicPath,`brand ${asset.name}`);if(!/^https:\/\//.test(asset.sourcePage||'')||!asset.author){console.error(`FAIL brand ${asset.name}: provenance missing`);failed=true}}
const unresolved=players.filter(player=>!player.photo).map(player=>`${player.region}/${player.team}/${player.name}`);
const declared=new Set((sources.unresolved||[]).map(player=>`${player.region}/${player.team}/${player.name}`));
for(const player of unresolved){if(!declared.has(player)){console.error(`FAIL unresolved player not documented: ${player}`);failed=true}}
const ph=players.filter(player=>player.region==='PH');
const id=players.filter(player=>player.region==='ID');
console.log(`Hero portraits: ${heroes.length}/${heroes.length}`);
console.log(`Brand assets with provenance: ${(brandSources.assets||[]).length}`);
console.log(`MPL PH player portraits: ${ph.filter(player=>player.photo).length}/${ph.length}`);
console.log(`MPL ID player portraits: ${id.filter(player=>player.photo).length}/${id.length}`);
console.log(`Unresolved player portraits: ${unresolved.join(', ')||'none'}`);
if(failed)process.exit(1);
