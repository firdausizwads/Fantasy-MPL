import type { Metadata } from 'next';
import LegalPage from '../_components/legal-page';

export const metadata: Metadata = { title: 'Privacy Policy', description: 'How Fantasy MPL handles account and profile information.' };

export default function PrivacyPage() {
  return <LegalPage title="Privacy Policy" intro="This policy explains what information Fantasy MPL collects, why it is used, and which profile details are public or private." sections={[
    { title: 'Information we collect', items: ['Account email and authentication identifiers through Supabase Auth.', 'Required full name and manager name.', 'Optional profile photo, biography, address, and date of birth.', 'Regional memberships, predictions, fantasy lineups, league activity, chat messages, and scoring history.', 'Technical information required for security, reliability, and abuse prevention.'] },
    { title: 'Public information', paragraphs: ['Manager name, profile photo, country or regional badge, public biography, fantasy score, ranking, and public creator status may be visible to other users.'] },
    { title: 'Private information', paragraphs: ['Full name, address, date of birth, authentication credentials, and private account records are not displayed on public leaderboards. Access is restricted through Supabase Row Level Security.'] },
    { title: 'How information is used', items: ['Operate authentication, leagues, predictions, drafts, scoring, and moderation.', 'Prevent fraud, abuse, duplicate rewards, and unauthorized access.', 'Improve product performance and user experience.', 'Comply with legal obligations and enforce platform rules.'] },
    { title: 'Storage and security', paragraphs: ['Data is stored using Supabase infrastructure. No online service is completely risk-free, but Fantasy MPL uses access controls, Row Level Security, HTTPS, restricted storage policies, and server-controlled deadlines.'] },
    { title: 'Your choices', paragraphs: ['Users may update profile information from My Profile. Requests for account deletion, data access, or correction will be supported before the full public launch.'] },
    { title: 'Contact', paragraphs: ['A dedicated privacy contact address will be published before public launch. Do not send passwords, database credentials, or recovery codes through community chat.'] }
  ]}/>;
}
