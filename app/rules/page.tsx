import type { Metadata } from 'next';
import LegalPage from '../_components/legal-page';

export const metadata: Metadata = { title: 'Fantasy and Prediction Rules', description: 'Fantasy MPL scoring, deadlines, and correction rules.' };

export default function RulesPage() {
  return <LegalPage title="Fantasy & Prediction Rules" intro="These rules summarize the current beta scoring model. Versioned regional rule sets will be published before official competition scoring begins." sections={[
    { title: 'Match predictions', items: ['Correct series winner: 30 points.', 'Exact series score: 20 additional points.', 'Configured upset bonus: 5–15 additional points.', 'Perfect regional week: 50 bonus points.'] },
    { title: 'Weekly MVP', paragraphs: ['A correct official regional Weekly MVP selection earns 100 prediction points. The selection locks at the published regional deadline.'] },
    { title: 'Fantasy roster rules', items: ['One EXP, Jungler, Mid, Gold, and Roam player.', 'No more than one player from the same professional team.', 'Captain multiplier applies only where the league rule set enables it.', 'Salary-cap lineups must remain within their configured budget.'] },
    { title: 'Role-based scoring', paragraphs: ['Fantasy scoring may include role-adjusted kills, assists, deaths, victories, objective control, damage, economy, and verified role events. Advanced telemetry metrics activate only after a reliable data source is connected.'] },
    { title: 'Deadlines', paragraphs: ['Server time controls all locks. Browser clocks do not override a closed fixture, lineup, Meta Lab card, H2H ban, or playoff bracket.'] },
    { title: 'Corrections', paragraphs: ['Finalized errors are corrected through an append-only score ledger. Historical transactions remain auditable, with reversing and replacement entries where required.'] },
    { title: 'Tie-breakers', items: ['Total points.', 'Prediction accuracy or configured fantasy metric.', 'Exact-score count.', 'Captain points where applicable.', 'Published league-specific tie-break rules.'] },
    { title: 'Beta notice', paragraphs: ['Sample points, standings, prices and recommendations must not be treated as official until the relevant data is verified and the competition is marked active.'] }
  ]}/>;
}
