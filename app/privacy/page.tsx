import type { Metadata } from 'next';
import LegalPage from '../_components/legal-page';

export const metadata: Metadata = { title: 'Privacy Policy', description: 'How Fantasy MPL handles account and profile information.' };

const configuredPrivacyEmail = process.env.NEXT_PUBLIC_PRIVACY_EMAIL?.trim();

export default function PrivacyPage() {
  const contact = configuredPrivacyEmail
    ? `For privacy, access, correction or deletion requests, email ${configuredPrivacyEmail}. Do not send passwords, database credentials or recovery codes.`
    : 'A dedicated privacy email must be configured before the full public launch. Until then, do not send personal data, passwords, database credentials or recovery codes through community chat.';

  return <LegalPage title="Privacy Policy" intro="This policy explains what information Fantasy MPL collects, why it is used, and which profile details are public or private." sections={[
    { title: 'Information we collect', items: ['Account email and authentication identifiers through Supabase Auth.', 'Required full name and manager name.', 'Optional profile photo, biography, address and date of birth.', 'Age and guardian confirmation, the accepted terms version and acceptance time.', 'Regional memberships, predictions, fantasy lineups, league activity, chat messages and scoring history.', 'Technical information required for security, reliability and abuse prevention.'] },
    { title: 'Public information', paragraphs: ['Manager name, profile photo, country or regional badge, public biography, fantasy score, ranking and public creator status may be visible to other users.'] },
    { title: 'Private information', paragraphs: ['Full name, email, address, date of birth, age confirmation, authentication credentials and private account records are not displayed on public leaderboards. Access is restricted through Supabase Row Level Security and server-side authorization.'] },
    { title: 'How information is used', items: ['Operate authentication, leagues, predictions, drafts, scoring and moderation.', 'Confirm acceptance of the age, guardian and platform terms required for an account.', 'Prevent fraud, abuse, duplicate rewards and unauthorized access.', 'Improve product performance and user experience.', 'Comply with legal obligations and enforce platform rules.'] },
    { title: 'Young users and guardians', paragraphs: ['Fantasy MPL accounts are for users aged 13 or older. A user who is below the age of legal majority where they live must have a parent or guardian review and approve their use of the service. Fantasy MPL does not knowingly permit accounts for children under 13. A guardian may request review or deletion of a young user’s account through the published privacy contact. Prize campaigns may apply a higher minimum age and separate eligibility checks.'] },
    { title: 'Analytics and service providers', paragraphs: ['Fantasy MPL uses Supabase for authentication, database and storage services, and Vercel for hosting, Analytics and Speed Insights. These providers may process technical and account data in the locations where their infrastructure operates. Analytics must not be configured to collect passwords, addresses, dates of birth, private profile fields, chat contents or prediction selections.'] },
    { title: 'Storage and security', paragraphs: ['No online service is completely risk-free. Fantasy MPL uses HTTPS, access controls, Row Level Security, restricted storage policies, security headers and server-controlled deadlines. Server secrets are not included in browser code.'] },
    { title: 'Retention and deletion', paragraphs: ['Account data is retained while an account remains active and as needed to operate competitions and protect integrity. Users can export their account data or permanently delete their account from My Profile. Deletion removes active account records; limited backup, security, fraud-prevention or legal records may remain for up to 90 days or longer when required by law.'] },
    { title: 'Your choices', paragraphs: ['Users may update profile information, download an account export and permanently delete an account from My Profile. Users may also request access, correction or deletion through the published privacy contact.'] },
    { title: 'Contact', paragraphs: [contact] }
  ]}/>;
}
