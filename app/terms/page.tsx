import type { Metadata } from 'next';
import LegalPage from '../_components/legal-page';

export const metadata: Metadata = { title: 'Terms of Service', description: 'Terms for using Fantasy MPL.' };

export default function TermsPage() {
  return <LegalPage title="Terms of Service" intro="By creating an account or using Fantasy MPL, you agree to follow these terms and all published competition rules." sections={[
    { title: 'Independent community platform', paragraphs: ['Fantasy MPL is an independent fantasy and prediction project. It is not an official MPL, MLBB, MOONTON, team, or tournament service unless a future written partnership explicitly states otherwise.'] },
    { title: 'Account responsibilities', items: ['Provide accurate required registration information.', 'Keep passwords and recovery methods secure.', 'Do not share, sell, automate, or impersonate accounts.', 'Do not attempt to bypass deadlines, scoring rules, moderation, or access controls.'] },
    { title: 'Fair play', paragraphs: ['Multi-account abuse, collusion, automated entries, manipulation, harassment, and exploitation of technical errors are prohibited. Fantasy MPL may reverse points or suspend accounts where integrity is affected.'] },
    { title: 'Predictions and scoring', paragraphs: ['Deadlines and results are controlled by server time and verified data. Corrections may create reversing score transactions. Displayed demo values do not create an entitlement to points or rewards.'] },
    { title: 'Prizes and Fantasy Dust', paragraphs: ['No prize is guaranteed until an official campaign publishes funding, eligibility, territories, dates, and rules. Fantasy Dust is non-transferable, cannot be purchased, has no cash value, and is not redeemable for cash.'] },
    { title: 'Intellectual property', paragraphs: ['MPL, MLBB, team marks, player images, and related assets belong to their respective owners. Fantasy MPL branding and original interface work may not be copied or misrepresented.'] },
    { title: 'Availability and changes', paragraphs: ['Features may change, pause, or be removed during beta. Reasonable efforts will be made to protect data and competition integrity, but uninterrupted service is not guaranteed.'] },
    { title: 'Age and legal eligibility', paragraphs: ['Age limits and territory requirements will be finalized before prize-supported competitions launch. Users must comply with the laws applicable in their location.'] }
  ]}/>;
}
