import type { Metadata } from 'next';
import LegalPage from '../_components/legal-page';

export const metadata: Metadata = { title: 'Community Guidelines', description: 'Fantasy MPL community, chat, and fair-play standards.' };

export default function CommunityGuidelinesPage() {
  return <LegalPage title="Community Guidelines" intro="Fantasy MPL is built for competitive but respectful regional esports communities. Participation requires fair play and responsible communication." sections={[
    { title: 'Respect other users', items: ['No harassment, hate speech, threats, sexual harassment, or targeted abuse.', 'No insults based on nationality, ethnicity, religion, gender, disability, or identity.', 'Competitive banter must remain non-threatening and respectful.'] },
    { title: 'Protect privacy', items: ['Do not post addresses, phone numbers, passwords, private messages, or identity documents.', 'Do not impersonate players, creators, administrators, teams, or tournament officials.', 'Report suspected account compromise privately to platform support.'] },
    { title: 'Fair competition', items: ['No multi-account manipulation, collusion, bots, automated drafts, or deadline exploits.', 'Do not intentionally abuse scoring, transfer, invite, or chat defects.', 'Report technical issues instead of using them for an advantage.'] },
    { title: 'Chat and league spaces', paragraphs: ['League commissioners and platform moderators may manage community spaces. Platform administrators may remove messages, mute users, preserve moderation records, or suspend accounts when necessary.'] },
    { title: 'Enforcement', items: ['Warning or content removal.', 'Temporary chat mute.', 'League removal.', 'Point reversal.', 'Temporary or permanent account suspension.', 'Escalation where safety or law requires it.'] },
    { title: 'Appeals', paragraphs: ['A transparent moderation and appeal process will be published before full public launch. Serious safety restrictions may remain in place during review.'] }
  ]}/>;
}
