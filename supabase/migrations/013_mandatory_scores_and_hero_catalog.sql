-- Fantasy MPL — Mandatory exact scores and complete hero role catalog
-- Run after 012_profile_privilege_hardening.sql

-- Existing beta predictions without an exact score cannot satisfy the new
-- mandatory rule and cannot be repaired without guessing the user's intent.
-- Remove only those incomplete rows so affected users can submit again.
with removed as (
  delete from public.match_predictions
  where predicted_home_score is null or predicted_away_score is null
  returning id
)
select count(*) as incomplete_predictions_removed from removed;

alter table public.match_predictions
  alter column predicted_home_score set not null,
  alter column predicted_away_score set not null;

create or replace function public.validate_mandatory_match_score()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  fixture public.matches;
  wins_required integer;
begin
  select * into fixture from public.matches where id = new.match_id;
  if not found then raise exception 'Match not found'; end if;

  wins_required := (fixture.best_of / 2) + 1;

  if new.predicted_winner_team_id = fixture.home_team_id then
    if new.predicted_home_score <> wins_required
       or new.predicted_away_score < 0
       or new.predicted_away_score >= wins_required then
      raise exception 'Invalid BO% score for predicted home winner', fixture.best_of;
    end if;
  elsif new.predicted_winner_team_id = fixture.away_team_id then
    if new.predicted_away_score <> wins_required
       or new.predicted_home_score < 0
       or new.predicted_home_score >= wins_required then
      raise exception 'Invalid BO% score for predicted away winner', fixture.best_of;
    end if;
  else
    raise exception 'Predicted winner is not part of this match';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_mandatory_match_score_before_write
on public.match_predictions;

create trigger validate_mandatory_match_score_before_write
before insert or update on public.match_predictions
for each row execute function public.validate_mandatory_match_score();

-- Complete lane-based hero catalog. Flexible heroes intentionally appear in
-- more than one standard role.
insert into public.heroes (name, standard_roles, active, source_url)
values
  ('AAMON', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('AKAI', array['JUNGLE','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ALDOUS', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ALICE', array['EXP','MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ALUCARD', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ANGELA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ARGUS', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ARLOTT', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ATLAS', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('AULUS', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('AURORA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BADANG', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BALMOND', array['EXP','JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BANE', array['EXP','MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BARATS', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BAXIA', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BEATRIX', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BELERICK', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BENEDETTA', array['EXP','JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BRODY', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('BRUNO', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CARMILLA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CECILION', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CHANG’E', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CHIP', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CHOU', array['EXP','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CICI', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CLAUDE', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CLINT', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('CYCLOPS', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('DIGGIE', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('DYRROTH', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('EDITH', array['EXP','GOLD','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ESMERALDA', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ESTES', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('EUDORA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('FANNY', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('FARAMIS', array['MID','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('FLORYN', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('FRANCO', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('FREDRINN', array['JUNGLE','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('FREYA', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('GATOTKACA', array['EXP','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('GLOO', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('GORD', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('GRANGER', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('GROCK', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('GUINEVERE', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('GUSION', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('HANABI', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('HANZO', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('HARITH', array['MID','GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('HARLEY', array['JUNGLE','MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('HAYABUSA', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('HELCURT', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('HILDA', array['EXP','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('HYLOS', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('IRITHEL', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('IXIA', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('JAWHEAD', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('JOHNSON', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('JOY', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('JULIAN', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KADITA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KAGURA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KAJA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KALEA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KARINA', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KARRIE', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KHALEED', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KHUFRA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('KIMMY', array['MID','GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LANCELOT', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LAPU-LAPU', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LAYLA', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LEOMORD', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LESLEY', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LING', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LOLITA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LUKAS', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LUNOX', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LUO YI', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('LYLIA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MARCEL', array['EXP','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MARTIS', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MASHA', array['EXP','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MATHILDA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MELISSA', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MINOTAUR', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MINSITTHAR', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MIYA', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('MOSKOV', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('NANA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('NATALIA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('NATAN', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('NOLAN', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('NOVARIA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('OBSIDIA', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ODETTE', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('PAQUITO', array['EXP','JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('PHARSA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('PHOVEUS', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('POPOL AND KUPA', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('RAFAELA', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ROGER', array['JUNGLE','GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('RUBY', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('SABER', array['JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('SELENA', array['JUNGLE','MID','ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('SILVANNA', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('SORA', array['EXP','JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('SUN', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('SUYOU', array['EXP','JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('TERIZLA', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('THAMUZ', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('TIGREAL', array['ROAM']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('URANUS', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('VALE', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('VALENTINA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('VALIR', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('VEXANA', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('WANWAN', array['GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('X.BORG', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('XAVIER', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('YI SUN-SHIN', array['JUNGLE','GOLD']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('YIN', array['EXP','JUNGLE']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('YU ZHONG', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('YVE', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ZETIAN', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ZHASK', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ZHUXIN', array['MID']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes'),
  ('ZILONG', array['EXP']::text[], true, 'https://liquipedia.net/mobilelegends/Portal:Heroes')
on conflict (name) do update set
  standard_roles = excluded.standard_roles,
  active = true,
  source_url = excluded.source_url,
  updated_at = now();

select
  (select count(*) from public.heroes where active = true) as active_heroes,
  (select count(*) from public.match_predictions
   where predicted_home_score is null or predicted_away_score is null) as incomplete_predictions;
