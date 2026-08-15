-- Fantasy MPL — Verified Season 18 identity and Week 1 seed
-- Run after 002_competitions_predictions_scoring.sql

-- Stable conflict targets for repeatable imports.
create unique index if not exists players_handle_unique on public.players (handle);
create unique index if not exists matches_unique_fixture
  on public.matches (season_id, home_team_id, away_team_id, scheduled_at);

-- Verified team identities.

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('MY', 'AC', 'AC ESPORTS', '/teams/my/ac.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplmy/s18/teams/AC_LOGO.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('MY', 'BTRM', 'BIGETRON MY BY VIT', '/teams/my/btrm.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplmy/s18/teams/BTRM-LOGO_MAIN.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('MY', 'FL', 'TEAM FLASH', '/teams/my/fl.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplmy/s18/teams/Team_Flash_white.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('MY', 'IG', 'INVICTUS GAMING', '/teams/my/ig.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplmy/s18/teams/INVICTUS_GAMING.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('MY', 'RRQMY', 'RRQ TORA', '/teams/my/rrqmy.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplmy/s18/teams/RRQ_LOGO_MAIN.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('MY', 'SRG', 'SELANGOR RED GIANTS', '/teams/my/srg.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplmy/s18/teams/SRG-LOGO-MAIN.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('MY', 'TR', 'TEAM REY', '/teams/my/tr.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplmy/s18/teams/team-rey.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('MY', 'VMS', 'TEAM VAMOS', '/teams/my/vms.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplmy/s18/teams/Latest-Team-Vamos-Logo.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'AE', 'ALTER EGO ESPORTS', '/teams/id/ae.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/ae-256.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'BTR', 'BIGETRON BY VIT', '/teams/id/btr.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/btr_vit.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'DEWA', 'DEWA UNITED', '/teams/id/dewa.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/dewa-united-500.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'EVOS', 'EVOS', '/teams/id/evos.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/evos-500.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'GEEK', 'GEEK FAM', '/teams/id/geek.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/geek-500.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'NAVI', 'NAVI', '/teams/id/navi.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/NAVI-2.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'ONICID', 'ONIC', '/teams/id/onicid.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/onic-b-256.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'RRQID', 'RRQ HOSHI', '/teams/id/rrqid.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/rrq-500.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('ID', 'TLID', 'TEAM LIQUID ID', '/teams/id/tlid.webp', true, 'https://wsrv.nl/?url=https://ik.imagekit.io/nloe8dhf7w/mplid/s14/teams/TLID-Primary500x500.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('PH', 'APBR', 'AP BREN', '/teams/ph/apbr.webp', true, 'https://mplph-storage.sgp1.digitaloceanspaces.com/season12/Logo/APBREN-LOGO3.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('PH', 'RORA', 'AURORA GAMING', '/teams/ph/rora.webp', true, 'https://mplph-storage.sgp1.digitaloceanspaces.com/season16/teams/rora.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('PH', 'ONPH', 'ONIC PH', '/teams/ph/onph.webp', true, 'https://mplph-storage.sgp1.digitaloceanspaces.com/season16/teams/onicph_bw.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('PH', 'OMG', 'SMART OMEGA', '/teams/ph/omg.webp', true, 'https://mplph-storage.sgp1.digitaloceanspaces.com/season14/teams/smart_500.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('PH', 'FLCN', 'TEAM FALCONS', '/teams/ph/flcn.webp', true, 'https://mplph-storage.sgp1.digitaloceanspaces.com/season16/teams/flcn.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('PH', 'TLPH', 'TEAM LIQUID PH', '/teams/ph/tlph.webp', true, 'https://mplph-storage.sgp1.digitaloceanspaces.com/season18/new-team-logo/team-liquid-ph.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('PH', 'TNC', 'TNC PRO TEAM', '/teams/ph/tnc.webp', true, 'https://mplph-storage.sgp1.digitaloceanspaces.com/season8/teams/tnc-500.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.teams (region_code, code, name, logo_url, active, source_url, verified_at)
values ('PH', 'TWIS', 'TWISTED MINDS PH', '/teams/ph/twis.webp', true, 'https://mplph-storage.sgp1.digitaloceanspaces.com/season15/logo%20team/twistedminds.png', '2026-08-15T00:00:00Z')
on conflict (region_code, code) do update set
  name=excluded.name, logo_url=excluded.logo_url, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;


-- Verified player identities. Nationality remains null unless independently verified.

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('NINO', null, '/players/id/ae/nino.webp', true, 'https://cdn.id-mpl.com/season18/player/AE/Nino.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('DINGARAI', null, '/players/id/ae/dingarai.webp', true, 'https://cdn.id-mpl.com/season18/player/AE/Dingarai.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('AFFAN', null, '/players/id/ae/affan.webp', true, 'https://cdn.id-mpl.com/season18/player/AE/Affan.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('REYY', null, '/players/id/ae/reyy.webp', true, 'https://cdn.id-mpl.com/season18/player/AE/Reyy.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('DALVIN', null, '/players/id/ae/dalvin.webp', true, 'https://cdn.id-mpl.com/season18/player/AE/Dalvin.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('HALIM', null, '/players/id/ae/halim.webp', true, 'https://cdn.id-mpl.com/season18/player/AE/Halim.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ALEXANDER', null, '/players/id/ae/alexander.webp', true, 'https://cdn.id-mpl.com/season18/player/AE/Alexander.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('IVANN', null, '/players/id/ae/ivann.webp', true, 'https://cdn.id-mpl.com/season18/player/AE/Ivann.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('LAUFEYSON', null, '/players/id/dewa/laufeyson.webp', true, 'https://cdn.id-mpl.com/season18/player/DEWA/Laufeyson.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('QINN', null, '/players/id/dewa/qinn.webp', true, 'https://cdn.id-mpl.com/season18/player/DEWA/Qinn.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('MAYBEEE', null, '/players/id/dewa/maybeee.webp', true, 'https://cdn.id-mpl.com/season18/player/DEWA/Maybeee.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('KAYN', null, '/players/id/dewa/kayn.webp', true, 'https://cdn.id-mpl.com/season18/player/DEWA/Kayn.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('OCTA', null, '/players/id/dewa/octa.webp', true, 'https://cdn.id-mpl.com/season18/player/DEWA/Octa.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ITOSHI KESU', null, '/players/id/dewa/itoshi-kesu.webp', true, 'https://cdn.id-mpl.com/season18/player/DEWA/Itoshi%20Kesu.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('RUL GOOD', null, '/players/id/dewa/rul-good.webp', true, 'https://cdn.id-mpl.com/season18/player/DEWA/Rul%20Good.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('BRAVO', null, '/players/id/evos/bravo.webp', true, 'https://cdn.id-mpl.com/season18/player/EVOS/Bravo.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('RENDYYY', null, '/players/id/evos/rendyyy.webp', true, 'https://cdn.id-mpl.com/season18/player/EVOS/Rendyyy.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('VELL', null, '/players/id/evos/vell.webp', true, 'https://cdn.id-mpl.com/season18/player/EVOS/Vell.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ERLAN', null, '/players/id/evos/erlan.webp', true, 'https://cdn.id-mpl.com/season18/player/EVOS/Erlan.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ALBERTTT', null, '/players/id/evos/alberttt.webp', true, 'https://cdn.id-mpl.com/season18/player/EVOS/Alberttt.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('DRIANW', null, '/players/id/evos/drianw.webp', true, 'https://cdn.id-mpl.com/season18/player/EVOS/Drianw.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('MUEZZA', null, '/players/id/evos/muezza.webp', true, 'https://cdn.id-mpl.com/season18/player/EVOS/Muezza.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('FEBRIII', null, '/players/id/geek/febriii.webp', true, 'https://cdn.id-mpl.com/season18/player/GEEK/Febriii.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('MARCEL', null, '/players/id/geek/marcel.webp', true, 'https://cdn.id-mpl.com/season18/player/GEEK/Marcel.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('KENNZYYSKIE', null, '/players/id/geek/kennzyyskie.webp', true, 'https://cdn.id-mpl.com/season18/player/GEEK/Kennzyskie.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('NAZARA', null, '/players/id/geek/nazara.webp', true, 'https://cdn.id-mpl.com/season18/player/GEEK/Nazara.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ABOYY', null, '/players/id/geek/aboyy.webp', true, 'https://cdn.id-mpl.com/season18/player/GEEK/Aboy.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('AUDYTZY', null, '/players/id/geek/audytzy.webp', true, 'https://cdn.id-mpl.com/season18/player/GEEK/Audytzy.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('HAN', null, '/players/id/navi/han.webp', true, 'https://cdn.id-mpl.com/season18/player/NAVI/Han.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('FEBBB', null, '/players/id/navi/febbb.webp', true, 'https://cdn.id-mpl.com/season18/player/NAVI/Febbb.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('KARSS', null, '/players/id/navi/karss.webp', true, 'https://cdn.id-mpl.com/season18/player/NAVI/Karss.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ZEONN', null, '/players/id/navi/zeonn.webp', true, 'https://cdn.id-mpl.com/season18/player/NAVI/Zeonn.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ANDORYUUU', null, '/players/id/navi/andoryuuu.webp', true, 'https://cdn.id-mpl.com/season18/player/NAVI/Andoryuuu.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('JIIZEE', null, '/players/id/navi/jiizee.webp', true, 'https://cdn.id-mpl.com/season18/player/NAVI/Jiize.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('APRHO', null, '/players/id/navi/aprho.webp', true, 'https://cdn.id-mpl.com/season18/player/NAVI/Aprho.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('JOSHUA', null, '/players/id/rrqid/joshua.webp', true, 'https://cdn.id-mpl.com/season18/player/RRQ/Joshua.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ARTHUR', null, '/players/id/rrqid/arthur.webp', true, 'https://cdn.id-mpl.com/season18/player/RRQ/Arthur.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('HABIL', null, '/players/id/rrqid/habil.webp', true, 'https://cdn.id-mpl.com/season18/player/RRQ/Habil.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('DEMONKITE', null, '/players/id/rrqid/demonkite.webp', true, 'https://cdn.id-mpl.com/season18/player/RRQ/Demonkite.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('CLAYYY', null, '/players/id/rrqid/clayyy.webp', true, 'https://cdn.id-mpl.com/season18/player/RRQ/Clayy.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('HAJIRIN', null, '/players/id/rrqid/hajirin.webp', true, 'https://cdn.id-mpl.com/season18/player/RRQ/Hajirin.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('SAID', null, '/players/id/rrqid/said.webp', true, 'https://cdn.id-mpl.com/season18/player/RRQ/Said.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('FACEHUGGER', null, '/players/id/tlid/facehugger.webp', true, 'https://cdn.id-mpl.com/season18/player/TLID/Facehugger.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ARAN', null, '/players/id/tlid/aran.webp', true, 'https://cdn.id-mpl.com/season18/player/TLID/Aran.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('KEVEN', null, '/players/id/tlid/keven.webp', true, 'https://cdn.id-mpl.com/season18/player/TLID/Keven.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('KEVIN', null, '/players/id/tlid/kevin.webp', true, 'https://cdn.id-mpl.com/season18/player/TLID/Kevin.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ANAVER', null, '/players/id/tlid/anaver.webp', true, 'https://cdn.id-mpl.com/season18/player/TLID/Anaver.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('DRICHEL', null, '/players/id/tlid/drichel.webp', true, 'https://cdn.id-mpl.com/season18/player/TLID/Drichel.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('LYONI', null, '/players/id/tlid/lyoni.webp', true, 'https://cdn.id-mpl.com/season18/player/TLID/Lyoni.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Momo', null, '/players/my/ac/momo.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-MOMO.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('NETS', null, '/players/my/ac/nets.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-NETS.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Zahyed', null, '/players/my/ac/zahyed.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-ZAHYED.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Izanami', null, '/players/my/ac/izanami.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-IZANAMI.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('MARTZYY', null, '/players/my/ac/martzyy.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-MARTZYY.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('REYZAR', null, '/players/my/ac/reyzar.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-REYZAR.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Jeymz', null, '/players/my/btrm/jeymz.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-Jeymz.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('AMZZIQ', null, '/players/my/btrm/amzziq.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-Amzziq.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('CikuGais', null, '/players/my/btrm/cikugais.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-CikuGais.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Chibii', null, '/players/my/btrm/chibii.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-Chibi.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Zieyy', null, '/players/my/btrm/zieyy.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-Zieyy.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('GRboy', null, '/players/my/btrm/grboy.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-GRboy.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('3Mar', null, '/players/my/fl/3mar.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-3MAR.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Vanix', null, '/players/my/fl/vanix.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-VANIX.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Garyy', null, '/players/my/fl/garyy.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-GARYY.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('UK1R', null, '/players/my/fl/uk1r.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-UK1R.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Osker', null, '/players/my/fl/osker.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-OSKER.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('XORN', null, '/players/my/fl/xorn.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-XORN.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('REZZA', null, '/players/my/ig/rezza.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-REZZA.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('YE3', null, '/players/my/ig/ye3.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-YE3.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Rokji', null, '/players/my/ig/rokji.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-NEWROKJI.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Lunnn', null, '/players/my/ig/lunnn.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-NEWLUNNN.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Treacky', null, '/players/my/ig/treacky.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-TREACKY.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ATANNN', null, '/players/my/ig/atannn.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-NEWATANNN.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('LEHTZY', null, '/players/my/rrqmy/lehtzy.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-LEHTZY.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('IZZSHIKI', null, '/players/my/rrqmy/izzshiki.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-IZZSHIKI.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Loleal', null, '/players/my/rrqmy/loleal.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-LOLEAL.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('SUPERKENN', null, '/players/my/rrqmy/superkenn.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-SUPERKENN.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('AJ', null, '/players/my/rrqmy/aj.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-AJ.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Yehezkiel', null, '/players/my/rrqmy/yehezkiel.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-YEHEZKIEL.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Addboyy', null, '/players/my/rrqmy/addboyy.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S188-ADDBOYY.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('kramM', null, '/players/my/srg/kramm.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_KRAMM.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Innocent', null, '/players/my/srg/innocent.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_INNOCENT.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Sekysss', null, '/players/my/srg/sekysss.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_SEKYSSS.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Unii', null, '/players/my/srg/unii.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_UNII.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Stormie', null, '/players/my/srg/stormie.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_STORMIE.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('YumS', null, '/players/my/srg/yums.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_YUMS.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('JWen', null, '/players/my/tr/jwen.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-JWEN.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('SMOOTH', null, '/players/my/tr/smooth.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-SMOOTH.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Cliveee', null, '/players/my/tr/cliveee.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-CLIVEEE.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Dolynn', null, '/players/my/tr/dolynn.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-DOLYNN.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Kyym', null, '/players/my/tr/kyym.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-KYYM.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('NovaXcobar', null, '/players/my/tr/novaxcobar.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-NOVAXCOBAR.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('SEPAT', null, '/players/my/vms/sepat.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-SEPAT.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Sizkaa', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Malaysia/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Natco', null, '/players/my/vms/natco.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-NATCO.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ERROR 404', null, '/players/my/vms/error-404.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-ERROR404.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('EYYMAL', null, '/players/my/vms/eyymal.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/EyyMal.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('CLAWKUN', null, '/players/my/vms/clawkun.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-CLAWKUN.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('ZQEEF', null, '/players/my/vms/zqeef.webp', true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-%20ZQEEF.png', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('JMPINKMAN', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Shizou', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Jamespangks', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('LanceCy', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Escalera', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Flap', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Super Marco', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Kyle', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Hadji', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Owgwen', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Louis', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Cull', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Raizen', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Minguin', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Perkziva', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Kirk', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Savero', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('K1NGKONG', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Super Frince', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Super Yoshi', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Nathzz', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Domeng', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Koyl', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Yue', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Light', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Sanford', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Teddy', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('KarlTzy', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Sanji', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Jaypee', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Ryota', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Jowm', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Zaida', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Vin', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Zehn', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Lansu', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Bennyqt', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Sensu1', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Sionnn', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.players (handle, country_code, photo_url, active, source_url, verified_at)
values ('Tracy', null, null, true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z')
on conflict (handle) do update set
  photo_url=coalesce(excluded.photo_url, public.players.photo_url),
  active=true, source_url=excluded.source_url, verified_at=excluded.verified_at;


-- Season roster relationships.

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/AE/Nino.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'NINO'
join public.teams t on t.region_code = 'ID' and t.code = 'AE'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/AE/Dingarai.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'DINGARAI'
join public.teams t on t.region_code = 'ID' and t.code = 'AE'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/AE/Affan.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'AFFAN'
join public.teams t on t.region_code = 'ID' and t.code = 'AE'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/AE/Reyy.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'REYY'
join public.teams t on t.region_code = 'ID' and t.code = 'AE'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/AE/Dalvin.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'DALVIN'
join public.teams t on t.region_code = 'ID' and t.code = 'AE'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/AE/Halim.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'HALIM'
join public.teams t on t.region_code = 'ID' and t.code = 'AE'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/AE/Alexander.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ALEXANDER'
join public.teams t on t.region_code = 'ID' and t.code = 'AE'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/AE/Ivann.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'IVANN'
join public.teams t on t.region_code = 'ID' and t.code = 'AE'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'FLEX', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/DEWA/Laufeyson.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'LAUFEYSON'
join public.teams t on t.region_code = 'ID' and t.code = 'DEWA'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/DEWA/Qinn.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'QINN'
join public.teams t on t.region_code = 'ID' and t.code = 'DEWA'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/DEWA/Maybeee.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'MAYBEEE'
join public.teams t on t.region_code = 'ID' and t.code = 'DEWA'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/DEWA/Kayn.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'KAYN'
join public.teams t on t.region_code = 'ID' and t.code = 'DEWA'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/DEWA/Octa.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'OCTA'
join public.teams t on t.region_code = 'ID' and t.code = 'DEWA'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/DEWA/Itoshi%20Kesu.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ITOSHI KESU'
join public.teams t on t.region_code = 'ID' and t.code = 'DEWA'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/DEWA/Rul%20Good.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'RUL GOOD'
join public.teams t on t.region_code = 'ID' and t.code = 'DEWA'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'FLEX', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/EVOS/Bravo.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'BRAVO'
join public.teams t on t.region_code = 'ID' and t.code = 'EVOS'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/EVOS/Rendyyy.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'RENDYYY'
join public.teams t on t.region_code = 'ID' and t.code = 'EVOS'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/EVOS/Vell.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'VELL'
join public.teams t on t.region_code = 'ID' and t.code = 'EVOS'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/EVOS/Erlan.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ERLAN'
join public.teams t on t.region_code = 'ID' and t.code = 'EVOS'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/EVOS/Alberttt.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ALBERTTT'
join public.teams t on t.region_code = 'ID' and t.code = 'EVOS'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/EVOS/Drianw.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'DRIANW'
join public.teams t on t.region_code = 'ID' and t.code = 'EVOS'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/EVOS/Muezza.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'MUEZZA'
join public.teams t on t.region_code = 'ID' and t.code = 'EVOS'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/GEEK/Febriii.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'FEBRIII'
join public.teams t on t.region_code = 'ID' and t.code = 'GEEK'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/GEEK/Marcel.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'MARCEL'
join public.teams t on t.region_code = 'ID' and t.code = 'GEEK'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/GEEK/Kennzyskie.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'KENNZYYSKIE'
join public.teams t on t.region_code = 'ID' and t.code = 'GEEK'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/GEEK/Nazara.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'NAZARA'
join public.teams t on t.region_code = 'ID' and t.code = 'GEEK'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/GEEK/Aboy.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ABOYY'
join public.teams t on t.region_code = 'ID' and t.code = 'GEEK'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/GEEK/Audytzy.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'AUDYTZY'
join public.teams t on t.region_code = 'ID' and t.code = 'GEEK'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'FLEX', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/NAVI/Han.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'HAN'
join public.teams t on t.region_code = 'ID' and t.code = 'NAVI'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/NAVI/Febbb.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'FEBBB'
join public.teams t on t.region_code = 'ID' and t.code = 'NAVI'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/NAVI/Karss.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'KARSS'
join public.teams t on t.region_code = 'ID' and t.code = 'NAVI'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/NAVI/Zeonn.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ZEONN'
join public.teams t on t.region_code = 'ID' and t.code = 'NAVI'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/NAVI/Andoryuuu.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ANDORYUUU'
join public.teams t on t.region_code = 'ID' and t.code = 'NAVI'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/NAVI/Jiize.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'JIIZEE'
join public.teams t on t.region_code = 'ID' and t.code = 'NAVI'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/NAVI/Aprho.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'APRHO'
join public.teams t on t.region_code = 'ID' and t.code = 'NAVI'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/RRQ/Joshua.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'JOSHUA'
join public.teams t on t.region_code = 'ID' and t.code = 'RRQID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/RRQ/Arthur.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ARTHUR'
join public.teams t on t.region_code = 'ID' and t.code = 'RRQID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/RRQ/Habil.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'HABIL'
join public.teams t on t.region_code = 'ID' and t.code = 'RRQID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/RRQ/Demonkite.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'DEMONKITE'
join public.teams t on t.region_code = 'ID' and t.code = 'RRQID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/RRQ/Clayy.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'CLAYYY'
join public.teams t on t.region_code = 'ID' and t.code = 'RRQID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/RRQ/Hajirin.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'HAJIRIN'
join public.teams t on t.region_code = 'ID' and t.code = 'RRQID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/RRQ/Said.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'SAID'
join public.teams t on t.region_code = 'ID' and t.code = 'RRQID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'FLEX', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/TLID/Facehugger.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'FACEHUGGER'
join public.teams t on t.region_code = 'ID' and t.code = 'TLID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/TLID/Aran.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ARAN'
join public.teams t on t.region_code = 'ID' and t.code = 'TLID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/TLID/Keven.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'KEVEN'
join public.teams t on t.region_code = 'ID' and t.code = 'TLID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/TLID/Kevin.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'KEVIN'
join public.teams t on t.region_code = 'ID' and t.code = 'TLID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/TLID/Anaver.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ANAVER'
join public.teams t on t.region_code = 'ID' and t.code = 'TLID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/TLID/Drichel.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'DRICHEL'
join public.teams t on t.region_code = 'ID' and t.code = 'TLID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://cdn.id-mpl.com/season18/player/TLID/Lyoni.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'LYONI'
join public.teams t on t.region_code = 'ID' and t.code = 'TLID'
where s.region_code = 'ID' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-MOMO.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Momo'
join public.teams t on t.region_code = 'MY' and t.code = 'AC'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-NETS.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'NETS'
join public.teams t on t.region_code = 'MY' and t.code = 'AC'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-ZAHYED.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Zahyed'
join public.teams t on t.region_code = 'MY' and t.code = 'AC'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-IZANAMI.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Izanami'
join public.teams t on t.region_code = 'MY' and t.code = 'AC'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-MARTZYY.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'MARTZYY'
join public.teams t on t.region_code = 'MY' and t.code = 'AC'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/AC/S18-REYZAR.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'REYZAR'
join public.teams t on t.region_code = 'MY' and t.code = 'AC'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-Jeymz.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Jeymz'
join public.teams t on t.region_code = 'MY' and t.code = 'BTRM'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-Amzziq.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'AMZZIQ'
join public.teams t on t.region_code = 'MY' and t.code = 'BTRM'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-CikuGais.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'CikuGais'
join public.teams t on t.region_code = 'MY' and t.code = 'BTRM'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-Chibi.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Chibii'
join public.teams t on t.region_code = 'MY' and t.code = 'BTRM'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-Zieyy.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Zieyy'
join public.teams t on t.region_code = 'MY' and t.code = 'BTRM'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/BTRM/S18-GRboy.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'GRboy'
join public.teams t on t.region_code = 'MY' and t.code = 'BTRM'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-3MAR.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = '3Mar'
join public.teams t on t.region_code = 'MY' and t.code = 'FL'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-VANIX.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Vanix'
join public.teams t on t.region_code = 'MY' and t.code = 'FL'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-GARYY.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Garyy'
join public.teams t on t.region_code = 'MY' and t.code = 'FL'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-UK1R.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'UK1R'
join public.teams t on t.region_code = 'MY' and t.code = 'FL'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-OSKER.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Osker'
join public.teams t on t.region_code = 'MY' and t.code = 'FL'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMFLASH/S18-XORN.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'XORN'
join public.teams t on t.region_code = 'MY' and t.code = 'FL'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-REZZA.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'REZZA'
join public.teams t on t.region_code = 'MY' and t.code = 'IG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-YE3.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'YE3'
join public.teams t on t.region_code = 'MY' and t.code = 'IG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-NEWROKJI.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Rokji'
join public.teams t on t.region_code = 'MY' and t.code = 'IG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-NEWLUNNN.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Lunnn'
join public.teams t on t.region_code = 'MY' and t.code = 'IG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-TREACKY.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Treacky'
join public.teams t on t.region_code = 'MY' and t.code = 'IG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/Invictus-Gaming/S18-NEWATANNN.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ATANNN'
join public.teams t on t.region_code = 'MY' and t.code = 'IG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-LEHTZY.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'LEHTZY'
join public.teams t on t.region_code = 'MY' and t.code = 'RRQMY'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-IZZSHIKI.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'IZZSHIKI'
join public.teams t on t.region_code = 'MY' and t.code = 'RRQMY'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-LOLEAL.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Loleal'
join public.teams t on t.region_code = 'MY' and t.code = 'RRQMY'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-SUPERKENN.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'SUPERKENN'
join public.teams t on t.region_code = 'MY' and t.code = 'RRQMY'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-AJ.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'AJ'
join public.teams t on t.region_code = 'MY' and t.code = 'RRQMY'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S18-YEHEZKIEL.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Yehezkiel'
join public.teams t on t.region_code = 'MY' and t.code = 'RRQMY'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/RRQ/S188-ADDBOYY.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Addboyy'
join public.teams t on t.region_code = 'MY' and t.code = 'RRQMY'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_KRAMM.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'kramM'
join public.teams t on t.region_code = 'MY' and t.code = 'SRG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_INNOCENT.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Innocent'
join public.teams t on t.region_code = 'MY' and t.code = 'SRG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_SEKYSSS.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Sekysss'
join public.teams t on t.region_code = 'MY' and t.code = 'SRG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_UNII.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Unii'
join public.teams t on t.region_code = 'MY' and t.code = 'SRG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_STORMIE.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Stormie'
join public.teams t on t.region_code = 'MY' and t.code = 'SRG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/SRG/S18_YUMS.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'YumS'
join public.teams t on t.region_code = 'MY' and t.code = 'SRG'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-JWEN.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'JWen'
join public.teams t on t.region_code = 'MY' and t.code = 'TR'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-SMOOTH.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'SMOOTH'
join public.teams t on t.region_code = 'MY' and t.code = 'TR'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-CLIVEEE.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Cliveee'
join public.teams t on t.region_code = 'MY' and t.code = 'TR'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-DOLYNN.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Dolynn'
join public.teams t on t.region_code = 'MY' and t.code = 'TR'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-KYYM.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Kyym'
join public.teams t on t.region_code = 'MY' and t.code = 'TR'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/TEAMREY/S18-NOVAXCOBAR.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'NovaXcobar'
join public.teams t on t.region_code = 'MY' and t.code = 'TR'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-SEPAT.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'SEPAT'
join public.teams t on t.region_code = 'MY' and t.code = 'VMS'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Malaysia/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Sizkaa'
join public.teams t on t.region_code = 'MY' and t.code = 'VMS'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-NATCO.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Natco'
join public.teams t on t.region_code = 'MY' and t.code = 'VMS'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-ERROR404.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ERROR 404'
join public.teams t on t.region_code = 'MY' and t.code = 'VMS'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/EyyMal.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'EYYMAL'
join public.teams t on t.region_code = 'MY' and t.code = 'VMS'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-CLAWKUN.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'CLAWKUN'
join public.teams t on t.region_code = 'MY' and t.code = 'VMS'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-14T00:00:00Z'::timestamptz,
  true, 'https://mplmy-storage.sgp1.digitaloceanspaces.com/season18/player/VAMOS/S18-%20ZQEEF.png', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'ZQEEF'
join public.teams t on t.region_code = 'MY' and t.code = 'VMS'
where s.region_code = 'MY' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'JMPINKMAN'
join public.teams t on t.region_code = 'PH' and t.code = 'APBR'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Shizou'
join public.teams t on t.region_code = 'PH' and t.code = 'APBR'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Jamespangks'
join public.teams t on t.region_code = 'PH' and t.code = 'APBR'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'LanceCy'
join public.teams t on t.region_code = 'PH' and t.code = 'APBR'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Escalera'
join public.teams t on t.region_code = 'PH' and t.code = 'APBR'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Flap'
join public.teams t on t.region_code = 'PH' and t.code = 'FLCN'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Super Marco'
join public.teams t on t.region_code = 'PH' and t.code = 'FLCN'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Kyle'
join public.teams t on t.region_code = 'PH' and t.code = 'FLCN'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Hadji'
join public.teams t on t.region_code = 'PH' and t.code = 'FLCN'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Owgwen'
join public.teams t on t.region_code = 'PH' and t.code = 'FLCN'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Louis'
join public.teams t on t.region_code = 'PH' and t.code = 'OMG'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Cull'
join public.teams t on t.region_code = 'PH' and t.code = 'OMG'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Raizen'
join public.teams t on t.region_code = 'PH' and t.code = 'OMG'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Minguin'
join public.teams t on t.region_code = 'PH' and t.code = 'OMG'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Perkziva'
join public.teams t on t.region_code = 'PH' and t.code = 'OMG'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Kirk'
join public.teams t on t.region_code = 'PH' and t.code = 'ONPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Savero'
join public.teams t on t.region_code = 'PH' and t.code = 'ONPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'K1NGKONG'
join public.teams t on t.region_code = 'PH' and t.code = 'ONPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Super Frince'
join public.teams t on t.region_code = 'PH' and t.code = 'ONPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Super Yoshi'
join public.teams t on t.region_code = 'PH' and t.code = 'ONPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Nathzz'
join public.teams t on t.region_code = 'PH' and t.code = 'RORA'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Domeng'
join public.teams t on t.region_code = 'PH' and t.code = 'RORA'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Koyl'
join public.teams t on t.region_code = 'PH' and t.code = 'RORA'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Yue'
join public.teams t on t.region_code = 'PH' and t.code = 'RORA'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Light'
join public.teams t on t.region_code = 'PH' and t.code = 'RORA'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Sanford'
join public.teams t on t.region_code = 'PH' and t.code = 'TLPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Teddy'
join public.teams t on t.region_code = 'PH' and t.code = 'TLPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'KarlTzy'
join public.teams t on t.region_code = 'PH' and t.code = 'TLPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Sanji'
join public.teams t on t.region_code = 'PH' and t.code = 'TLPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Jaypee'
join public.teams t on t.region_code = 'PH' and t.code = 'TLPH'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Ryota'
join public.teams t on t.region_code = 'PH' and t.code = 'TNC'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Jowm'
join public.teams t on t.region_code = 'PH' and t.code = 'TNC'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Zaida'
join public.teams t on t.region_code = 'PH' and t.code = 'TNC'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Vin'
join public.teams t on t.region_code = 'PH' and t.code = 'TNC'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Zehn'
join public.teams t on t.region_code = 'PH' and t.code = 'TNC'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'EXP', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Lansu'
join public.teams t on t.region_code = 'PH' and t.code = 'TWIS'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'GOLD', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Bennyqt'
join public.teams t on t.region_code = 'PH' and t.code = 'TWIS'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'JUNGLE', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Sensu1'
join public.teams t on t.region_code = 'PH' and t.code = 'TWIS'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'MID', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Sionnn'
join public.teams t on t.region_code = 'PH' and t.code = 'TWIS'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;

insert into public.season_rosters
  (season_id, player_id, team_id, role, starts_at, active, source_url, verified_at)
select
  s.id, p.id, t.id, 'ROAM', '2026-08-21T00:00:00Z'::timestamptz,
  true, 'https://liquipedia.net/mobilelegends/MPL/Philippines/Season_18', '2026-08-15T00:00:00Z'
from public.seasons s
join public.players p on p.handle = 'Tracy'
join public.teams t on t.region_code = 'PH' and t.code = 'TWIS'
where s.region_code = 'PH' and s.season_number = 18
on conflict (season_id, player_id, starts_at) do update set
  team_id=excluded.team_id, role=excluded.role, active=true,
  source_url=excluded.source_url, verified_at=excluded.verified_at;


-- Week 1 regional windows.

insert into public.competition_weeks
  (season_id, week_number, name, starts_at, ends_at, meta_locks_at, mvp_locks_at)
select id, 1, 'Week 1', '2026-08-14T09:00:00Z'::timestamptz, '2026-08-16T12:00:00Z'::timestamptz,
  '2026-08-14T09:00:00Z'::timestamptz, '2026-08-14T09:00:00Z'::timestamptz
from public.seasons where region_code='MY' and season_number=18
on conflict (season_id, week_number) do update set
  starts_at=excluded.starts_at, ends_at=excluded.ends_at,
  meta_locks_at=excluded.meta_locks_at, mvp_locks_at=excluded.mvp_locks_at;

insert into public.competition_weeks
  (season_id, week_number, name, starts_at, ends_at, meta_locks_at, mvp_locks_at)
select id, 1, 'Week 1', '2026-08-14T08:00:00Z'::timestamptz, '2026-08-16T14:00:00Z'::timestamptz,
  '2026-08-14T08:00:00Z'::timestamptz, '2026-08-14T08:00:00Z'::timestamptz
from public.seasons where region_code='ID' and season_number=18
on conflict (season_id, week_number) do update set
  starts_at=excluded.starts_at, ends_at=excluded.ends_at,
  meta_locks_at=excluded.meta_locks_at, mvp_locks_at=excluded.mvp_locks_at;

insert into public.competition_weeks
  (season_id, week_number, name, starts_at, ends_at, meta_locks_at, mvp_locks_at)
select id, 1, 'Week 1', '2026-08-21T09:00:00Z'::timestamptz, '2026-08-23T12:30:00Z'::timestamptz,
  '2026-08-21T09:00:00Z'::timestamptz, '2026-08-21T09:00:00Z'::timestamptz
from public.seasons where region_code='PH' and season_number=18
on conflict (season_id, week_number) do update set
  starts_at=excluded.starts_at, ends_at=excluded.ends_at,
  meta_locks_at=excluded.meta_locks_at, mvp_locks_at=excluded.mvp_locks_at;


-- Verified Week 1 fixtures. Unverified results remain intentionally empty.

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-14T09:00:00Z'::timestamptz, '2026-08-14T09:00:00Z'::timestamptz,
  'completed', 1, 2,
  (select id from public.teams where region_code='MY' and code='BTRM'),
  'finalized', 'https://my.mpl.mobilelegends.com/schedule', now()
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='MY' and ht.code='AC'
join public.teams awt on awt.region_code='MY' and awt.code='BTRM'
where s.region_code='MY' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-14T12:15:00Z'::timestamptz, '2026-08-14T12:15:00Z'::timestamptz,
  'completed', 2, 1,
  (select id from public.teams where region_code='MY' and code='VMS'),
  'finalized', 'https://my.mpl.mobilelegends.com/schedule', now()
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='MY' and ht.code='VMS'
join public.teams awt on awt.region_code='MY' and awt.code='FL'
where s.region_code='MY' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-15T06:30:00Z'::timestamptz, '2026-08-15T06:30:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://my.mpl.mobilelegends.com/schedule', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='MY' and ht.code='FL'
join public.teams awt on awt.region_code='MY' and awt.code='BTRM'
where s.region_code='MY' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-15T09:00:00Z'::timestamptz, '2026-08-15T09:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://my.mpl.mobilelegends.com/schedule', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='MY' and ht.code='RRQMY'
join public.teams awt on awt.region_code='MY' and awt.code='TR'
where s.region_code='MY' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-15T12:15:00Z'::timestamptz, '2026-08-15T12:15:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://my.mpl.mobilelegends.com/schedule', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='MY' and ht.code='SRG'
join public.teams awt on awt.region_code='MY' and awt.code='IG'
where s.region_code='MY' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-16T06:30:00Z'::timestamptz, '2026-08-16T06:30:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://my.mpl.mobilelegends.com/schedule', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='MY' and ht.code='IG'
join public.teams awt on awt.region_code='MY' and awt.code='RRQMY'
where s.region_code='MY' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-16T09:00:00Z'::timestamptz, '2026-08-16T09:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://my.mpl.mobilelegends.com/schedule', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='MY' and ht.code='TR'
join public.teams awt on awt.region_code='MY' and awt.code='SRG'
where s.region_code='MY' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-14T08:00:00Z'::timestamptz, '2026-08-14T08:00:00Z'::timestamptz,
  'completed', 2, 0,
  (select id from public.teams where region_code='ID' and code='EVOS'),
  'finalized', 'https://id-mpl.com/', now()
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='ID' and ht.code='EVOS'
join public.teams awt on awt.region_code='ID' and awt.code='RRQID'
where s.region_code='ID' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-14T11:00:00Z'::timestamptz, '2026-08-14T11:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://id-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='ID' and ht.code='NAVI'
join public.teams awt on awt.region_code='ID' and awt.code='AE'
where s.region_code='ID' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-15T07:00:00Z'::timestamptz, '2026-08-15T07:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://id-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='ID' and ht.code='TLID'
join public.teams awt on awt.region_code='ID' and awt.code='GEEK'
where s.region_code='ID' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-15T10:00:00Z'::timestamptz, '2026-08-15T10:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://id-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='ID' and ht.code='DEWA'
join public.teams awt on awt.region_code='ID' and awt.code='RRQID'
where s.region_code='ID' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-15T13:00:00Z'::timestamptz, '2026-08-15T13:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://id-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='ID' and ht.code='EVOS'
join public.teams awt on awt.region_code='ID' and awt.code='NAVI'
where s.region_code='ID' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-16T07:00:00Z'::timestamptz, '2026-08-16T07:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://id-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='ID' and ht.code='TLID'
join public.teams awt on awt.region_code='ID' and awt.code='DEWA'
where s.region_code='ID' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-16T10:00:00Z'::timestamptz, '2026-08-16T10:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://id-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='ID' and ht.code='BTR'
join public.teams awt on awt.region_code='ID' and awt.code='GEEK'
where s.region_code='ID' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-16T13:00:00Z'::timestamptz, '2026-08-16T13:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://id-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='ID' and ht.code='AE'
join public.teams awt on awt.region_code='ID' and awt.code='ONICID'
where s.region_code='ID' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-21T09:00:00Z'::timestamptz, '2026-08-21T09:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://ph-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='PH' and ht.code='RORA'
join public.teams awt on awt.region_code='PH' and awt.code='ONPH'
where s.region_code='PH' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-21T11:30:00Z'::timestamptz, '2026-08-21T11:30:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://ph-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='PH' and ht.code='TLPH'
join public.teams awt on awt.region_code='PH' and awt.code='FLCN'
where s.region_code='PH' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-22T06:30:00Z'::timestamptz, '2026-08-22T06:30:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://ph-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='PH' and ht.code='APBR'
join public.teams awt on awt.region_code='PH' and awt.code='TWIS'
where s.region_code='PH' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-22T09:00:00Z'::timestamptz, '2026-08-22T09:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://ph-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='PH' and ht.code='OMG'
join public.teams awt on awt.region_code='PH' and awt.code='TLPH'
where s.region_code='PH' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-22T11:30:00Z'::timestamptz, '2026-08-22T11:30:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://ph-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='PH' and ht.code='FLCN'
join public.teams awt on awt.region_code='PH' and awt.code='TNC'
where s.region_code='PH' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-23T09:00:00Z'::timestamptz, '2026-08-23T09:00:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://ph-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='PH' and ht.code='ONPH'
join public.teams awt on awt.region_code='PH' and awt.code='APBR'
where s.region_code='PH' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;

insert into public.matches
  (season_id, week_id, home_team_id, away_team_id, best_of, scheduled_at,
   prediction_locks_at, status, home_score, away_score, winner_team_id,
   result_state, source_url, finalized_at)
select
  s.id, w.id, ht.id, awt.id, 3, '2026-08-23T11:30:00Z'::timestamptz, '2026-08-23T11:30:00Z'::timestamptz,
  'scheduled', null, null,
  null,
  'unverified', 'https://ph-mpl.com/', null
from public.seasons s
join public.competition_weeks w on w.season_id=s.id and w.week_number=1
join public.teams ht on ht.region_code='PH' and ht.code='TNC'
join public.teams awt on awt.region_code='PH' and awt.code='RORA'
where s.region_code='PH' and s.season_number=18
on conflict (season_id, home_team_id, away_team_id, scheduled_at) do update set
  week_id=excluded.week_id, best_of=excluded.best_of,
  prediction_locks_at=excluded.prediction_locks_at,
  status=excluded.status, home_score=excluded.home_score,
  away_score=excluded.away_score, winner_team_id=excluded.winner_team_id,
  result_state=excluded.result_state, source_url=excluded.source_url,
  finalized_at=excluded.finalized_at;


-- Import summary
select
  (select count(*) from public.teams) as teams,
  (select count(*) from public.players) as players,
  (select count(*) from public.season_rosters) as roster_records,
  (select count(*) from public.matches) as matches;
