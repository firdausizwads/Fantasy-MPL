-- Fantasy MPL — Complete Season 18 rosters (ID: BTR + ONIC) and identity fixes
-- Run after 009_cloud_transfers.sql
-- Sources verified 15 Aug 2026:
--   https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18
--   https://www.vcgamers.com/news/roster-bigetron-mpl-s18-dan-jadwal-week-1/
--   https://www.vcgamers.com/news/en/onics-official-roster-in-mpl-id-season-18/

-- 1. Missing MPL ID players: Bigetron by Vitality ------------------------------

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Shogun', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Nnael', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Moreno', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('EMANN', 'PH', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Finn', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Miguel', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

-- 2. Missing MPL ID players: ONIC ------------------------------------------------

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Lutpiii', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Kairi', 'PH', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('S A N Z', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Kelra', 'PH', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Kiboy', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('SamueL', 'ID', null, true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  country_code=coalesce(public.players.country_code, excluded.country_code),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

-- 3. Season roster entries for BTR and ONIC (MPL ID Season 18) -------------------

do $$
declare
  entry record;
begin
  for entry in
    select * from (values
      ('Shogun',  'BTR',    'EXP'),
      ('Nnael',   'BTR',    'JUNGLE'),
      ('Moreno',  'BTR',    'MID'),
      ('EMANN',   'BTR',    'GOLD'),
      ('Finn',    'BTR',    'ROAM'),
      ('Miguel',  'BTR',    'FLEX'),
      ('Lutpiii', 'ONICID', 'EXP'),
      ('Kairi',   'ONICID', 'JUNGLE'),
      ('S A N Z', 'ONICID', 'MID'),
      ('Kelra',   'ONICID', 'GOLD'),
      ('Kiboy',   'ONICID', 'ROAM'),
      ('SamueL',  'ONICID', 'FLEX')
    ) as v(handle, team_code, role)
  loop
    insert into public.season_rosters
      (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
    select
      s.id, p.id, t.id, entry.role, '2026-08-14T00:00:00Z'::timestamptz,
      true, 'https://liquipedia.net/mobilelegends/MPL/Indonesia/Season_18', now()
    from public.seasons s
    join public.players p on p.handle = entry.handle
    join public.teams t on t.region_code = 'ID' and t.code = entry.team_code
    where s.region_code = 'ID' and s.season_number = 18
    on conflict (season_id, player_id, starts_at) do update set
      team_id = excluded.team_id, role = excluded.role, active = true,
      source_url = excluded.source_url, verified_at = excluded.verified_at;
  end loop;
end $$;

-- 4. Country codes: fill the gaps so leaderboard flags are correct ----------------
-- PH players in MPL ID (per Liquipedia country representation, 15 Aug 2026).

update public.players set country_code = 'PH'
where handle in ('Andoryuuu','Demonkite','EMANN','Kairi','Kayn','Kelra','QINN')
  and (country_code is null or country_code <> 'PH');

-- All MPL PH Season 18 roster players default to PH when unset.
update public.players p set country_code = 'PH'
from public.season_rosters sr
join public.seasons s on s.id = sr.season_id
where sr.player_id = p.id
  and s.region_code = 'PH' and s.season_number = 18
  and p.country_code is null;

-- MPL MY roster players default to MY when unset.
update public.players p set country_code = 'MY'
from public.season_rosters sr
join public.seasons s on s.id = sr.season_id
where sr.player_id = p.id
  and s.region_code = 'MY' and s.season_number = 18
  and p.country_code is null;

-- MPL ID roster players default to ID when unset.
update public.players p set country_code = 'ID'
from public.season_rosters sr
join public.seasons s on s.id = sr.season_id
where sr.player_id = p.id
  and s.region_code = 'ID' and s.season_number = 18
  and p.country_code is null;

-- 5. Photo fix: Sizkaa's portrait exists but was never linked ---------------------

update public.players set photo_url = '/players/my/vms/sizkaa.webp'
where handle = 'Sizkaa' and photo_url is null;
