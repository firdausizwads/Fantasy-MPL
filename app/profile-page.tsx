'use client';

import { useState } from 'react';
import type { ComponentType, FormEvent, ReactNode } from 'react';
import { supabase } from '../lib/supabase/client';

export type ProfileSession = {
  name: string;
  email: string;
  country: string;
  fullName: string;
  address: string;
  bio: string;
  dob: string;
  avatar: string;
};

type PageBannerProps = { tag: string; title: string; copy: string; side: ReactNode; sideLabel: string };

const COUNTRIES = [
  { code: 'MY', name: 'Malaysia' }, { code: 'ID', name: 'Indonesia' },
  { code: 'PH', name: 'Philippines' }, { code: 'SG', name: 'Singapore' },
  { code: 'BN', name: 'Brunei' }, { code: 'TH', name: 'Thailand' },
  { code: 'VN', name: 'Vietnam' }, { code: 'KH', name: 'Cambodia' },
  { code: 'MM', name: 'Myanmar' }, { code: 'LA', name: 'Laos' },
  { code: 'OTHER', name: 'Other' }
] as const;

const getCountry = (code: string) => COUNTRIES.find(country => country.code === code) || COUNTRIES[10];

function LocalFlag({ code }: { code: string }) {
  const file = code === 'OTHER' ? 'other.svg' : `${code.toLowerCase()}.svg`;
  return <span className="nationalFlag"><img src={`/flags/${file}`} alt={`${getCountry(code).name} flag`} /></span>;
}

function ProfileGlyph() {
  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><circle cx="12" cy="8" r="4"/><path d="M4 21c1-6 15-6 16 0"/></svg>;
}

export default function ProfilePage({ session, save, notify, PageBanner }: {
  session: ProfileSession;
  save: (profile: Partial<ProfileSession>) => void;
  notify: (message: string) => void;
  PageBanner: ComponentType<PageBannerProps>;
}) {
  const [fullName, setFullName] = useState(session.fullName);
  const [name, setName] = useState(session.name);
  const [country, setCountry] = useState(session.country);
  const [address, setAddress] = useState(session.address);
  const [bio, setBio] = useState(session.bio);
  const [dob, setDob] = useState(session.dob);
  const [avatar, setAvatar] = useState(session.avatar);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [deleteName, setDeleteName] = useState('');
  const [deletePassword, setDeletePassword] = useState('');
  const [busy, setBusy] = useState(false);

  function upload(file?: File) {
    if (!file) return;
    if (file.size > 5_000_000) { notify('Choose an image smaller than 5 MB.'); return; }
    const reader = new FileReader();
    reader.onload = () => {
      const image = new Image();
      image.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = 320; canvas.height = 320;
        const context = canvas.getContext('2d');
        if (!context) return;
        const side = Math.min(image.width, image.height);
        context.drawImage(image, (image.width-side)/2, (image.height-side)/2, side, side, 0, 0, 320, 320);
        setAvatar(canvas.toDataURL('image/jpeg', .86));
      };
      image.src = String(reader.result);
    };
    reader.readAsDataURL(file);
  }

  function submit(event: FormEvent) {
    event.preventDefault();
    if (fullName.trim().length < 3) { notify('Full name is required.'); return; }
    save({ fullName: fullName.trim(), name: name.trim() || session.name, country, address: address.trim(), bio: bio.trim(), dob, avatar });
    notify('Profile updated successfully.');
  }

  async function exportData() {
    if (!supabase) { notify('Cloud data export requires Supabase.'); return; }
    setBusy(true);
    const { data, error } = await supabase.rpc('export_my_data');
    setBusy(false);
    if (error) { notify(error.message); return; }
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.download = `fantasy-mpl-data-${new Date().toISOString().slice(0,10)}.json`;
    anchor.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
    notify('Your data export has been downloaded.');
  }

  async function deleteAccount() {
    if (!supabase) return;
    if (deleteName.trim().toLowerCase() !== session.name.trim().toLowerCase()) {
      notify('Manager name confirmation does not match.'); return;
    }
    if (deletePassword.length < 8) { notify('Enter your current password.'); return; }
    setBusy(true);
    const { error: authError } = await supabase.auth.signInWithPassword({ email: session.email, password: deletePassword });
    if (authError) { setBusy(false); notify('Password confirmation failed.'); return; }
    const { error } = await supabase.rpc('delete_my_account', { confirmation_name: deleteName.trim() });
    setBusy(false);
    if (error) { notify(error.message); return; }
    localStorage.clear();
    window.location.href = '/';
  }

  const selectedCountry = getCountry(country);
  return <div className="page profilePage">
    <PageBanner tag="MANAGER ACCOUNT" title="My Profile" copy="Manage your public identity and optional personal information." side={<LocalFlag code={country}/>} sideLabel={selectedCountry.name.toUpperCase()}/>
    <div className="profileLayout">
      <aside className="profileIdentity"><div className="avatarEditor"><div>{avatar?<img src={avatar} alt="Profile preview"/>:<span>{name.slice(0,2).toUpperCase()}</span>}</div><label><ProfileGlyph/> UPLOAD PHOTO<input type="file" accept="image/png,image/jpeg,image/webp" onChange={event=>upload(event.target.files?.[0])}/></label>{avatar&&<button onClick={()=>setAvatar('')}>REMOVE PHOTO</button>}</div><h2>{name}</h2><p><LocalFlag code={country}/> {selectedCountry.name}</p><span>FANTASY MPL MANAGER</span><div className="profilePublicNote"><b>PUBLIC</b><p>YOUR MANAGER NAME, PHOTO, COUNTRY AND BIO MAY APPEAR ON LEADERBOARDS.</p></div></aside>
      <form className="profileForm" onSubmit={submit}><div className="profileFormHead"><div><h2>PROFILE INFORMATION</h2><p>ONLY YOUR FULL NAME IS REQUIRED. ALL OTHER PERSONAL DETAILS ARE OPTIONAL.</p></div><span>* REQUIRED</span></div><div className="profileFields"><label>FULL NAME *<input value={fullName} onChange={event=>setFullName(event.target.value)} placeholder="YOUR FULL NAME"/></label><label>MANAGER NAME<input value={name} onChange={event=>setName(event.target.value)} placeholder="PUBLIC DISPLAY NAME"/></label><label>COUNTRY<select value={country} onChange={event=>setCountry(event.target.value)}>{COUNTRIES.map(item=><option key={item.code} value={item.code}>{item.name.toUpperCase()}</option>)}</select></label><label>DATE OF BIRTH · OPTIONAL<input type="date" value={dob} onChange={event=>setDob(event.target.value)}/></label><label className="fullField">ADDRESS · OPTIONAL<input value={address} onChange={event=>setAddress(event.target.value)} placeholder="CITY, STATE OR FULL ADDRESS"/></label><label className="fullField">BIO · OPTIONAL<textarea maxLength={180} value={bio} onChange={event=>setBio(event.target.value)} placeholder="TELL THE COMMUNITY ABOUT YOURSELF, YOUR FAVORITE TEAM OR YOUR FANTASY STYLE."/><small>{bio.length} / 180</small></label></div><div className="privacyNotice"><span>◈</span><p><b>PRIVACY CONTROL</b><br/>ADDRESS AND DATE OF BIRTH WILL NEVER BE SHOWN ON PUBLIC LEADERBOARDS.</p></div><button className="primary" type="submit">SAVE PROFILE CHANGES</button></form>
    </div>

    <section className="accountSafety"><div><span>ACCOUNT & PRIVACY</span><h2>CONTROL YOUR FANTASY MPL DATA.</h2><p>DOWNLOAD A COPY OF YOUR ACCOUNT, OR permanently delete it after password confirmation.</p></div><div className="accountSafetyActions"><button className="secondary" disabled={busy} onClick={exportData}>DOWNLOAD MY DATA</button><button className="dangerButton" disabled={busy} onClick={()=>setDeleteOpen(!deleteOpen)}>DELETE MY ACCOUNT</button></div>{deleteOpen&&<div className="deleteAccountPanel"><h3>PERMANENT ACCOUNT DELETION</h3><p>THIS REMOVES YOUR PROFILE, PREDICTIONS, LINEUPS, MEMBERSHIPS, AVATAR AND ACCOUNT ACCESS. LEAGUES YOU COMMISSION WILL TRANSFER TO THE OLDEST ACTIVE MANAGER WHEN POSSIBLE.</p><label>TYPE YOUR MANAGER NAME<input value={deleteName} onChange={event=>setDeleteName(event.target.value)} placeholder={session.name}/></label><label>CURRENT PASSWORD<input type="password" value={deletePassword} onChange={event=>setDeletePassword(event.target.value)} autoComplete="current-password"/></label><div><button className="secondary" onClick={()=>setDeleteOpen(false)}>CANCEL</button><button className="dangerButton" disabled={busy||!deleteName||!deletePassword} onClick={deleteAccount}>{busy?'PLEASE WAIT…':'PERMANENTLY DELETE ACCOUNT'}</button></div></div>}</section>
  </div>;
}
