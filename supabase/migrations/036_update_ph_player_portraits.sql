-- Migration 036: Update verified portrait for TNC Vin (Ervin Franco)
update public.players
set 
  photo_url = '/players/ph/tnc/vin.webp',
  country_code = coalesce(country_code, 'PH'),
  source_url = 'https://liquipedia.net/mobilelegends/Vinnn',
  verified_at = now()
where handle in ('Vin', 'Vinnn');
