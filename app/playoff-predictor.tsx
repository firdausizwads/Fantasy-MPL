"use client";
import { useEffect, useState } from "react";
import type { ComponentType, ReactNode } from "react";
type Region = "MY" | "ID" | "PH";
export type PlayoffTeam = { code: string; name: string; logo: string };
type PageBannerProps = {
  tag: string;
  title: string;
  copy: string;
  side: ReactNode;
  sideLabel: string;
};
const REGION_INFO: Record<Region, { name: string; logo: string }> = {
  MY: { name: "MPL Malaysia", logo: "/leagues/display/mpl-my.webp" },
  ID: { name: "MPL Indonesia", logo: "/leagues/display/mpl-id.webp" },
  PH: { name: "MPL Philippines", logo: "/leagues/display/mpl-ph.webp" },
};
function roundRect(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  w: number,
  h: number,
  r: number,
) {
  ctx.beginPath();
  if (typeof ctx.roundRect === "function") {
    ctx.roundRect(x, y, w, h, r);
  } else {
    const radius = Math.min(r, w / 2, h / 2);
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + w - radius, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + radius);
    ctx.lineTo(x + w, y + h - radius);
    ctx.quadraticCurveTo(x + w, y + h, x + w - radius, y + h);
    ctx.lineTo(x + radius, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
  }
}
function drawImageContain(
  ctx: CanvasRenderingContext2D,
  image: HTMLImageElement,
  x: number,
  y: number,
  w: number,
  h: number,
) {
  const ratio = Math.min(w / image.width, h / image.height),
    dw = image.width * ratio,
    dh = image.height * ratio;
  ctx.drawImage(image, x + (w - dw) / 2, y + (h - dh) / 2, dw, dh);
}
type BracketPick = { winner?: string; score?: string };
type PlayoffAccess = {
  state: "pending" | "countdown" | "open";
  open: boolean;
  opens_at: string | null;
  playoff_starts_at: string | null;
  regular_matches: number;
  completed_regular_matches: number;
  server_now: string;
};
type Countdown = {
  days: string;
  hours: string;
  minutes: string;
  seconds: string;
  compact: string;
};
const EMPTY_ACCESS: PlayoffAccess = {
  state: "pending",
  open: false,
  opens_at: null,
  playoff_starts_at: null,
  regular_matches: 0,
  completed_regular_matches: 0,
  server_now: new Date(0).toISOString(),
};
function countdownUntil(target: string | null, now: number): Countdown {
  if (!target)
    return {
      days: "--",
      hours: "--",
      minutes: "--",
      seconds: "--",
      compact: "DATE PENDING",
    };
  const remaining = Math.max(0, new Date(target).getTime() - now);
  const days = Math.floor(remaining / 86400000);
  const hours = Math.floor((remaining % 86400000) / 3600000);
  const minutes = Math.floor((remaining % 3600000) / 60000);
  const seconds = Math.floor((remaining % 60000) / 1000);
  return {
    days: String(days).padStart(2, "0"),
    hours: String(hours).padStart(2, "0"),
    minutes: String(minutes).padStart(2, "0"),
    seconds: String(seconds).padStart(2, "0"),
    compact: days > 0 ? `${days}D ${hours}H` : `${hours}H ${minutes}M`,
  };
}
const PLAYOFF_MATCHES = [
  { id: "P1", label: "PLAY-IN 1", round: "PLAY-INS", bestOf: 5 },
  { id: "P2", label: "PLAY-IN 2", round: "PLAY-INS", bestOf: 5 },
  { id: "U1", label: "UPPER SEMIFINAL 1", round: "UPPER SEMIS", bestOf: 5 },
  { id: "U2", label: "UPPER SEMIFINAL 2", round: "UPPER SEMIS", bestOf: 5 },
  { id: "UF", label: "UPPER FINAL", round: "FINALS PATH", bestOf: 5 },
  { id: "LS", label: "LOWER SEMIFINAL", round: "FINALS PATH", bestOf: 5 },
  { id: "LF", label: "LOWER FINAL", round: "LOWER FINAL", bestOf: 7 },
  { id: "GF", label: "GRAND FINAL", round: "GRAND FINAL", bestOf: 7 },
] as const;
export default function PlayoffPredictor({
  region,
  notify,
  teams,
  teamIndex,
  PageBanner,
}: {
  region: Region;
  notify: (s: string) => void;
  teams: PlayoffTeam[];
  teamIndex: Record<string, { name: string; logo: string }>;
  PageBanner: ComponentType<PageBannerProps>;
}) {
  const [mode, setMode] = useState<"custom" | "official">("custom");
  const [customSeeds, setCustomSeeds] = useState<string[]>(
    teams.slice(0, 6).map((team) => team.code),
  );
  const initialSeeds = teams.slice(0, 6).map((team) => team.code);
  const [access, setAccess] = useState<PlayoffAccess>(EMPTY_ACCESS);
  const [serverOffset, setServerOffset] = useState(0);
  const [clock, setClock] = useState(() => Date.now());
  const serverNow = clock + serverOffset;
  const officialOpen =
    Boolean(access.opens_at) &&
    serverNow >= new Date(access.opens_at!).getTime();
  const countdown = countdownUntil(access.opens_at, serverNow);
  const bracketTeams =
    mode === "custom"
      ? customSeeds
          .map((code) => teams.find((team) => team.code === code))
          .filter((team): team is PlayoffTeam => Boolean(team))
      : teams.slice(0, 6);
  const seeds: Record<number, string> = Object.fromEntries(
    bracketTeams.map((t, i) => [i + 1, t.code]),
  );
  const storage = `fmpl_playoffs_${region}_${mode}`;
  const [picks, setPicks] = useState<Record<string, BracketPick>>({});
  const [submitted, setSubmitted] = useState(false);
  const officialLocked = mode === "official" && submitted;
  useEffect(() => {
    setCustomSeeds(teams.slice(0, 6).map((team) => team.code));
  }, [region, teams]);
  useEffect(() => {
    try {
      const raw = localStorage.getItem(storage);
      if (raw) {
        const value = JSON.parse(raw);
        setPicks(value.picks || {});
        if (
          mode === "custom" &&
          Array.isArray(value.seeds) &&
          value.seeds.length === 6
        ) {
          setCustomSeeds(value.seeds);
        }
        setSubmitted(mode === "official" && Boolean(value.submitted));
      } else {
        setPicks({});
        setSubmitted(false);
      }
    } catch {}
  }, [region, mode]);
  useEffect(() => {
    const timer = window.setInterval(() => setClock(Date.now()), 1000);
    return () => window.clearInterval(timer);
  }, []);
  useEffect(() => {
    let active = true;
    async function loadAccess() {
      try {
        const response = await fetch(`/api/playoff-access?region=${region}`);
        if (!response.ok) throw new Error("Playoff access status unavailable");
        const value = (await response.json()) as PlayoffAccess;
        if (!active) return;
        setAccess(value);
        setServerOffset(new Date(value.server_now).getTime() - Date.now());
      } catch {
        if (active) setAccess(EMPTY_ACCESS);
      }
    }
    loadAccess();
    const refresh = window.setInterval(loadAccess, 60000);
    return () => {
      active = false;
      window.clearInterval(refresh);
    };
  }, [region]);
  const winner = (id: string) => picks[id]?.winner;
  const participants = (id: string): Array<string | undefined> => {
    const loser = (match: string) => {
      const pair = participants(match),
        win = winner(match);
      return win ? pair.find((x) => x && x !== win) : undefined;
    };
    switch (id) {
      case "P1":
        return [seeds[3], seeds[6]];
      case "P2":
        return [seeds[4], seeds[5]];
      case "U1":
        return [seeds[1], winner("P2")];
      case "U2":
        return [seeds[2], winner("P1")];
      case "UF":
        return [winner("U1"), winner("U2")];
      case "LS":
        return [loser("U1"), loser("U2")];
      case "LF":
        return [loser("UF"), winner("LS")];
      case "GF":
        return [winner("UF"), winner("LF")];
      default:
        return [];
    }
  };
  function choose(id: string, team: string) {
    if (officialLocked) return;
    const index = PLAYOFF_MATCHES.findIndex((m) => m.id === id);
    const next = {
      ...picks,
      [id]: {
        winner: team,
        score: picks[id]?.winner === team ? picks[id]?.score : undefined,
      },
    };
    PLAYOFF_MATCHES.slice(index + 1).forEach((m) => delete next[m.id]);
    setPicks(next);
  }
  function score(id: string, value: string) {
    if (officialLocked) return;
    setPicks({ ...picks, [id]: { ...picks[id], score: value } });
  }
  function save(lock = false) {
    const shouldLock = mode === "official" && lock;
    localStorage.setItem(
      storage,
      JSON.stringify({
        picks,
        submitted: shouldLock,
        seeds: mode === "custom" ? customSeeds : undefined,
      }),
    );
    setSubmitted(shouldLock);
    notify(
      shouldLock
        ? "Official playoff prediction locked."
        : mode === "custom"
          ? "Custom bracket saved — keep editing whenever you like."
          : "Official prediction draft saved.",
    );
  }
  function changeSeed(index: number, code: string) {
    setCustomSeeds((current) => {
      const next = [...current];
      const other = next.indexOf(code);
      if (other >= 0) [next[index], next[other]] = [next[other], next[index]];
      else next[index] = code;
      return next;
    });
    setPicks({});
    setSubmitted(false);
  }
  function resetSeeds() {
    setCustomSeeds(initialSeeds);
    setPicks({});
    setSubmitted(false);
    localStorage.removeItem(`fmpl_playoffs_${region}_custom`);
    notify("Custom seeds reset to the regional team order.");
  }
  const complete = PLAYOFF_MATCHES.every(
    (m) => picks[m.id]?.winner && picks[m.id]?.score,
  );
  const champion = winner("GF");
  const champ = bracketTeams.find((t) => t.code === champion);
  async function exportBracket() {
    const canvas = document.createElement("canvas");
    canvas.width = 1920;
    canvas.height = 1080;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;
    const load = (src: string) =>
      new Promise<HTMLImageElement | null>((resolve) => {
        const image = new Image();
        image.onload = () => resolve(image);
        image.onerror = () => resolve(null);
        image.src = src;
      });
    const [leagueLogo, brandLogo] = await Promise.all([
      load(REGION_INFO[region].logo),
      load("/brand/fantasy-mpl-emblem-display.webp"),
    ]);
    const loadedTeamLogos = await Promise.all(
      bracketTeams.map((team) => load(team.logo)),
    );
    const teamLogoMap: Record<string, HTMLImageElement> = {};
    bracketTeams.forEach((team, index) => {
      const image = loadedTeamLogos[index];
      if (image) teamLogoMap[team.code] = image;
    });
    const colors: Record<Region, [string, string, string]> = {
      MY: ["#061a3c", "#1257aa", "#f2c633"],
      ID: ["#240b13", "#9e2031", "#ff6979"],
      PH: ["#081a36", "#175fb7", "#f3b826"],
    };
    const [dark, mid, accent] = colors[region];
    const gradient = ctx.createLinearGradient(0, 0, 1920, 1080);
    gradient.addColorStop(0, dark);
    gradient.addColorStop(0.62, mid);
    gradient.addColorStop(1, dark);
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 1920, 1080);
    ctx.globalAlpha = 0.08;
    ctx.strokeStyle = "#fff";
    ctx.lineWidth = 1;
    for (let x = -500; x < 2200; x += 90) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x + 700, 1080);
      ctx.stroke();
    }
    ctx.globalAlpha = 1;
    const glow = ctx.createRadialGradient(1500, 200, 10, 1500, 200, 520);
    glow.addColorStop(0, accent + "55");
    glow.addColorStop(1, "transparent");
    ctx.fillStyle = glow;
    ctx.fillRect(900, 0, 1020, 800);
    if (brandLogo) ctx.drawImage(brandLogo, 66, 48, 75, 75);
    ctx.fillStyle = "#fff";
    ctx.font = "800 44px Arial";
    ctx.fillText("FANTASY MPL", 155, 84);
    ctx.fillStyle = "rgba(255,255,255,.6)";
    ctx.font = "700 16px Arial";
    ctx.fillText("PLAYOFF BRACKET PREDICTION", 157, 112);
    if (leagueLogo) {
      const ratio = leagueLogo.width / leagueLogo.height;
      const h = 105,
        w = h * ratio;
      ctx.drawImage(leagueLogo, 1810 - w, 35, w, h);
    }
    ctx.textAlign = "right";
    ctx.fillStyle = accent;
    ctx.font = "800 19px Arial";
    ctx.fillText(REGION_INFO[region].name.toUpperCase(), 1805, 163);
    ctx.textAlign = "left";
    ctx.fillStyle = "#fff";
    ctx.font = "800 32px Arial";
    ctx.fillText("ROAD TO THE GRAND FINAL", 66, 193);
    ctx.fillStyle = "rgba(255,255,255,.58)";
    ctx.font = "600 14px Arial";
    ctx.fillText("SEASON 18 · FULL BRACKET · 1920 × 1080", 68, 220);
    const stages = [
      { title: "01 · PLAY-IN", ids: ["P1", "P2"] },
      { title: "02 · UPPER & LOWER BRACKET", ids: ["U1", "U2", "LS"] },
      { title: "03 · UPPER & LOWER FINALS", ids: ["UF", "LF"] },
      { title: "04 · GRAND FINAL", ids: ["GF"] },
    ];
    const colW = 425,
      gap = 25,
      startX = 65;
    stages.forEach((stage, col) => {
      const x = startX + col * (colW + gap);
      ctx.fillStyle = "rgba(255,255,255,.08)";
      roundRect(ctx, x, 252, colW, 690, 16);
      ctx.fill();
      ctx.strokeStyle = "rgba(255,255,255,.13)";
      ctx.stroke();
      ctx.fillStyle = accent;
      ctx.font = "800 16px Arial";
      ctx.fillText(stage.title, x + 20, 287);
      ctx.fillStyle = "rgba(255,255,255,.43)";
      ctx.font = "600 11px Arial";
      ctx.fillText(
        col === 0
          ? "SEEDS 3–6 · ELIMINATION"
          : col === 1
            ? "DOUBLE-ELIMINATION PATH"
            : col === 2
              ? "WINNERS REACH THE TITLE MATCH"
              : "CHAMPIONSHIP SERIES",
        x + 20,
        308,
      );
      const availableH = 590;
      const cardH =
        stage.ids.length === 3 ? 175 : stage.ids.length === 2 ? 225 : 275;
      const cardGap =
        (availableH - stage.ids.length * cardH) / (stage.ids.length + 1);
      stage.ids.forEach((id, row) => {
        const y = 322 + cardGap * (row + 1) + cardH * row;
        ctx.fillStyle = "rgba(5,12,22,.56)";
        roundRect(ctx, x + 18, y, colW - 36, cardH, 11);
        ctx.fill();
        ctx.strokeStyle = "rgba(255,255,255,.14)";
        ctx.stroke();
        const def = PLAYOFF_MATCHES.find((m) => m.id === id)!;
        ctx.fillStyle = accent;
        ctx.font = "800 11px Arial";
        ctx.fillText(`${def.label} · BO${def.bestOf}`, x + 35, y + 27);
        const pair = participants(id);
        pair.forEach((code, i) => {
          const team = code ? teamIndex[code] : undefined;
          const rowY = y + 48 + i * 49;
          ctx.fillStyle =
            picks[id]?.winner === code
              ? "rgba(255,255,255,.17)"
              : "rgba(255,255,255,.065)";
          roundRect(ctx, x + 31, rowY, colW - 62, 39, 7);
          ctx.fill();
          ctx.fillStyle = "#fff";
          ctx.font = "700 12px Arial";
          if (code && teamLogoMap[code])
            drawImageContain(ctx, teamLogoMap[code], x + 42, rowY + 5, 29, 29);
          ctx.fillText(
            team?.name || "TO BE DECIDED",
            x + (team ? 82 : 44),
            rowY + 25,
          );
          if (picks[id]?.winner === code) {
            ctx.fillStyle = accent;
            ctx.font = "800 13px Arial";
            ctx.fillText("✓", x + colW - 52, rowY + 25);
          }
        });
        ctx.strokeStyle = "rgba(255,255,255,.11)";
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(x + 31, y + cardH - 39);
        ctx.lineTo(x + colW - 31, y + cardH - 39);
        ctx.stroke();
        ctx.fillStyle = "rgba(255,255,255,.035)";
        roundRect(ctx, x + 31, y + cardH - 33, colW - 62, 24, 5);
        ctx.fill();
        ctx.fillStyle = "rgba(255,255,255,.7)";
        ctx.font = "700 10px Arial";
        ctx.fillText(`EXACT SCORE`, x + 43, y + cardH - 16);
        ctx.textAlign = "right";
        ctx.fillStyle = accent;
        ctx.font = "800 12px Arial";
        ctx.fillText(picks[id]?.score || "—", x + colW - 43, y + cardH - 16);
        ctx.textAlign = "left";
      });
      if (col < 3) {
        ctx.strokeStyle = accent;
        ctx.lineWidth = 2;
        ctx.globalAlpha = 0.7;
        ctx.beginPath();
        ctx.moveTo(x + colW, 595);
        ctx.lineTo(x + colW + gap, 595);
        ctx.stroke();
        ctx.globalAlpha = 1;
      }
    });
    ctx.fillStyle = "rgba(5,12,22,.78)";
    roundRect(ctx, 1375, 950, 480, 94, 12);
    ctx.fill();
    ctx.strokeStyle = accent;
    ctx.stroke();
    if (champ && teamLogoMap[champ.code])
      drawImageContain(ctx, teamLogoMap[champ.code], 1395, 965, 58, 58);
    ctx.fillStyle = accent;
    ctx.font = "800 11px Arial";
    ctx.fillText(
      `PREDICTED ${REGION_INFO[region].name.toUpperCase()} CHAMPION`,
      1470,
      981,
    );
    ctx.fillStyle = "#fff";
    ctx.font = "800 24px Arial";
    ctx.fillText(champ?.name || "NOT SELECTED", 1470, 1017);
    ctx.fillStyle = "rgba(255,255,255,.48)";
    ctx.font = "600 11px Arial";
    ctx.fillText("CREATED WITH FANTASY MPL", 67, 1020);
    canvas.toBlob((blob) => {
      if (!blob) return;
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = `fantasy-mpl-${region.toLowerCase()}-playoff-bracket.png`;
      a.click();
      setTimeout(() => URL.revokeObjectURL(a.href), 1000);
    }, "image/png");
  }
  const modeNav = (
    <div className="playoffModeTabs" aria-label="Playoff bracket mode">
      <button
        className={mode === "custom" ? "active" : ""}
        onClick={() => setMode("custom")}
      >
        <span className="modeTabIcon">✦</span>
        <span>
          <b>CUSTOM BRACKET</b>
          <small>CREATE · EDIT · EXPORT ANYTIME</small>
        </span>
        <em className="modeStatus open">ALWAYS OPEN</em>
      </button>
      <button
        className={mode === "official" ? "active" : ""}
        onClick={() => setMode("official")}
      >
        <span className="modeTabIcon">◷</span>
        <span>
          <b>OFFICIAL PREDICTOR</b>
          <small>
            {officialOpen
              ? "OFFICIAL ENTRY WINDOW AVAILABLE"
              : "OPENS AFTER REGULAR SEASON"}
          </small>
        </span>
        <em className={`modeStatus ${officialOpen ? "open" : "locked"}`}>
          {officialOpen ? "OPEN NOW" : countdown.compact}
        </em>
      </button>
    </div>
  );
  if (mode === "official" && !officialOpen)
    return (
      <div className="page playoffPage playoffV2">
        <PageBanner
          tag={`${REGION_INFO[region].name.toUpperCase()} · OFFICIAL PLAYOFFS`}
          title="Official Predictor Opens Soon"
          copy="The official entry window opens when the final regular-season series window has ended."
          side={countdown.compact}
          sideLabel="OFFICIAL UNLOCK"
        />
        {modeNav}
        <section className="officialPlayoffGate officialCountdownGate">
          <div className="officialGateMark">
            <img src={REGION_INFO[region].logo} alt="" />
            <i />
          </div>
          <span>REGULAR SEASON · FINAL COUNTDOWN</span>
          <h2>The official bracket unlocks at zero.</h2>
          <p>
            Official prediction locking applies only here. Your Custom Bracket
            remains available to create, edit, save and export at any time.
          </p>
          <div
            className="playoffCountdown"
            aria-label={`Official predictor opens in ${countdown.compact}`}
          >
            <div>
              <b>{countdown.days}</b>
              <small>DAYS</small>
            </div>
            <i>:</i>
            <div>
              <b>{countdown.hours}</b>
              <small>HOURS</small>
            </div>
            <i>:</i>
            <div>
              <b>{countdown.minutes}</b>
              <small>MINUTES</small>
            </div>
            <i>:</i>
            <div>
              <b>{countdown.seconds}</b>
              <small>SECONDS</small>
            </div>
          </div>
          <div className="officialGateMeta">
            <span>
              <b>
                {access.completed_regular_matches} / {access.regular_matches}
              </b>
              <small>REGULAR-SEASON RESULTS COMPLETE</small>
            </span>
            <span>
              <b>
                {access.playoff_starts_at
                  ? new Date(access.playoff_starts_at).toLocaleDateString()
                  : "DATE PENDING"}
              </b>
              <small>FIRST IMPORTED PLAYOFF SERIES</small>
            </span>
          </div>
          <button onClick={() => setMode("custom")}>
            BUILD A CUSTOM BRACKET NOW →
          </button>
        </section>
      </div>
    );
  return (
    <div className="page playoffPage playoffV2">
      <PageBanner
        tag={`${REGION_INFO[region].name.toUpperCase()} · ${mode === "custom" ? "CUSTOM PLAYGROUND" : "OFFICIAL PLAYOFFS"}`}
        title="Road to the Grand Final"
        copy={
          mode === "custom"
            ? "Build your own six-team seeding, change it anytime and share your dream bracket."
            : "Predict every official winner and exact series score before the entry lock."
        }
        side={officialLocked ? "LOCKED" : `${Object.keys(picks).length} / 8`}
        sideLabel={officialLocked ? "OFFICIAL STATUS" : "SERIES PREDICTED"}
      />
      {modeNav}
      {mode === "custom" && (
        <section className="customSeedPanel seedStudio">
          <header>
            <div>
              <span>CUSTOM SEED STUDIO</span>
              <h2>Choose your six seeds</h2>
              <p>
                Pick any six regional teams. Selecting a team already in the
                bracket swaps its position, so every seed stays unique.
              </p>
            </div>
            <aside>
              <span>
                <b>6</b> UNIQUE TEAMS
              </span>
              <button type="button" onClick={resetSeeds}>
                RESET SEEDS
              </button>
            </aside>
          </header>
          <div className="seedPickerGrid">
            {customSeeds.map((code, index) => {
              const selectedTeam = teams.find((team) => team.code === code);
              return (
                <label className="seedPickerCard" key={index}>
                  <span className="seedNumber">
                    {String(index + 1).padStart(2, "0")}
                  </span>
                  <span className="seedTeamIdentity">
                    {selectedTeam && <img src={selectedTeam.logo} alt="" />}
                    <span>
                      <b>{selectedTeam?.name || "CHOOSE TEAM"}</b>
                      <small>{selectedTeam?.code || "—"}</small>
                    </span>
                  </span>
                  <span className="seedRoute">
                    {index < 2 ? "UPPER SEMIFINAL" : "PLAY-IN"}
                  </span>
                  <select
                    aria-label={`Seed ${index + 1}`}
                    value={code}
                    onChange={(event) => changeSeed(index, event.target.value)}
                  >
                    {teams.map((team) => (
                      <option value={team.code} key={team.code}>
                        {team.name}
                      </option>
                    ))}
                  </select>
                </label>
              );
            })}
          </div>
          <footer>
            <i>∞</i>
            <p>
              <b>YOUR BRACKET NEVER LOCKS.</b>
              <small>
                COME BACK TO CHANGE SEEDS, WINNERS OR SCORES WHENEVER YOU WANT.
              </small>
            </p>
          </footer>
        </section>
      )}
      <div className="playoffScoreRules">
        <div>
          <strong>+40</strong>
          <span>SERIES WINNER</span>
        </div>
        <div>
          <strong>+25</strong>
          <span>EXACT SCORE</span>
        </div>
        <div>
          <strong>+75</strong>
          <span>EACH FINALIST</span>
        </div>
        <div>
          <strong>+150</strong>
          <span>CHAMPION</span>
        </div>
        <div>
          <strong>+250</strong>
          <span>PERFECT BRACKET</span>
        </div>
      </div>
      <div className="bracketScroll">
        <div className="bracketGrid playoffBracketV2">
          <BracketColumn
            title="01 · PLAY-IN"
            subtitle="SEEDS 3–6 · ELIMINATION"
          >
            <BracketMatch
              teamIndex={teamIndex}
              match={PLAYOFF_MATCHES[0]}
              teams={participants("P1")}
              picks={picks}
              choose={choose}
              score={score}
              locked={officialLocked}
            />
            <BracketMatch
              teamIndex={teamIndex}
              match={PLAYOFF_MATCHES[1]}
              teams={participants("P2")}
              picks={picks}
              choose={choose}
              score={score}
              locked={officialLocked}
            />
          </BracketColumn>
          <BracketColumn
            title="02 · UPPER & LOWER BRACKET"
            subtitle="DOUBLE-ELIMINATION PATH"
          >
            <BracketMatch
              teamIndex={teamIndex}
              match={PLAYOFF_MATCHES[2]}
              teams={participants("U1")}
              picks={picks}
              choose={choose}
              score={score}
              locked={officialLocked}
            />
            <BracketMatch
              teamIndex={teamIndex}
              match={PLAYOFF_MATCHES[3]}
              teams={participants("U2")}
              picks={picks}
              choose={choose}
              score={score}
              locked={officialLocked}
            />
            <BracketMatch
              teamIndex={teamIndex}
              match={PLAYOFF_MATCHES[5]}
              teams={participants("LS")}
              picks={picks}
              choose={choose}
              score={score}
              locked={officialLocked}
            />
          </BracketColumn>
          <BracketColumn
            title="03 · UPPER & LOWER FINALS"
            subtitle="WINNERS REACH THE TITLE MATCH"
          >
            <BracketMatch
              teamIndex={teamIndex}
              match={PLAYOFF_MATCHES[4]}
              teams={participants("UF")}
              picks={picks}
              choose={choose}
              score={score}
              locked={officialLocked}
            />
            <BracketMatch
              teamIndex={teamIndex}
              match={PLAYOFF_MATCHES[6]}
              teams={participants("LF")}
              picks={picks}
              choose={choose}
              score={score}
              locked={officialLocked}
            />
          </BracketColumn>
          <BracketColumn
            title="04 · GRAND FINAL"
            subtitle="BEST OF 7 · CHAMPIONSHIP"
          >
            <BracketMatch
              teamIndex={teamIndex}
              match={PLAYOFF_MATCHES[7]}
              teams={participants("GF")}
              picks={picks}
              choose={choose}
              score={score}
              locked={officialLocked}
            />
            {champ && (
              <div className="predictedChampion">
                <span>
                  PREDICTED {REGION_INFO[region].name.toUpperCase()} CHAMPION
                </span>
                <img src={champ.logo} alt={`${champ.name} logo`} />
                <strong>{champ.name}</strong>
              </div>
            )}
          </BracketColumn>
        </div>
      </div>
      <section className="seedingSummary">
        <div className="seedingSummaryHead">
          <div>
            <span>
              {mode === "custom" ? "YOUR SIX-SEED PREVIEW" : "OFFICIAL SEEDING"}
            </span>
            <h2>
              {mode === "custom"
                ? "The bracket you imagined"
                : "Regional playoff order"}
            </h2>
          </div>
          <p>
            {mode === "custom"
              ? "This is your personal sandbox seeding. It stays editable and does not affect the official competition."
              : "Official seeds become the fixed entry order for the prediction challenge."}
          </p>
        </div>
        <div className="seedingSummaryGrid">
          {bracketTeams.map((team, index) => (
            <article key={team.code}>
              <span>{index + 1}</span>
              <img src={team.logo} alt="" />
              <div>
                <b>{team.name}</b>
                <small>{index < 2 ? "UPPER SEMIFINAL" : "PLAY-IN"}</small>
              </div>
            </article>
          ))}
        </div>
        <div className="seedingSummaryActions">
          <div>
            <b>SHARE YOUR BRACKET</b>
            <small>EXPORT A CLEAN 1920 × 1080 PNG CARD.</small>
          </div>
          <button onClick={exportBracket}>
            <span>↓</span>
            <div>
              <strong>EXPORT BRACKET CARD</strong>
              <small>PNG · 1920 × 1080</small>
            </div>
          </button>
        </div>
      </section>
      <div
        className={`bracketFooter ${mode === "custom" ? "customFooter" : "officialFooter"}`}
      >
        <div>
          <span className={complete ? "complete" : "incomplete"}>
            {complete ? "✓" : "!"}
          </span>
          <p>
            <b>
              {complete
                ? "BRACKET COMPLETE"
                : mode === "custom"
                  ? "KEEP BUILDING YOUR BRACKET"
                  : "OFFICIAL PREDICTION INCOMPLETE"}
            </b>
            <small>
              {complete
                ? mode === "custom"
                  ? "SAVE IT, SHARE IT OR KEEP CHANGING IT — YOUR CUSTOM BRACKET NEVER LOCKS."
                  : "EVERY OFFICIAL SERIES HAS A WINNER AND EXACT SCORE."
                : mode === "custom"
                  ? "YOU CAN SAVE NOW AND RETURN ANYTIME TO FINISH OR CHANGE IT."
                  : "COMPLETE ALL EIGHT SERIES AND SCORES BEFORE LOCKING YOUR OFFICIAL ENTRY."}
            </small>
          </p>
        </div>
        <div>
          <button
            className="secondary"
            disabled={officialLocked}
            onClick={() => save(false)}
          >
            {mode === "custom"
              ? "SAVE CUSTOM BRACKET"
              : officialLocked
                ? "ENTRY SAVED"
                : "SAVE OFFICIAL DRAFT"}
          </button>
          {mode === "custom" ? (
            <button className="primary" onClick={exportBracket}>
              EXPORT & SHARE
            </button>
          ) : (
            <button
              className="primary"
              disabled={!complete || officialLocked}
              onClick={() => save(true)}
            >
              {officialLocked
                ? "✓ OFFICIAL PREDICTION LOCKED"
                : "LOCK OFFICIAL PREDICTION"}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
function BracketColumn({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle: string;
  children: ReactNode;
}) {
  return (
    <section className="bracketColumn">
      <div className="bracketColumnHead">
        <h2>{title}</h2>
        <p>{subtitle}</p>
      </div>
      <div className="bracketMatches">{children}</div>
    </section>
  );
}
function BracketMatch({
  match,
  teams,
  picks,
  choose,
  score,
  locked,
  teamIndex,
}: {
  teamIndex: Record<string, { name: string; logo: string }>;
  match: (typeof PLAYOFF_MATCHES)[number];
  teams: Array<string | undefined>;
  picks: Record<string, BracketPick>;
  choose: (id: string, t: string) => void;
  score: (id: string, v: string) => void;
  locked: boolean;
}) {
  const pick = picks[match.id] || {};
  const options =
    match.bestOf === 7 ? ["4–0", "4–1", "4–2", "4–3"] : ["3–0", "3–1", "3–2"];
  return (
    <article className={`bracketMatch ${pick.winner ? "hasPick" : ""}`}>
      <div className="bracketMatchHead">
        <span>{match.label}</span>
        <b>BO{match.bestOf}</b>
      </div>
      {teams.map((code, i) => {
        const team = code ? teamIndex[code] : undefined;
        return (
          <button
            key={i}
            disabled={!team || locked}
            className={pick.winner === code ? "winner" : ""}
            onClick={() => team && choose(match.id, code!)}
          >
            {team ? (
              <>
                <img src={team.logo} alt={`${team.name} logo`} />
                <span>
                  <b>{team.name}</b>
                  <small>
                    {pick.winner === code ? "ADVANCES" : "SELECT WINNER"}
                  </small>
                </span>
                <i>{pick.winner === code ? "✓" : `#${i + 1}`}</i>
              </>
            ) : (
              <>
                <span className="tbdLogo">?</span>
                <span>
                  <b>TO BE DECIDED</b>
                  <small>COMPLETE PREVIOUS SERIES</small>
                </span>
              </>
            )}
          </button>
        );
      })}
      <div className="bracketScore">
        <label>EXACT SCORE</label>
        <select
          value={pick.score || ""}
          disabled={!pick.winner || locked}
          onChange={(e) => score(match.id, e.target.value)}
        >
          <option value="">SELECT</option>
          {options.map((x) => (
            <option key={x}>{x}</option>
          ))}
        </select>
      </div>
    </article>
  );
}
