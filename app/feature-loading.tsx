'use client';

export default function FeatureLoading({ label = 'Loading feature' }: { label?: string }) {
  return (
    <div className="featureLoading" role="status" aria-live="polite">
      <div className="featureLoadingBar" />
      <div className="featureLoadingGrid">
        <span />
        <span />
        <span />
      </div>
      <p>{label}…</p>
    </div>
  );
}
