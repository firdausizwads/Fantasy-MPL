'use client';

import { FormEvent, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase/client';

type Region = 'MY' | 'ID' | 'PH';
type Session = { name:string; email:string; accountRole:string };
type SubmitClient = { rpc:(name:string,args:Record<string,unknown>)=>Promise<{data:unknown;error:{message:string}|null}> };

const AREA_OPTIONS = ['Dashboard','Predictions','Fantasy Team','Live Draft Lab','Schedule & Standings','Leaderboard','Profile / Account','Mobile layout','Other'];
const TYPE_OPTIONS = ['Bug','Confusing flow','Suggestion','Performance','Data issue','Other'];
const SEVERITY_OPTIONS = ['Low','Medium','High','Critical'];

export default function BetaFeedback({
  region,
  userId,
  session,
  guest,
  onAuth,
  notify,
  PageBanner
}: {
  region: Region;
  userId: string;
  session: Session;
  guest: boolean;
  onAuth: (mode:'register'|'signin') => void;
  notify: (message:string) => void;
  PageBanner: (props:{tag:string;title:string;copy:string;side:React.ReactNode;sideLabel:string})=>React.ReactElement;
}) {
  const [area,setArea]=useState('Mobile layout');
  const [type,setType]=useState('Bug');
  const [severity,setSeverity]=useState('Medium');
  const [title,setTitle]=useState('');
  const [details,setDetails]=useState('');
  const [steps,setSteps]=useState('');
  const [contactAllowed,setContactAllowed]=useState(true);
  const [busy,setBusy]=useState(false);
  const [submitted,setSubmitted]=useState(false);

  const deviceInfo = useMemo(() => {
    if (typeof window === 'undefined') return '';
    return `${window.innerWidth}x${window.innerHeight} · ${navigator.userAgent}`;
  }, []);

  async function submit(event:FormEvent) {
    event.preventDefault();
    if (!supabase || !userId) {
      notify('Please sign in before sending closed beta feedback.');
      return;
    }
    if (title.trim().length < 5) { notify('Add a short feedback title.'); return; }
    if (details.trim().length < 15) { notify('Describe the issue or suggestion with a little more detail.'); return; }
    setBusy(true);
    const client = supabase as unknown as SubmitClient;
    const { error } = await client.rpc('submit_beta_feedback', {
      feedback_region: region,
      feedback_area: area,
      feedback_type: type,
      feedback_severity: severity,
      feedback_title: title.trim(),
      feedback_details: details.trim(),
      feedback_steps: steps.trim() || null,
      feedback_path: typeof window !== 'undefined' ? `${window.location.pathname}${window.location.hash}` : null,
      feedback_device: deviceInfo,
      contact_allowed: contactAllowed
    });
    setBusy(false);
    if (error) { notify(error.message); return; }
    setSubmitted(true);
    setTitle(''); setDetails(''); setSteps('');
    notify('Thank you — your closed beta feedback was sent.');
  }

  return <div className="page betaFeedbackPage">
    <PageBanner
      tag="CLOSED BETA · FEEDBACK"
      title="Help us fix bugs before launch."
      copy="Send bugs, confusing screens, data issues, mobile layout problems or ideas directly to the Fantasy MPL admin queue."
      side="BETA"
      sideLabel="REAL USER FEEDBACK" />

    {guest || !userId ? <section className="panel feedbackSigninGate">
      <span>🔒</span>
      <h2>Sign in to send feedback.</h2>
      <p>Closed beta feedback is linked to your manager account so I can follow up if I need more detail.</p>
      <div><button className="primary" onClick={()=>onAuth('register')}>CREATE FREE ACCOUNT</button><button className="secondary" onClick={()=>onAuth('signin')}>SIGN IN</button></div>
    </section> : <div className="feedbackLayout">
      <form className="panel betaFeedbackForm" onSubmit={submit}>
        <header><span>CLOSED BETA REPORT</span><h2>What should we fix?</h2><p>Be direct. Screenshots are not required, but mention the page and what happened.</p></header>
        <div className="feedbackGrid">
          <label>AREA<select value={area} onChange={event=>setArea(event.target.value)}>{AREA_OPTIONS.map(option=><option key={option}>{option}</option>)}</select></label>
          <label>TYPE<select value={type} onChange={event=>setType(event.target.value)}>{TYPE_OPTIONS.map(option=><option key={option}>{option}</option>)}</select></label>
          <label>SEVERITY<select value={severity} onChange={event=>setSeverity(event.target.value)}>{SEVERITY_OPTIONS.map(option=><option key={option}>{option}</option>)}</select></label>
          <label className="wide">SHORT TITLE<input value={title} onChange={event=>setTitle(event.target.value)} placeholder="Example: Draft preview text overlaps on mobile" maxLength={120}/></label>
          <label className="wide">DETAILS<textarea value={details} onChange={event=>setDetails(event.target.value)} placeholder="What did you see? What did you expect instead?" rows={6}/></label>
          <label className="wide">STEPS TO REPEAT <small>OPTIONAL</small><textarea value={steps} onChange={event=>setSteps(event.target.value)} placeholder="1. Open Live Draft Lab\n2. Scroll to preview\n3. Text overlaps..." rows={4}/></label>
        </div>
        <label className="feedbackConsent"><input type="checkbox" checked={contactAllowed} onChange={event=>setContactAllowed(event.target.checked)}/><span>You may contact me about this feedback if more detail is needed.</span></label>
        <button className="primary" disabled={busy}>{busy?'SENDING FEEDBACK…':'SEND FEEDBACK'}</button>
        {submitted&&<div className="feedbackSuccess">✓ Feedback sent. Thank you for testing the closed beta.</div>}
      </form>
      <aside className="panel feedbackContext">
        <span>MANAGER</span>
        <h3>{session.name}</h3>
        <p>{session.email}</p>
        <dl><div><dt>Region</dt><dd>{region}</dd></div><div><dt>Current path</dt><dd>{typeof window !== 'undefined' ? `${window.location.pathname}${window.location.hash}` : '—'}</dd></div><div><dt>Device</dt><dd>{deviceInfo || '—'}</dd></div></dl>
      </aside>
    </div>}
  </div>;
}
