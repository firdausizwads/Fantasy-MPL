-- Migration 037: Full Season 18 Roster Synchronization (MY, ID, PH)
-- Updates verified handles, mid-season transfers, active rosters, and newly registered substitutes.

do $$
declare
  v_season_id uuid;
  v_team_id uuid;
  v_player_id uuid;
begin

  -- ==================== REGION: MY ====================
  select id into v_season_id from public.seasons where region_code = 'MY' and season_number = 18;
  if v_season_id is not null then
    -- Momo (AC - EXP Lane)
    select id into v_team_id from public.teams where code = 'AC' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Momo', 'MY', '/players/my/ac/momo.webp', 'https://liquipedia.net/mobilelegends/Momo', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ac/momo.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Momo', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Momo';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Zahyed (AC - Jungle)
    select id into v_team_id from public.teams where code = 'AC' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Zahyed', 'MY', '/players/my/ac/zahyed.webp', 'https://liquipedia.net/mobilelegends/Zahyed', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ac/zahyed.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Zahyed', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Zahyed';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Izanami (AC - Midlane)
    select id into v_team_id from public.teams where code = 'AC' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Izanami', 'MY', '/players/my/ac/izanami.webp', 'https://liquipedia.net/mobilelegends/Izanami', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ac/izanami.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Izanami', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Izanami';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Nets (AC - Gold Lane)
    select id into v_team_id from public.teams where code = 'AC' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Nets', 'MY', '/players/my/ac/nets.webp', 'https://liquipedia.net/mobilelegends/Nets', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ac/nets.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Nets', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Nets';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Reyzar (AC - Roam)
    select id into v_team_id from public.teams where code = 'AC' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Reyzar', 'MY', '/players/my/ac/reyzar.webp', 'https://liquipedia.net/mobilelegends/Reyzar', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ac/reyzar.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Reyzar', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Reyzar';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Martzy (AC - Midlane)
    select id into v_team_id from public.teams where code = 'AC' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Martzy', 'MY', '/players/my/ac/martzyy.webp', 'https://liquipedia.net/mobilelegends/Martzy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ac/martzyy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Martzy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Martzy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Jeymz (BTRM - EXP Lane)
    select id into v_team_id from public.teams where code = 'BTRM' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Jeymz', 'MY', '/players/my/btrm/jeymz.webp', 'https://liquipedia.net/mobilelegends/Jeymz', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/btrm/jeymz.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Jeymz', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Jeymz';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Chibi (BTRM - Jungle)
    select id into v_team_id from public.teams where code = 'BTRM' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Chibi', 'MY', '/players/my/btrm/chibii.webp', 'https://liquipedia.net/mobilelegends/Chibi', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/btrm/chibii.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Chibi', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Chibi';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Zieyy (BTRM - Midlane)
    select id into v_team_id from public.teams where code = 'BTRM' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Zieyy', 'MY', '/players/my/btrm/zieyy.webp', 'https://liquipedia.net/mobilelegends/Zieyy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/btrm/zieyy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Zieyy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Zieyy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Ciku (BTRM - Gold Lane)
    select id into v_team_id from public.teams where code = 'BTRM' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Ciku', 'MY', '/players/my/btrm/cikugais.webp', 'https://liquipedia.net/mobilelegends/Ciku', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/btrm/cikugais.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Ciku', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Ciku';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- GRBoy (BTRM - Roam)
    select id into v_team_id from public.teams where code = 'BTRM' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('GRBoy', 'MY', '/players/my/btrm/grboy.webp', 'https://liquipedia.net/mobilelegends/GR', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/btrm/grboy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/GR', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'GRBoy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Amzziq (BTRM - Gold Lane)
    select id into v_team_id from public.teams where code = 'BTRM' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Amzziq', 'MY', '/players/my/btrm/amzziq.webp', 'https://liquipedia.net/mobilelegends/Amzziq', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/btrm/amzziq.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Amzziq', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Amzziq';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Ye3 (IG - EXP Lane)
    select id into v_team_id from public.teams where code = 'IG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Ye3', 'MY', '/players/my/ig/ye3.webp', 'https://liquipedia.net/mobilelegends/Ye3', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ig/ye3.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Ye3', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Ye3';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Lunnn (IG - Jungle)
    select id into v_team_id from public.teams where code = 'IG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Lunnn', 'MY', '/players/my/ig/lunnn.webp', 'https://liquipedia.net/mobilelegends/Lunnn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ig/lunnn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Lunnn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Lunnn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Treacky (IG - Midlane)
    select id into v_team_id from public.teams where code = 'IG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Treacky', 'MY', '/players/my/ig/treacky.webp', 'https://liquipedia.net/mobilelegends/Treacky', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ig/treacky.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Treacky', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Treacky';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Rokji (IG - Gold Lane)
    select id into v_team_id from public.teams where code = 'IG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Rokji', 'MY', '/players/my/ig/rokji.webp', 'https://liquipedia.net/mobilelegends/Rough', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ig/rokji.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Rough', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Rokji';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Atannn (IG - Roam)
    select id into v_team_id from public.teams where code = 'IG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Atannn', 'MY', '/players/my/ig/atannn.webp', 'https://liquipedia.net/mobilelegends/Atannn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ig/atannn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Atannn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Atannn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Rezza (IG - EXP Lane)
    select id into v_team_id from public.teams where code = 'IG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Rezza', 'MY', '/players/my/ig/rezza.webp', 'https://liquipedia.net/mobilelegends/Rezza', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/ig/rezza.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Rezza', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Rezza';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- LEHTzy (RRQMY - EXP Lane)
    select id into v_team_id from public.teams where code = 'RRQMY' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('LEHTzy', 'MY', '/players/my/rrqmy/lehtzy.webp', 'https://liquipedia.net/mobilelegends/LEHTzy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/rrqmy/lehtzy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/LEHTzy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'LEHTzy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Super Kenn (RRQMY - Jungle)
    select id into v_team_id from public.teams where code = 'RRQMY' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Super Kenn', 'MY', '/players/my/rrqmy/superkenn.webp', 'https://liquipedia.net/mobilelegends/Super Kenn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/rrqmy/superkenn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Super Kenn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Super Kenn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Yehezkiel (RRQMY - Midlane)
    select id into v_team_id from public.teams where code = 'RRQMY' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Yehezkiel', 'MY', '/players/my/rrqmy/yehezkiel.webp', 'https://liquipedia.net/mobilelegends/Yehezkiel', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/rrqmy/yehezkiel.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Yehezkiel', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Yehezkiel';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Loleal (RRQMY - Gold Lane)
    select id into v_team_id from public.teams where code = 'RRQMY' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Loleal', 'MY', '/players/my/rrqmy/loleal.webp', 'https://liquipedia.net/mobilelegends/Loleal', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/rrqmy/loleal.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Loleal', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Loleal';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Addboy (RRQMY - Roam)
    select id into v_team_id from public.teams where code = 'RRQMY' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Addboy', 'MY', '/players/my/rrqmy/addboyy.webp', 'https://liquipedia.net/mobilelegends/Addboy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/rrqmy/addboyy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Addboy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Addboy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Aj (RRQMY - Midlane)
    select id into v_team_id from public.teams where code = 'RRQMY' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Aj', 'MY', '/players/my/rrqmy/aj.webp', 'https://liquipedia.net/mobilelegends/Aj', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/rrqmy/aj.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Aj', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Aj';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Izzshiki (RRQMY - Gold Lane)
    select id into v_team_id from public.teams where code = 'RRQMY' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Izzshiki', 'MY', '/players/my/rrqmy/izzshiki.webp', 'https://liquipedia.net/mobilelegends/Izzshiki', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/rrqmy/izzshiki.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Izzshiki', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Izzshiki';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- JinZhao (RRQMY - Roam)
    select id into v_team_id from public.teams where code = 'RRQMY' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('JinZhao', 'MY', null, 'https://liquipedia.net/mobilelegends/JinZhao', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/JinZhao', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'JinZhao';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kramm (SRG - EXP Lane)
    select id into v_team_id from public.teams where code = 'SRG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kramm', 'MY', '/players/my/srg/kramm.webp', 'https://liquipedia.net/mobilelegends/Kramm', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/srg/kramm.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Kramm', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kramm';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Sekysss (SRG - Jungle)
    select id into v_team_id from public.teams where code = 'SRG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Sekysss', 'MY', '/players/my/srg/sekysss.webp', 'https://liquipedia.net/mobilelegends/Sekys', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/srg/sekysss.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sekys', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Sekysss';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Stormie (SRG - Midlane)
    select id into v_team_id from public.teams where code = 'SRG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Stormie', 'MY', '/players/my/srg/stormie.webp', 'https://liquipedia.net/mobilelegends/Stormie', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/srg/stormie.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Stormie', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Stormie';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Innocent (SRG - Gold Lane)
    select id into v_team_id from public.teams where code = 'SRG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Innocent', 'MY', '/players/my/srg/innocent.webp', 'https://liquipedia.net/mobilelegends/Innocent', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/srg/innocent.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Innocent', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Innocent';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Yums (SRG - Roam)
    select id into v_team_id from public.teams where code = 'SRG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Yums', 'MY', '/players/my/srg/yums.webp', 'https://liquipedia.net/mobilelegends/Yums', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/srg/yums.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Yums', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Yums';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Unii (SRG - Jungle)
    select id into v_team_id from public.teams where code = 'SRG' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Unii', 'MY', '/players/my/srg/unii.webp', 'https://liquipedia.net/mobilelegends/Unii', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/srg/unii.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Unii', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Unii';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- 3Mar (FL - EXP Lane)
    select id into v_team_id from public.teams where code = 'FL' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('3Mar', 'MY', '/players/my/fl/3mar.webp', 'https://liquipedia.net/mobilelegends/3MarTzy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/fl/3mar.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/3MarTzy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = '3Mar';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Garyy (FL - Jungle)
    select id into v_team_id from public.teams where code = 'FL' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Garyy', 'MY', '/players/my/fl/garyy.webp', 'https://liquipedia.net/mobilelegends/Garyy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/fl/garyy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Garyy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Garyy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- UK1R (FL - Midlane)
    select id into v_team_id from public.teams where code = 'FL' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('UK1R', 'MY', '/players/my/fl/uk1r.webp', 'https://liquipedia.net/mobilelegends/UK1R', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/fl/uk1r.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/UK1R', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'UK1R';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Vanix (FL - Gold Lane)
    select id into v_team_id from public.teams where code = 'FL' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Vanix', 'MY', '/players/my/fl/vanix.webp', 'https://liquipedia.net/mobilelegends/Vanix', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/fl/vanix.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Vanix', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Vanix';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Xorn (FL - Roam)
    select id into v_team_id from public.teams where code = 'FL' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Xorn', 'MY', '/players/my/fl/xorn.webp', 'https://liquipedia.net/mobilelegends/Xorn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/fl/xorn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Xorn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Xorn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Osker (FL - Roam)
    select id into v_team_id from public.teams where code = 'FL' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Osker', 'MY', '/players/my/fl/osker.webp', 'https://liquipedia.net/mobilelegends/Osker', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/fl/osker.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Osker', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Osker';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Sepat (TR - EXP Lane)
    select id into v_team_id from public.teams where code = 'TR' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Sepat', 'MY', '/players/my/vms/sepat.webp', 'https://liquipedia.net/mobilelegends/Sepat', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/vms/sepat.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sepat', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Sepat';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Dolynn (TR - Jungle)
    select id into v_team_id from public.teams where code = 'TR' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Dolynn', 'MY', '/players/my/tr/dolynn.webp', 'https://liquipedia.net/mobilelegends/Dolynn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/tr/dolynn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Dolynn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Dolynn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kyym (TR - Midlane)
    select id into v_team_id from public.teams where code = 'TR' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kyym', 'MY', '/players/my/tr/kyym.webp', 'https://liquipedia.net/mobilelegends/Kyym', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/tr/kyym.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Kyym', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kyym';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Cliveee (TR - Gold Lane)
    select id into v_team_id from public.teams where code = 'TR' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Cliveee', 'MY', '/players/my/tr/cliveee.webp', 'https://liquipedia.net/mobilelegends/Pinnn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/tr/cliveee.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Pinnn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Cliveee';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- NovaXcobar (TR - Roam)
    select id into v_team_id from public.teams where code = 'TR' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('NovaXcobar', 'MY', '/players/my/tr/novaxcobar.webp', 'https://liquipedia.net/mobilelegends/NovaXcobar', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/tr/novaxcobar.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/NovaXcobar', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'NovaXcobar';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- JWen (TR - EXP Lane)
    select id into v_team_id from public.teams where code = 'TR' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('JWen', 'MY', '/players/my/tr/jwen.webp', 'https://liquipedia.net/mobilelegends/Teh O Ice', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/tr/jwen.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Teh O Ice', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'JWen';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Smooth (TR - EXP Lane)
    select id into v_team_id from public.teams where code = 'TR' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Smooth', 'MY', '/players/my/tr/smooth.webp', 'https://liquipedia.net/mobilelegends/Smooth', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/tr/smooth.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Smooth', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Smooth';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Sizkaa (VMS - EXP Lane)
    select id into v_team_id from public.teams where code = 'VMS' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Sizkaa', 'MY', '/players/my/vms/sizkaa.webp', 'https://liquipedia.net/mobilelegends/Sizkaa', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/vms/sizkaa.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sizkaa', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Sizkaa';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Error 404 (VMS - Jungle)
    select id into v_team_id from public.teams where code = 'VMS' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Error 404', 'MY', '/players/my/vms/error-404.webp', 'https://liquipedia.net/mobilelegends/Error 404', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/vms/error-404.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Error 404', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Error 404';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Claw Kun (VMS - Midlane)
    select id into v_team_id from public.teams where code = 'VMS' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Claw Kun', 'MY', '/players/my/vms/clawkun.webp', 'https://liquipedia.net/mobilelegends/Claw Kun', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/vms/clawkun.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Claw Kun', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Claw Kun';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Natco (VMS - Gold Lane)
    select id into v_team_id from public.teams where code = 'VMS' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Natco', 'MY', '/players/my/vms/natco.webp', 'https://liquipedia.net/mobilelegends/Natco', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/vms/natco.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Natco', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Natco';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Zqeef (VMS - Roam)
    select id into v_team_id from public.teams where code = 'VMS' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Zqeef', 'MY', '/players/my/vms/zqeef.webp', 'https://liquipedia.net/mobilelegends/Zqeef', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/vms/zqeef.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Zqeef', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Zqeef';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Sepat (VMS - EXP Lane)
    select id into v_team_id from public.teams where code = 'VMS' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Sepat', 'MY', '/players/my/vms/sepat.webp', 'https://liquipedia.net/mobilelegends/Sepat', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/vms/sepat.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sepat', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Sepat';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- EyyMal (VMS - Jungle)
    select id into v_team_id from public.teams where code = 'VMS' and region_code = 'MY';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('EyyMal', 'MY', '/players/my/vms/eyymal.webp', 'https://liquipedia.net/mobilelegends/EyyMal', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/my/vms/eyymal.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/EyyMal', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'EyyMal';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
  end if;

  -- ==================== REGION: ID ====================
  select id into v_season_id from public.seasons where region_code = 'ID' and season_number = 18;
  if v_season_id is not null then
    -- Nino (AE - EXP Lane)
    select id into v_team_id from public.teams where code = 'AE' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Nino', 'ID', '/players/id/ae/nino.webp', 'https://liquipedia.net/mobilelegends/Nino', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/ae/nino.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Nino', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Nino';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Affan (AE - Jungle)
    select id into v_team_id from public.teams where code = 'AE' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Affan', 'ID', '/players/id/ae/affan.webp', 'https://liquipedia.net/mobilelegends/Yazukee', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/ae/affan.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Yazukee', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Affan';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Dalvin (AE - Midlane)
    select id into v_team_id from public.teams where code = 'AE' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Dalvin', 'ID', '/players/id/ae/dalvin.webp', 'https://liquipedia.net/mobilelegends/Hijumee', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/ae/dalvin.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Hijumee', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Dalvin';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Dingarai (AE - Gold Lane)
    select id into v_team_id from public.teams where code = 'AE' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Dingarai', 'ID', '/players/id/ae/dingarai.webp', 'https://liquipedia.net/mobilelegends/Arfy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/ae/dingarai.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Arfy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Dingarai';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Alexander (AE - Roam)
    select id into v_team_id from public.teams where code = 'AE' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Alexander', 'ID', '/players/id/ae/alexander.webp', 'https://liquipedia.net/mobilelegends/alekk', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/ae/alexander.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/alekk', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Alexander';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Reyy (AE - Jungle)
    select id into v_team_id from public.teams where code = 'AE' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Reyy', 'ID', '/players/id/ae/reyy.webp', 'https://liquipedia.net/mobilelegends/Reyy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/ae/reyy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Reyy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Reyy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Halim (AE - Midlane)
    select id into v_team_id from public.teams where code = 'AE' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Halim', 'ID', '/players/id/ae/halim.webp', 'https://liquipedia.net/mobilelegends/Cyruz', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/ae/halim.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Cyruz', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Halim';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Ivann (AE - Roam)
    select id into v_team_id from public.teams where code = 'AE' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Ivann', 'ID', '/players/id/ae/ivann.webp', 'https://liquipedia.net/mobilelegends/Ivann', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/ae/ivann.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Ivann', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Ivann';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Shogun (BTR - EXP Lane)
    select id into v_team_id from public.teams where code = 'BTR' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Shogun', 'ID', '/players/id/btr/shogun.webp', 'https://liquipedia.net/mobilelegends/Shogun', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/btr/shogun.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Shogun', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Shogun';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Nnael (BTR - Jungle)
    select id into v_team_id from public.teams where code = 'BTR' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Nnael', 'ID', '/players/id/btr/nnael.webp', 'https://liquipedia.net/mobilelegends/Nnael', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/btr/nnael.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Nnael', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Nnael';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Moreno (BTR - Midlane)
    select id into v_team_id from public.teams where code = 'BTR' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Moreno', 'ID', '/players/id/btr/moreno.webp', 'https://liquipedia.net/mobilelegends/Moreno', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/btr/moreno.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Moreno', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Moreno';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- EMANN (BTR - Gold Lane)
    select id into v_team_id from public.teams where code = 'BTR' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('EMANN', 'ID', '/players/id/btr/emann.webp', 'https://liquipedia.net/mobilelegends/EMANN', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/btr/emann.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/EMANN', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'EMANN';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Finn (BTR - Roam)
    select id into v_team_id from public.teams where code = 'BTR' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Finn', 'ID', '/players/id/btr/finn.webp', 'https://liquipedia.net/mobilelegends/Finn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/btr/finn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Finn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Finn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Miguel (BTR - Flex)
    select id into v_team_id from public.teams where code = 'BTR' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Miguel', 'ID', null, 'https://liquipedia.net/mobilelegends/Miguel (Indonesian player)', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Miguel (Indonesian player)', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Miguel';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Flex', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Rendyy (EVOS - EXP Lane)
    select id into v_team_id from public.teams where code = 'EVOS' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Rendyy', 'ID', '/players/id/evos/rendyyy.webp', 'https://liquipedia.net/mobilelegends/Rendyy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/evos/rendyyy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Rendyy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Rendyy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Alberttt (EVOS - Jungle)
    select id into v_team_id from public.teams where code = 'EVOS' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Alberttt', 'ID', '/players/id/evos/alberttt.webp', 'https://liquipedia.net/mobilelegends/Alberttt', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/evos/alberttt.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Alberttt', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Alberttt';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Ryzaa (EVOS - Midlane)
    select id into v_team_id from public.teams where code = 'EVOS' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Ryzaa', 'ID', null, 'https://liquipedia.net/mobilelegends/Ryzaa', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Ryzaa', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Ryzaa';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Erlan (EVOS - Gold Lane)
    select id into v_team_id from public.teams where code = 'EVOS' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Erlan', 'ID', '/players/id/evos/erlan.webp', 'https://liquipedia.net/mobilelegends/Erlan', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/evos/erlan.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Erlan', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Erlan';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Muezza (EVOS - Roam)
    select id into v_team_id from public.teams where code = 'EVOS' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Muezza', 'ID', '/players/id/evos/muezza.webp', 'https://liquipedia.net/mobilelegends/Muezza', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/evos/muezza.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Muezza', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Muezza';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Vell (EVOS - EXP Lane)
    select id into v_team_id from public.teams where code = 'EVOS' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Vell', 'ID', '/players/id/evos/vell.webp', 'https://liquipedia.net/mobilelegends/Vell', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/evos/vell.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Vell', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Vell';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- DrianW (EVOS - Midlane)
    select id into v_team_id from public.teams where code = 'EVOS' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('DrianW', 'ID', '/players/id/evos/drianw.webp', 'https://liquipedia.net/mobilelegends/DrianW', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/evos/drianw.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/DrianW', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'DrianW';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- QINN (DEWA - EXP Lane)
    select id into v_team_id from public.teams where code = 'DEWA' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('QINN', 'ID', '/players/id/dewa/qinn.webp', 'https://liquipedia.net/mobilelegends/QINN', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/dewa/qinn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/QINN', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'QINN';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kayn (DEWA - Jungle)
    select id into v_team_id from public.teams where code = 'DEWA' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kayn', 'ID', '/players/id/dewa/kayn.webp', 'https://liquipedia.net/mobilelegends/Kayn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/dewa/kayn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Kayn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kayn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Octa (DEWA - Midlane)
    select id into v_team_id from public.teams where code = 'DEWA' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Octa', 'ID', '/players/id/dewa/octa.webp', 'https://liquipedia.net/mobilelegends/Octa', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/dewa/octa.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Octa', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Octa';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Maybeee (DEWA - Gold Lane)
    select id into v_team_id from public.teams where code = 'DEWA' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Maybeee', 'ID', '/players/id/dewa/maybeee.webp', 'https://liquipedia.net/mobilelegends/Maybeee', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/dewa/maybeee.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Maybeee', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Maybeee';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Itoshi Kesu (DEWA - Roam)
    select id into v_team_id from public.teams where code = 'DEWA' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Itoshi Kesu', 'ID', '/players/id/dewa/itoshi-kesu.webp', 'https://liquipedia.net/mobilelegends/KESUUU', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/dewa/itoshi-kesu.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/KESUUU', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Itoshi Kesu';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Hazle (DEWA - Jungle)
    select id into v_team_id from public.teams where code = 'DEWA' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Hazle', 'ID', null, 'https://liquipedia.net/mobilelegends/Hazle', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Hazle', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Hazle';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- RuL Good (DEWA - Flex)
    select id into v_team_id from public.teams where code = 'DEWA' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('RuL Good', 'ID', '/players/id/dewa/rul-good.webp', 'https://liquipedia.net/mobilelegends/RuL Good', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/dewa/rul-good.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/RuL Good', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'RuL Good';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Flex', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- MarceL (GEEK - EXP Lane)
    select id into v_team_id from public.teams where code = 'GEEK' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('MarceL', 'ID', '/players/id/geek/marcel.webp', 'https://liquipedia.net/mobilelegends/MarceL', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/geek/marcel.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/MarceL', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'MarceL';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Nazara (GEEK - Jungle)
    select id into v_team_id from public.teams where code = 'GEEK' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Nazara', 'ID', '/players/id/geek/nazara.webp', 'https://liquipedia.net/mobilelegends/Nazara', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/geek/nazara.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Nazara', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Nazara';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- A B O Y (GEEK - Midlane)
    select id into v_team_id from public.teams where code = 'GEEK' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('A B O Y', 'ID', '/players/id/geek/aboyy.webp', 'https://liquipedia.net/mobilelegends/A B O Y', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/geek/aboyy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/A B O Y', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'A B O Y';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- KennzyySkie (GEEK - Gold Lane)
    select id into v_team_id from public.teams where code = 'GEEK' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('KennzyySkie', 'ID', '/players/id/geek/kennzyyskie.webp', 'https://liquipedia.net/mobilelegends/KennzyySkie', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/geek/kennzyyskie.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/KennzyySkie', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'KennzyySkie';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Frenzyy (GEEK - Roam)
    select id into v_team_id from public.teams where code = 'GEEK' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Frenzyy', 'ID', null, 'https://liquipedia.net/mobilelegends/Frenzyy', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Frenzyy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Frenzyy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Febriii (GEEK - EXP Lane)
    select id into v_team_id from public.teams where code = 'GEEK' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Febriii', 'ID', '/players/id/geek/febriii.webp', 'https://liquipedia.net/mobilelegends/Febriii', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/geek/febriii.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Febriii', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Febriii';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- AudyTzy (GEEK - Roam)
    select id into v_team_id from public.teams where code = 'GEEK' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('AudyTzy', 'ID', '/players/id/geek/audytzy.webp', 'https://liquipedia.net/mobilelegends/AudyTzy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/geek/audytzy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/AudyTzy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'AudyTzy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Karss (NAVI - EXP Lane)
    select id into v_team_id from public.teams where code = 'NAVI' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Karss', 'ID', '/players/id/navi/karss.webp', 'https://liquipedia.net/mobilelegends/Karss', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/navi/karss.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Karss', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Karss';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Andoryuuu (NAVI - Jungle)
    select id into v_team_id from public.teams where code = 'NAVI' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Andoryuuu', 'ID', '/players/id/navi/andoryuuu.webp', 'https://liquipedia.net/mobilelegends/Andoryuuu', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/navi/andoryuuu.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Andoryuuu', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Andoryuuu';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Jiizee (NAVI - Midlane)
    select id into v_team_id from public.teams where code = 'NAVI' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Jiizee', 'ID', '/players/id/navi/jiizee.webp', 'https://liquipedia.net/mobilelegends/Jizeezeze', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/navi/jiizee.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Jizeezeze', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Jiizee';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Zeonn (NAVI - Gold Lane)
    select id into v_team_id from public.teams where code = 'NAVI' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Zeonn', 'ID', '/players/id/navi/zeonn.webp', 'https://liquipedia.net/mobilelegends/Zeonn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/navi/zeonn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Zeonn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Zeonn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- APHRO (NAVI - Roam)
    select id into v_team_id from public.teams where code = 'NAVI' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('APHRO', 'ID', '/players/id/navi/aprho.webp', 'https://liquipedia.net/mobilelegends/APHRO', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/navi/aprho.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/APHRO', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'APHRO';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Febbb (NAVI - EXP Lane)
    select id into v_team_id from public.teams where code = 'NAVI' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Febbb', 'ID', '/players/id/navi/febbb.webp', 'https://liquipedia.net/mobilelegends/Febbb', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/navi/febbb.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Febbb', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Febbb';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Joshua (NAVI - Jungle)
    select id into v_team_id from public.teams where code = 'NAVI' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Joshua', 'ID', null, 'https://liquipedia.net/mobilelegends/Coolfire', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Coolfire', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Joshua';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Lutpiii (ONICID - EXP Lane)
    select id into v_team_id from public.teams where code = 'ONICID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Lutpiii', 'ID', '/players/id/onicid/lutpiii.webp', 'https://liquipedia.net/mobilelegends/Lutpiii', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/onicid/lutpiii.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Lutpiii', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Lutpiii';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kairi (ONICID - Jungle)
    select id into v_team_id from public.teams where code = 'ONICID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kairi', 'ID', '/players/id/onicid/kairi.webp', 'https://liquipedia.net/mobilelegends/Kairi', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/onicid/kairi.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Kairi', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kairi';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- S A N Z (ONICID - Midlane)
    select id into v_team_id from public.teams where code = 'ONICID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('S A N Z', 'ID', '/players/id/onicid/s-a-n-z.webp', 'https://liquipedia.net/mobilelegends/S A N Z', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/onicid/s-a-n-z.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/S A N Z', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'S A N Z';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kelra (ONICID - Gold Lane)
    select id into v_team_id from public.teams where code = 'ONICID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kelra', 'ID', '/players/id/onicid/kelra.webp', 'https://liquipedia.net/mobilelegends/Kelra', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/onicid/kelra.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Kelra', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kelra';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kiboy (ONICID - Roam)
    select id into v_team_id from public.teams where code = 'ONICID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kiboy', 'ID', '/players/id/onicid/kiboy.webp', 'https://liquipedia.net/mobilelegends/Kiboy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/onicid/kiboy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Kiboy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kiboy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- SamueL (ONICID - Roam)
    select id into v_team_id from public.teams where code = 'ONICID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('SamueL', 'ID', '/players/id/onicid/samuel.webp', 'https://liquipedia.net/mobilelegends/SamueL', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/onicid/samuel.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/SamueL', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'SamueL';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Joshua (RRQID - EXP Lane)
    select id into v_team_id from public.teams where code = 'RRQID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Joshua', 'ID', '/players/id/rrqid/joshua.webp', 'https://liquipedia.net/mobilelegends/Lynchh', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/rrqid/joshua.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Lynchh', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Joshua';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Demonkite (RRQID - Jungle)
    select id into v_team_id from public.teams where code = 'RRQID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Demonkite', 'ID', '/players/id/rrqid/demonkite.webp', 'https://liquipedia.net/mobilelegends/Demonkite', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/rrqid/demonkite.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Demonkite', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Demonkite';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Hajirin (RRQID - Midlane)
    select id into v_team_id from public.teams where code = 'RRQID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Hajirin', 'ID', '/players/id/rrqid/hajirin.webp', 'https://liquipedia.net/mobilelegends/Rinz', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/rrqid/hajirin.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Rinz', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Hajirin';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Arthur (RRQID - Gold Lane)
    select id into v_team_id from public.teams where code = 'RRQID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Arthur', 'ID', '/players/id/rrqid/arthur.webp', 'https://liquipedia.net/mobilelegends/Sutsujin', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/rrqid/arthur.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sutsujin', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Arthur';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Said (RRQID - Roam)
    select id into v_team_id from public.teams where code = 'RRQID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Said', 'ID', '/players/id/rrqid/said.webp', 'https://liquipedia.net/mobilelegends/Idok', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/rrqid/said.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Idok', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Said';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Habil (RRQID - Gold Lane)
    select id into v_team_id from public.teams where code = 'RRQID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Habil', 'ID', '/players/id/rrqid/habil.webp', 'https://liquipedia.net/mobilelegends/KurooKy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/rrqid/habil.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/KurooKy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Habil';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Clayyy (RRQID - Midlane)
    select id into v_team_id from public.teams where code = 'RRQID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Clayyy', 'ID', '/players/id/rrqid/clayyy.webp', 'https://liquipedia.net/mobilelegends/Clayyy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/rrqid/clayyy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Clayyy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Clayyy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Aran (TLID - EXP Lane)
    select id into v_team_id from public.teams where code = 'TLID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Aran', 'ID', '/players/id/tlid/aran.webp', 'https://liquipedia.net/mobilelegends/Aran', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/tlid/aran.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Aran', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Aran';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kevin (TLID - Jungle)
    select id into v_team_id from public.teams where code = 'TLID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kevin', 'ID', '/players/id/tlid/kevin.webp', 'https://liquipedia.net/mobilelegends/JOOOOO', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/tlid/kevin.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/JOOOOO', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kevin';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Drichel (TLID - Midlane)
    select id into v_team_id from public.teams where code = 'TLID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Drichel', 'ID', '/players/id/tlid/drichel.webp', 'https://liquipedia.net/mobilelegends/Drichel', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/tlid/drichel.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Drichel', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Drichel';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Keven (TLID - Gold Lane)
    select id into v_team_id from public.teams where code = 'TLID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Keven', 'ID', '/players/id/tlid/keven.webp', 'https://liquipedia.net/mobilelegends/Jull', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/tlid/keven.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Jull', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Keven';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Lyoni (TLID - Roam)
    select id into v_team_id from public.teams where code = 'TLID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Lyoni', 'ID', '/players/id/tlid/lyoni.webp', 'https://liquipedia.net/mobilelegends/Lyoni', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/tlid/lyoni.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Lyoni', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Lyoni';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Anaver (TLID - Midlane)
    select id into v_team_id from public.teams where code = 'TLID' and region_code = 'ID';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Anaver', 'ID', '/players/id/tlid/anaver.webp', 'https://liquipedia.net/mobilelegends/NenShikii', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/id/tlid/anaver.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/NenShikii', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Anaver';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
  end if;

  -- ==================== REGION: PH ====================
  select id into v_season_id from public.seasons where region_code = 'PH' and season_number = 18;
  if v_season_id is not null then
    -- JMPINKMAN (APBR - EXP Lane)
    select id into v_team_id from public.teams where code = 'APBR' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('JMPINKMAN', 'PH', '/players/ph/apbr/jmpinkman.webp', 'https://liquipedia.net/mobilelegends/JM', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/apbr/jmpinkman.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/JM', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'JMPINKMAN';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Jamespangks (APBR - Jungle)
    select id into v_team_id from public.teams where code = 'APBR' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Jamespangks', 'PH', '/players/ph/apbr/jamespangks.webp', 'https://liquipedia.net/mobilelegends/Jamespangks', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/apbr/jamespangks.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Jamespangks', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Jamespangks';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- LanceCy (APBR - Midlane)
    select id into v_team_id from public.teams where code = 'APBR' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('LanceCy', 'PH', '/players/ph/apbr/lancecy.webp', 'https://liquipedia.net/mobilelegends/LanceCy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/apbr/lancecy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/LanceCy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'LanceCy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Shizou (APBR - Gold Lane)
    select id into v_team_id from public.teams where code = 'APBR' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Shizou', 'PH', '/players/ph/apbr/shizou.webp', 'https://liquipedia.net/mobilelegends/Shizou', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/apbr/shizou.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Shizou', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Shizou';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Escalera (APBR - Roam)
    select id into v_team_id from public.teams where code = 'APBR' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Escalera', 'PH', '/players/ph/apbr/escalera.webp', 'https://liquipedia.net/mobilelegends/Escalera', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/apbr/escalera.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Escalera', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Escalera';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Allen (APBR - EXP Lane)
    select id into v_team_id from public.teams where code = 'APBR' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Allen', 'PH', null, 'https://liquipedia.net/mobilelegends/Allen', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Allen', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Allen';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Nathzz (RORA - EXP Lane)
    select id into v_team_id from public.teams where code = 'RORA' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Nathzz', 'PH', '/players/ph/rora/nathzz.webp', 'https://liquipedia.net/mobilelegends/Nathzz', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/rora/nathzz.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Nathzz', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Nathzz';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Koyl (RORA - Jungle)
    select id into v_team_id from public.teams where code = 'RORA' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Koyl', 'PH', '/players/ph/rora/koyl.webp', 'https://liquipedia.net/mobilelegends/Koyl', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/rora/koyl.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Koyl', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Koyl';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Yue (RORA - Midlane)
    select id into v_team_id from public.teams where code = 'RORA' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Yue', 'PH', '/players/ph/rora/yue.webp', 'https://liquipedia.net/mobilelegends/Yue', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/rora/yue.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Yue', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Yue';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Domeng (RORA - Gold Lane)
    select id into v_team_id from public.teams where code = 'RORA' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Domeng', 'PH', '/players/ph/rora/domeng.webp', 'https://liquipedia.net/mobilelegends/Domeng', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/rora/domeng.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Domeng', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Domeng';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Light (RORA - Roam)
    select id into v_team_id from public.teams where code = 'RORA' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Light', 'PH', '/players/ph/rora/light.webp', 'https://liquipedia.net/mobilelegends/Light', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/rora/light.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Light', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Light';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Yecs (RORA - Flex)
    select id into v_team_id from public.teams where code = 'RORA' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Yecs', 'PH', null, 'https://liquipedia.net/mobilelegends/Yecs', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Yecs', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Yecs';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Flex', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Louis (OMG - EXP Lane)
    select id into v_team_id from public.teams where code = 'OMG' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Louis', 'PH', '/players/ph/omg/louis.webp', 'https://liquipedia.net/mobilelegends/Louis', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/omg/louis.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Louis', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Louis';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Raizen (OMG - Jungle)
    select id into v_team_id from public.teams where code = 'OMG' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Raizen', 'PH', '/players/ph/omg/raizen.webp', 'https://liquipedia.net/mobilelegends/Raizen', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/omg/raizen.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Raizen', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Raizen';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Minguin (OMG - Midlane)
    select id into v_team_id from public.teams where code = 'OMG' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Minguin', 'PH', '/players/ph/omg/minguin.webp', 'https://liquipedia.net/mobilelegends/Minguin', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/omg/minguin.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Minguin', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Minguin';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Cull (OMG - Gold Lane)
    select id into v_team_id from public.teams where code = 'OMG' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Cull', 'PH', null, 'https://liquipedia.net/mobilelegends/Cull', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Cull', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Cull';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Perkziva (OMG - Roam)
    select id into v_team_id from public.teams where code = 'OMG' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Perkziva', 'PH', '/players/ph/omg/perkziva.webp', 'https://liquipedia.net/mobilelegends/Perkz', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/omg/perkziva.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Perkz', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Perkziva';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Peuder (OMG - Flex)
    select id into v_team_id from public.teams where code = 'OMG' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Peuder', 'PH', null, 'https://liquipedia.net/mobilelegends/Peuder', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Peuder', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Peuder';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Flex', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kirk (ONPH - EXP Lane)
    select id into v_team_id from public.teams where code = 'ONPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kirk', 'PH', '/players/ph/onph/kirk.webp', 'https://liquipedia.net/mobilelegends/Kirk', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/onph/kirk.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Kirk', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kirk';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- K1NGKONG (ONPH - Jungle)
    select id into v_team_id from public.teams where code = 'ONPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('K1NGKONG', 'PH', '/players/ph/onph/k1ngkong.webp', 'https://liquipedia.net/mobilelegends/K1NGKONG', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/onph/k1ngkong.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/K1NGKONG', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'K1NGKONG';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Super Frince (ONPH - Midlane)
    select id into v_team_id from public.teams where code = 'ONPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Super Frince', 'PH', '/players/ph/onph/super-frince.webp', 'https://liquipedia.net/mobilelegends/Super Frince', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/onph/super-frince.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Super Frince', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Super Frince';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Savero (ONPH - Gold Lane)
    select id into v_team_id from public.teams where code = 'ONPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Savero', 'PH', '/players/ph/onph/savero.webp', 'https://liquipedia.net/mobilelegends/Savero', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/onph/savero.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Savero', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Savero';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Super Yoshi (ONPH - Roam)
    select id into v_team_id from public.teams where code = 'ONPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Super Yoshi', 'PH', '/players/ph/onph/super-yoshi.webp', 'https://liquipedia.net/mobilelegends/Super Yoshi', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/onph/super-yoshi.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Super Yoshi', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Super Yoshi';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Dann (ONPH - EXP Lane)
    select id into v_team_id from public.teams where code = 'ONPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Dann', 'PH', null, 'https://liquipedia.net/mobilelegends/Dan', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Dan', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Dann';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Brusko (ONPH - Roam)
    select id into v_team_id from public.teams where code = 'ONPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Brusko', 'PH', null, 'https://liquipedia.net/mobilelegends/Brusko', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Brusko', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Brusko';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Flap (FLCN - EXP Lane)
    select id into v_team_id from public.teams where code = 'FLCN' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Flap', 'PH', '/players/ph/flcn/flap.webp', 'https://liquipedia.net/mobilelegends/FlapTzy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/flcn/flap.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/FlapTzy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Flap';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kyle (FLCN - Jungle)
    select id into v_team_id from public.teams where code = 'FLCN' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kyle', 'PH', '/players/ph/flcn/kyle.webp', 'https://liquipedia.net/mobilelegends/KyleTzy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/flcn/kyle.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/KyleTzy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kyle';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Hadji (FLCN - Midlane)
    select id into v_team_id from public.teams where code = 'FLCN' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Hadji', 'PH', '/players/ph/flcn/hadji.webp', 'https://liquipedia.net/mobilelegends/Hadji', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/flcn/hadji.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Hadji', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Hadji';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Super Marco (FLCN - Gold Lane)
    select id into v_team_id from public.teams where code = 'FLCN' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Super Marco', 'PH', '/players/ph/flcn/super-marco.webp', 'https://liquipedia.net/mobilelegends/Super Marco', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/flcn/super-marco.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Super Marco', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Super Marco';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Owgwen (FLCN - Roam)
    select id into v_team_id from public.teams where code = 'FLCN' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Owgwen', 'PH', '/players/ph/flcn/owgwen.webp', 'https://liquipedia.net/mobilelegends/Owgwen', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/flcn/owgwen.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Owgwen', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Owgwen';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Ferdz (FLCN - EXP Lane)
    select id into v_team_id from public.teams where code = 'FLCN' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Ferdz', 'PH', null, 'https://liquipedia.net/mobilelegends/Ferdz', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Ferdz', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Ferdz';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Sanford (TLPH - EXP Lane)
    select id into v_team_id from public.teams where code = 'TLPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Sanford', 'PH', '/players/ph/tlph/sanford.webp', 'https://liquipedia.net/mobilelegends/Sanford', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tlph/sanford.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sanford', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Sanford';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- KarlTzy (TLPH - Jungle)
    select id into v_team_id from public.teams where code = 'TLPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('KarlTzy', 'PH', '/players/ph/tlph/karltzy.webp', 'https://liquipedia.net/mobilelegends/KarlTzy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tlph/karltzy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/KarlTzy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'KarlTzy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Sanji (TLPH - Midlane)
    select id into v_team_id from public.teams where code = 'TLPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Sanji', 'PH', '/players/ph/tlph/sanji.webp', 'https://liquipedia.net/mobilelegends/Sanji', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tlph/sanji.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sanji', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Sanji';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Teddy (TLPH - Gold Lane)
    select id into v_team_id from public.teams where code = 'TLPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Teddy', 'PH', '/players/ph/tlph/teddy.webp', 'https://liquipedia.net/mobilelegends/Teddyqt', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tlph/teddy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Teddyqt', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Teddy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Jaypee (TLPH - Roam)
    select id into v_team_id from public.teams where code = 'TLPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Jaypee', 'PH', '/players/ph/tlph/jaypee.webp', 'https://liquipedia.net/mobilelegends/Jaypee', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tlph/jaypee.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Jaypee', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Jaypee';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Daiki (TLPH - Gold Lane)
    select id into v_team_id from public.teams where code = 'TLPH' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Daiki', 'PH', null, 'https://liquipedia.net/mobilelegends/Dai Ki', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Dai Ki', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Daiki';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Ryota (TNC - EXP Lane)
    select id into v_team_id from public.teams where code = 'TNC' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Ryota', 'PH', '/players/ph/tnc/ryota.webp', 'https://liquipedia.net/mobilelegends/Ryota', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tnc/ryota.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Ryota', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Ryota';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Zaida (TNC - Jungle)
    select id into v_team_id from public.teams where code = 'TNC' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Zaida', 'PH', '/players/ph/tnc/zaida.webp', 'https://liquipedia.net/mobilelegends/Zaida', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tnc/zaida.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Zaida', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Zaida';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Vin (TNC - Midlane)
    select id into v_team_id from public.teams where code = 'TNC' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Vin', 'PH', '/players/ph/tnc/vin.webp', 'https://liquipedia.net/mobilelegends/Vinnn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tnc/vin.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Vinnn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Vin';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Jowm (TNC - Gold Lane)
    select id into v_team_id from public.teams where code = 'TNC' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Jowm', 'PH', '/players/ph/tnc/jowm.webp', 'https://liquipedia.net/mobilelegends/Jowm', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/tnc/jowm.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Jowm', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Jowm';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Zehn (TNC - Roam)
    select id into v_team_id from public.teams where code = 'TNC' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Zehn', 'PH', null, 'https://liquipedia.net/mobilelegends/Zehn', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Zehn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Zehn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Yeyeniya (TNC - Flex)
    select id into v_team_id from public.teams where code = 'TNC' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Yeyeniya', 'PH', null, 'https://liquipedia.net/mobilelegends/Lift', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Lift', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Yeyeniya';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Flex', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Lansu (TWIS - EXP Lane)
    select id into v_team_id from public.teams where code = 'TWIS' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Lansu', 'PH', '/players/ph/twis/lansu.webp', 'https://liquipedia.net/mobilelegends/Lansu', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/twis/lansu.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Lansu', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Lansu';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'EXP Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Sensu1 (TWIS - Jungle)
    select id into v_team_id from public.teams where code = 'TWIS' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Sensu1', 'PH', '/players/ph/twis/sensu1.webp', 'https://liquipedia.net/mobilelegends/Sensui', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/twis/sensu1.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sensui', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Sensu1';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Jungle', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Sionnn (TWIS - Midlane)
    select id into v_team_id from public.teams where code = 'TWIS' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Sionnn', 'PH', '/players/ph/twis/sionnn.webp', 'https://liquipedia.net/mobilelegends/Sionnn', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/twis/sionnn.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Sionnn', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Sionnn';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Bennyqt (TWIS - Gold Lane)
    select id into v_team_id from public.teams where code = 'TWIS' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Bennyqt', 'PH', '/players/ph/twis/bennyqt.webp', 'https://liquipedia.net/mobilelegends/Bennyqt', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/twis/bennyqt.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Bennyqt', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Bennyqt';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Gold Lane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Tracy (TWIS - Roam)
    select id into v_team_id from public.teams where code = 'TWIS' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Tracy', 'PH', '/players/ph/twis/tracy.webp', 'https://liquipedia.net/mobilelegends/Tracy', now())
      on conflict (handle) do update set
        photo_url = coalesce('/players/ph/twis/tracy.webp', public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Tracy', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Tracy';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Roam', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
    -- Kurtt (TWIS - Midlane)
    select id into v_team_id from public.teams where code = 'TWIS' and region_code = 'PH';
    if v_team_id is not null then
      insert into public.players (handle, country_code, photo_url, source_url, verified_at)
      values ('Kurtt', 'PH', null, 'https://liquipedia.net/mobilelegends/Super Kurt', now())
      on conflict (handle) do update set
        photo_url = coalesce(null, public.players.photo_url),
        source_url = coalesce('https://liquipedia.net/mobilelegends/Super Kurt', public.players.source_url),
        verified_at = now()
      returning id into v_player_id;
      if v_player_id is null then
        select id into v_player_id from public.players where handle = 'Kurtt';
      end if;
      insert into public.season_rosters (season_id, team_id, player_id, role, active, notes)
      values (v_season_id, v_team_id, v_player_id, 'Midlane', true, 'Official Season 18 Roster Sync')
      on conflict (season_id, player_id) do update set
        team_id = excluded.team_id,
        role = excluded.role,
        active = true,
        notes = excluded.notes;
    end if;
  end if;

end $$;
