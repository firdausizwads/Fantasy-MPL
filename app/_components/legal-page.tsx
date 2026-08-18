import Link from 'next/link';
import styles from './legal-page.module.css';

type Section = { title: string; paragraphs?: string[]; items?: string[] };

export default function LegalPage({ title, intro, sections }: { title: string; intro: string; sections: Section[] }) {
  return (
    <main className={styles.page}>
      <header className={styles.header}>
        <Link href="/" className={styles.brand}>
          <img src="/brand/fantasy-mpl-emblem-display.webp" alt="Fantasy MPL" />
          <span><b>FANTASY MPL</b><small>POLICY CENTER</small></span>
        </Link>
        <Link href="/" className={styles.back}>← RETURN TO FANTASY MPL</Link>
      </header>
      <article className={styles.document}>
        <span className={styles.eyebrow}>FANTASY MPL · LAST UPDATED 18 AUGUST 2026</span>
        <h1>{title}</h1>
        <p className={styles.intro}>{intro}</p>
        {sections.map(section => (
          <section key={section.title}>
            <h2>{section.title}</h2>
            {section.paragraphs?.map(paragraph => <p key={paragraph}>{paragraph}</p>)}
            {section.items && <ul>{section.items.map(item => <li key={item}>{item}</li>)}</ul>}
          </section>
        ))}
      </article>
      <footer className={styles.footer}>
        <span>FANTASY MPL IS AN INDEPENDENT COMMUNITY PROJECT.</span>
        <nav><Link href="/privacy">PRIVACY</Link><Link href="/terms">TERMS</Link><Link href="/rules">RULES</Link><Link href="/community-guidelines">COMMUNITY</Link></nav>
      </footer>
    </main>
  );
}
