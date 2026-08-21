import { expect, test } from '@playwright/test';

test.describe('public experience', () => {
  test('registration page renders core identity and controls', async ({ page, request }) => {
    const initial = await request.get('/');
    const initialMarkup = await initial.text();
    expect(initialMarkup).toContain('PREPARING YOUR ARENA');
    expect(initialMarkup).not.toContain('CREATE YOUR MANAGER PROFILE');
    await page.goto('/');
    await expect(page).toHaveTitle(/Fantasy MPL/i);
    await expect(page.getByRole('heading', { name: /WELCOME TO FANTASY MPL/i })).toBeVisible();
    await expect(page.locator('.guestJourney')).toHaveCount(0);
    await expect(page.getByRole('button', { name: /EXPLORE THE ARENA/i })).toHaveCount(0);
    await expect(page.getByRole('button', { name: /CREATE YOUR MANAGER/i })).toHaveCount(0);
    await expect(page.getByRole('button', { name: 'CREATE FREE ACCOUNT', exact: true })).toBeVisible();
    await page.getByRole('button', { name: 'CREATE FREE ACCOUNT', exact: true }).click();
    await expect(page.getByRole('button', { name: 'CREATE ACCOUNT', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'SIGN IN', exact: true })).toBeVisible();
    await expect(page.getByLabel(/AGE AND GUARDIAN CONFIRMATION/i)).toBeVisible();
    await expect(page.getByRole('button', { name: /CONTINUE EXPLORING/i })).toBeVisible();
  });

  test('local fallback registration reaches regional onboarding', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'CREATE FREE ACCOUNT', exact: true }).click();
    await page.getByLabel('FULL NAME *').fill('Fantasy Test Manager');
    await page.getByLabel('MANAGER NAME *').fill('TestManager');
    await page.getByLabel('EMAIL ADDRESS').fill('test@example.com');
    await page.getByLabel('PASSWORD').fill('test-password');
    await page.getByLabel('COUNTRY').selectOption('MY');
    await page.getByLabel(/AGE AND GUARDIAN CONFIRMATION/i).check();
    await page.getByRole('button', { name: /CREATE ACCOUNT →/ }).click();

    await expect(page.getByRole('heading', { name: 'CHOOSE YOUR BATTLEGROUND' })).toBeVisible();
    await page.getByRole('button', { name: /MPL Malaysia/i }).click();
    await expect(page.getByText(/WELCOME BACK, TESTMANAGER/i)).toBeVisible();
    await expect(page.getByText('1,248', { exact: true })).toHaveCount(0);
    await expect(page.getByText('#284', { exact: true })).toHaveCount(0);
    await expect(page.getByText('Borneo Rivals', { exact: true })).toHaveCount(0);
    await expect(page.getByText(/NO VERIFIED DATA/i)).toBeVisible();
  });

  test('visitors can browse regional features before creating an account', async ({ page, isMobile }) => {
    test.setTimeout(45_000);
    await page.goto('/');
    await expect(page.getByRole('heading', { name: /WELCOME TO FANTASY MPL/i })).toBeVisible();
    await expect(page.getByRole('heading', { name: 'CHOOSE YOUR BATTLEGROUND' })).toBeVisible({ timeout: 12_000 });
    await expect(page.locator('.guestRegionCard')).toHaveCount(3);
    await expect(page.locator('.modernTeamShowcase')).toBeVisible();
    await expect(page.locator('.modernTeamShowcase header nav button')).toHaveCount(3);
    await expect(page.locator('.modernTeamGrid article')).toHaveCount(8);
    await page.locator('.modernTeamShowcase header nav button').filter({ hasText: 'ID' }).click();
    await expect(page.locator('.modernTeamGrid article')).toHaveCount(9);
    await page.locator('.guestRegionID').click();
    await expect(page.getByText(/Opening the regional command center/i)).toBeVisible();
    await expect(page.getByText(/WELCOME BACK, GUEST MANAGER/i)).toBeVisible({ timeout: 5000 });
    await expect(page).toHaveURL(/\/id#dashboard$/);
    await expect(page.locator('.guestPreviewBanner').getByText('GUEST PREVIEW', { exact: true })).toBeVisible();

    if (isMobile) await page.getByRole('button', { name: 'Open navigation' }).click();
    const navigation=isMobile?page.locator('.mobileDrawer'):page.locator('.groupedNav').first();
    await expect(navigation.getByRole('button', { name: /My Profile/i })).toHaveCount(0);
    await navigation.getByRole('button', { name: /Teams & Players/i }).click();
    await expect(page.getByRole('heading', { name: 'Teams & Players' })).toBeVisible();
    await expect(page.getByRole('button', { name: /CREATE FREE ACCOUNT/i }).first()).toBeVisible();
    await page.reload();
    await expect(page.getByRole('heading', { name: 'Teams & Players' })).toBeVisible();
    await expect(page.locator('.guestPreviewBanner').getByText('GUEST PREVIEW', { exact: true })).toBeVisible();
    await page.locator('.guestPreviewBanner').getByRole('button', { name: 'CREATE FREE ACCOUNT' }).click();
    await expect(page.getByRole('heading', { name: 'Create your manager profile' })).toBeVisible();
    await page.getByRole('button', { name: /CONTINUE EXPLORING/i }).click();
    await expect(page.getByRole('heading', { name: 'Teams & Players' })).toBeVisible();
  });

  test('authenticated startup never flashes login and dark mode persists', async ({ page, isMobile }) => {
    await page.addInitScript(() => {
      (window as unknown as { __sawLogin: boolean }).__sawLogin = false;
      new MutationObserver(() => {
        if (document.body?.innerText.includes('CREATE YOUR MANAGER PROFILE')) {
          (window as unknown as { __sawLogin: boolean }).__sawLogin = true;
        }
      }).observe(document, { subtree: true, childList: true, characterData: true });
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4, name: 'StartupManager', email: 'startup@example.com', country: 'MY',
        fullName: 'Startup Test Manager', address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'user', joined: ['MY'], active: 'MY', picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my');
    await expect(page.getByText(/WELCOME BACK, STARTUPMANAGER/i)).toBeVisible();
    expect(await page.evaluate(() => (window as unknown as { __sawLogin: boolean }).__sawLogin)).toBeFalsy();
    await expect(page.locator('.shell')).toHaveClass(/darkMode/);
    if (isMobile) await page.getByRole('button', { name: 'Open navigation' }).click();
    await page.getByRole('button', { name: 'Switch to light mode' }).click();
    await expect(page.locator('.shell')).toHaveClass(/lightMode/);
    await page.reload();
    await expect(page.locator('.shell')).toHaveClass(/lightMode/);
    if (isMobile) await page.getByRole('button', { name: 'Open navigation' }).click();
    await page.getByRole('button', { name: 'Switch to dark mode' }).click();
    await expect(page.locator('.shell')).toHaveClass(/darkMode/);
  });

  test('joined regions switch reliably on desktop and mobile', async ({ page, isMobile }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4, name: 'RegionManager', email: 'regions@example.com', country: 'MY',
        fullName: 'Region Test Manager', address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'user', joined: ['MY', 'ID', 'PH'], active: 'MY', picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my#dashboard');
    await expect(page.locator('.hero')).toContainText('MPL Malaysia');

    const openRegionSelector = async () => {
      if (isMobile) {
        await page.getByRole('button', { name: 'Open navigation' }).click();
        await page.locator('.drawerRegion').click();
      } else {
        await page.locator('.desktopRegionCard').click();
      }
      await expect(page.getByRole('heading', { name: 'CHOOSE YOUR BATTLEGROUND' })).toBeVisible();
    };

    await openRegionSelector();
    await page.getByRole('button', { name: /MPL Indonesia/i }).click();
    await expect(page).toHaveURL(/\/id#dashboard$/);
    await expect(page.locator('.hero')).toContainText('MPL Indonesia');

    await openRegionSelector();
    await page.getByRole('button', { name: /MPL Philippines/i }).click();
    await expect(page).toHaveURL(/\/ph#dashboard$/);
    await expect(page.locator('.hero')).toContainText('MPL Philippines');
    await expect(page.getByText(/TypeError|Load failed/i)).toHaveCount(0);
  });

  test('admin console is discoverable and theme-safe on desktop and mobile', async ({ page, isMobile }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_color_mode', 'dark');
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4, name: 'AdminManager', email: 'admin@example.com', country: 'MY',
        fullName: 'Admin Test Manager', address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'admin', joined: ['MY', 'ID', 'PH'], active: 'MY', picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my#admin');
    await expect(page.getByRole('heading', { name: 'Admin Command Center' })).toBeVisible();
    await expect(page.locator('.adminSectionHeader h2')).toHaveText('Command overview');

    const openMobileTools = async () => {
      if (!isMobile) return;
      const browser = page.locator('.adminMobileNavigator>button');
      if ((await browser.getAttribute('aria-expanded')) !== 'true') await browser.click();
      await expect(page.locator('.adminMobileToolMenu')).toBeVisible();
    };

    if (isMobile) {
      await expect(page.locator('.adminToolRail')).toBeHidden();
      await openMobileTools();
      await expect(page.locator('.adminMobileToolMenu [data-admin-nav]')).toHaveCount(9);
    } else {
      await expect(page.locator('.adminToolRail')).toBeVisible();
      await expect(page.locator('.adminToolRail [data-admin-nav]')).toHaveCount(9);
      await expect(page.locator('.adminToolRail').getByText('MONITOR', { exact: true })).toBeVisible();
      await expect(page.locator('.adminToolRail').getByText('COMPETITION', { exact: true })).toBeVisible();
      await expect(page.locator('.adminToolRail').getByText('DATA & PLATFORM', { exact: true })).toBeVisible();
    }

    for (const [tool, heading] of [['matches', 'Results & scoring'], ['mvp', 'Weekly MVP'], ['players', 'Players & teams']] as const) {
      await openMobileTools();
      const scope = isMobile ? page.locator('.adminMobileToolMenu') : page.locator('.adminToolRail');
      await scope.locator(`[data-admin-nav="${tool}"]`).click();
      await expect(page.locator('.adminSectionHeader h2')).toHaveText(heading);
      await expect(page.locator('.adminToolContent')).toHaveAttribute('data-admin-tool', tool);
    }

    const darkAudit = await page.locator('.adminPage').evaluate(root => {
      const leaks:string[]=[];
      for (const element of root.querySelectorAll('*')) {
        const rect=element.getBoundingClientRect();
        if(rect.width*rect.height<2500||rect.bottom<0)continue;
        const match=getComputedStyle(element).backgroundColor.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?/);
        if(!match)continue;
        const alpha=match[4]==null?1:Number(match[4]);
        if(alpha>.5&&Number(match[1])>225&&Number(match[2])>225&&Number(match[3])>225)leaks.push((element.className||element.tagName).toString());
      }
      return {leaks,overflow:document.documentElement.scrollWidth>document.documentElement.clientWidth+1};
    });
    expect(darkAudit.leaks).toEqual([]);
    expect(darkAudit.overflow).toBeFalsy();

    if (isMobile) {
      await page.getByRole('button', { name: 'Open navigation' }).click();
      await page.getByRole('button', { name: 'Switch to light mode' }).click();
      await page.getByRole('button', { name: 'Close navigation' }).click();
    } else {
      await page.getByRole('button', { name: 'Switch to light mode' }).click();
    }
    await expect(page.locator('.shell')).toHaveClass(/lightMode/);
    await expect(page.locator('.adminSectionHeader')).toHaveCSS('background-color', 'rgb(255, 255, 255)');
    const lightOverflow = await page.evaluate(() => document.documentElement.scrollWidth > document.documentElement.clientWidth + 1);
    expect(lightOverflow).toBeFalsy();
  });

  test('Draft Intelligence Sources uses modern dark and light surfaces', async ({ page, isMobile }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_color_mode', 'dark');
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4, name: 'SourceAdmin', email: 'sources@example.com', country: 'MY',
        fullName: 'Source Admin', address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'admin', joined: ['MY'], active: 'MY', picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my#admin');
    await page.locator('.adminToolContent').evaluate(element => {
      element.innerHTML = `<div class="intelligenceConsole">
        <nav class="intelligenceTabs"><button>Overview</button><button class="active">Sources</button><button>Patch & Data</button><button>Draft Import</button><button>Model</button></nav>
        <div class="sourceWorkspace modernSourceWorkspace">
          <section class="sourceGovernanceSummary"><div><span>DATA SOURCE GOVERNANCE</span><h2>Approve evidence before it reaches public models.</h2><p>Record ownership, usage rights and exact attribution.</p></div><div class="sourceGovernanceStats"><article><small>REGISTERED</small><b>1</b><span>source</span></article><article><small>APPROVED</small><b>1</b><span>provider</span></article><article><small>COMMERCIAL RIGHTS</small><b>0</b><span>permission</span></article><article><small>PRIMARY</small><b>0</b><span>source</span></article></div></section>
          <section class="panel sourceLibrary"><div class="intelligenceSectionHead"><div><span>REGISTERED SOURCES</span><h2>Source library</h2></div></div><div class="sourceCards"><article class="sourceCard sourceCardapproved"><div class="sourceCardTop"><span class="sourceStatus sourceStatusapproved">APPROVED</span></div><h3>OpenMLBB / RoneAI</h3><div class="sourceRightsGrid"><div><small>LICENCE</small><b>Provider authorization</b></div><div class="unconfirmed"><small>COMMERCIAL USE</small><b>UNCONFIRMED</b></div></div><blockquote><span>PUBLIC ATTRIBUTION</span><p>Required provider credit.</p></blockquote></article></div></section>
          <form class="panel sourceReviewForm modernSourceReview"><div class="intelligenceSectionHead"><div><span>GUIDED SOURCE REVIEW</span><h2>Register or update a provider</h2></div></div><section class="sourceFormSection"><div class="sourceFormSectionTitle"><i>1</i><div><h3>Provider identity</h3><p>Record official references.</p></div></div><div class="formGrid"><label>SOURCE NAME<input value="OpenMLBB / RoneAI"></label><label>LICENCE<input value="Authorization"></label><label class="wide">PROVIDER URL<input value="https://example.com"></label></div></section><section class="sourceFormSection"><div class="sourceFormSectionTitle"><i>2</i><div><h3>Rights and public credit</h3></div></div><div class="formGrid"><label class="wide">PUBLIC ATTRIBUTION<input value="Required provider credit"></label><label class="wide">REVIEW NOTES<textarea>Non-commercial only.</textarea></label></div></section><section class="sourceFormSection"><div class="sourceDecisionGrid"><label class="sourceStatusField">REVIEW STATUS<select><option>PENDING REVIEW</option></select></label><div class="sourcePermissions"><label><input type="checkbox"><i>○</i><span><b>Commercial use confirmed</b><small>Written permission required</small></span></label></div></div></section></form>
        </div></div>`;
    });

    await expect(page.locator('.sourceLibrary')).toHaveCSS('background-color', 'rgb(12, 29, 46)');
    await expect(page.locator('.sourceFormSection').first()).toHaveCSS('background-color', 'rgb(10, 25, 40)');
    const fieldSizing = await page.locator('.sourceFormSection .formGrid label').first().evaluate(label => ({ label: label.getBoundingClientRect().width, input: label.querySelector('input')!.getBoundingClientRect().width }));
    expect(fieldSizing.input).toBeGreaterThanOrEqual(fieldSizing.label - 1);
    const darkLeaks = await page.locator('.modernSourceWorkspace').evaluate(root => [...root.querySelectorAll('*')].filter(element => {
      const rect=element.getBoundingClientRect();
      const match=getComputedStyle(element).backgroundColor.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?/);
      if(!match||rect.width*rect.height<1800)return false;
      const alpha=match[4]==null?1:Number(match[4]);
      return alpha>.5&&Number(match[1])>225&&Number(match[2])>225&&Number(match[3])>225;
    }).length);
    expect(darkLeaks).toBe(0);

    if (isMobile) {
      await page.getByRole('button', { name: 'Open navigation' }).click();
      await page.getByRole('button', { name: 'Switch to light mode' }).click();
      await page.getByRole('button', { name: 'Close navigation' }).click();
    } else await page.getByRole('button', { name: 'Switch to light mode' }).click();
    await expect(page.locator('.sourceLibrary')).toHaveCSS('background-color', 'rgb(255, 255, 255)');
    await expect(page.locator('.intelligenceTabs button.active')).toHaveCSS('background-color', 'rgb(23, 105, 210)');
    expect(await page.evaluate(() => document.documentElement.scrollWidth > document.documentElement.clientWidth + 1)).toBeFalsy();
  });

  test('dark mode has no large light surface leaks', async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_color_mode', 'dark');
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4, name: 'ContrastManager', email: 'contrast@example.com', country: 'MY',
        fullName: 'Contrast Test Manager', address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'user', joined: ['MY'], active: 'MY', picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    for (const view of ['predictions', 'fantasy', 'competition', 'directory', 'playoffs', 'draftlab', 'meta', 'leaderboard', 'profile', 'prizes']) {
      await page.goto(`/my#${view}`);
      await expect(page.locator('.shell')).toHaveClass(/darkMode/);
      await page.waitForTimeout(250);
      const lightLeaks = await page.locator('.shell.darkMode').evaluate(root => {
        const leaks:string[]=[];
        for (const element of root.querySelectorAll('*')) {
          const rect=element.getBoundingClientRect();
          if(rect.width*rect.height<2500||rect.bottom<0)continue;
          const match=getComputedStyle(element).backgroundColor.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?/);
          if(!match)continue;
          const alpha=match[4]==null?1:Number(match[4]);
          if(alpha>.5&&Number(match[1])>225&&Number(match[2])>225&&Number(match[3])>225)leaks.push((element.className||element.tagName).toString());
        }
        return leaks;
      });
      expect(lightLeaks, `${view} contains light surfaces`).toEqual([]);
    }
    await expect(page.getByRole('button', { name: /Creator Hub/i })).toHaveCount(0);
    await page.goto('/my#creators');
    await expect(page.getByRole('heading', { name: /PLAY AGAINST THE VOICES OF MPL/i })).toHaveCount(0);
    await expect(page.getByRole('button', { name: /Creator Hub/i })).toHaveCount(0);
  });

  test('regional entry lanes and cached model endpoint are available', async ({ page, request }) => {
    for (const route of ['/my', '/id', '/ph']) {
      const response = await request.get(route);
      expect(response.status()).toBe(200);
    }
    await page.goto('/my');
    await expect(page.getByRole('heading', { name: /WELCOME TO FANTASY MPL/i })).toBeVisible();
    const model = await request.get('/api/draft-model?region=MY');
    expect(model.status()).toBe(200);
    const payload = await model.json();
    expect(payload.status.region).toBe('MY');
    expect(Array.isArray(payload.metrics)).toBeTruthy();
  });

  test('custom playoffs stay editable and official predictor exposes its countdown', async ({ page, request }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4,
        name: 'BracketManager',
        email: 'bracket@example.com',
        country: 'MY',
        fullName: 'Bracket Test Manager',
        address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'user', joined: ['MY'], active: 'MY',
        picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my#playoffs');
    await expect(page.getByRole('heading', { name: /Road to the Grand Final/i })).toBeVisible();
    await expect(page.locator('.seedPickerCard')).toHaveCount(6);
    const seedOne = page.getByLabel('Seed 1');
    const alternate = await seedOne.locator('option').last().getAttribute('value');
    await seedOne.selectOption(alternate!);
    await expect(seedOne).toHaveValue(alternate!);
    await expect(page.getByRole('button', { name: 'SAVE CUSTOM BRACKET' })).toBeVisible();
    await expect(page.getByRole('button', { name: /LOCK OFFICIAL PREDICTION/i })).toHaveCount(0);
    const seedSummary = page.locator('.bracketScroll + .seedingSummary');
    await expect(seedSummary).toHaveCount(1);
    await expect(seedSummary.locator('.seedingSummaryGrid article')).toHaveCount(6);
    const summaryWidth = await seedSummary.evaluate(element => ({
      clientWidth: element.clientWidth,
      scrollWidth: element.scrollWidth
    }));
    expect(summaryWidth.scrollWidth).toBeLessThanOrEqual(summaryWidth.clientWidth + 1);

    await page.getByRole('button', { name: /OFFICIAL PREDICTOR/i }).click();
    await expect(page.getByRole('heading', { name: /Official Predictor Opens Soon/i })).toBeVisible();
    await expect(page.locator('.playoffCountdown')).toBeVisible();
    await expect(page.getByRole('button', { name: /BUILD A CUSTOM BRACKET NOW/i })).toBeVisible();

    const access = await request.get('/api/playoff-access?region=MY');
    expect(access.status()).toBe(200);
    expect((await access.json()).server_now).toBeTruthy();
  });

  test('every open match requires winner and exact score', async ({ page, isMobile }) => {
    test.skip(Boolean(isMobile), 'Desktop flow is automated; mobile scoring remains covered by manual beta QA.');
    // Mandatory BO score validation is also enforced server-side by
    // public.validate_mandatory_match_score() in Migration 013.
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4,
        name: 'PredictionManager',
        email: 'prediction@example.com',
        country: 'MY',
        fullName: 'Prediction Test Manager',
        address: '',
        bio: '',
        dob: '',
        avatar: '',
        accountRole: 'user',
        joined: ['MY'],
        active: 'MY',
        picks: {},
        exactScores: {},
        submittedAt: {},
        captains: {},
        rosters: {},
        transfers: {}
      }));
    });

    await page.goto('/');
    await expect(page.locator('.heroActions .primary')).toBeVisible();
    await page.locator('.heroActions .primary').click();
    await expect(page.locator('.fullMatch').first()).toBeVisible();

    const submit = page.locator('.saveBar .primary');
    await expect(submit).toBeDisabled();

    const matches = page.locator('.fullMatch:not(.matchLocked)');
    const matchCount = await matches.count();
    expect(matchCount).toBeGreaterThan(0);

    for (let index = 0; index < matchCount; index++) {
      const match = matches.nth(index);
      await match.locator('.winnerControls button').first().click();
      await expect(match.locator('.mandatoryScore button').first()).toBeEnabled();
      await match.locator('.mandatoryScore button').first().click();
    }

    await page.locator('.mvpCard:not(:disabled)').first().click();
    await expect(submit).toBeEnabled();
  });

  test('profile save waits for confirmation and survives refresh', async ({ page, isMobile }) => {
    test.skip(Boolean(isMobile), 'Desktop persistence flow is sufficient for local fallback coverage.');
    await page.addInitScript(() => { if (!localStorage.getItem('fmpl_session')) localStorage.setItem('fmpl_session', JSON.stringify({
      dataVersion:4,name:'ProfileManager',email:'profile@example.com',country:'MY',fullName:'Profile Test Manager',
      address:'',bio:'',dob:'',avatar:'',accountRole:'user',joined:['MY'],active:'MY',picks:{},exactScores:{},
      submittedAt:{},captains:{},rosters:{},transfers:{}
    })); });
    await page.goto('/my#profile');
    await page.getByLabel('MANAGER NAME').fill('SavedManager');
    await page.getByLabel(/BIO · OPTIONAL/i).fill('Verified local persistence test.');
    await page.getByRole('button', { name: 'SAVE PROFILE CHANGES' }).click();
    await expect(page.getByText(/Profile updated and confirmed/i)).toBeVisible();
    await page.reload();
    await expect(page.getByLabel('MANAGER NAME')).toHaveValue('SavedManager');
    await expect(page.getByLabel(/BIO · OPTIONAL/i)).toHaveValue('Verified local persistence test.');
  });

  test('active section survives a full page refresh', async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4,
        name: 'RefreshManager',
        email: 'refresh@example.com',
        country: 'MY',
        fullName: 'Refresh Test Manager',
        address: '', bio: '', dob: '', avatar: '', accountRole: 'user',
        joined: ['MY'], active: 'MY', picks: {}, exactScores: {},
        submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
    });
    await page.goto('/my#predictions');
    await expect(page.getByRole('heading', { name: 'Prediction Hub' })).toBeVisible();
    await page.reload();
    await expect(page).toHaveURL(/\/my#predictions$/);
    await expect(page.getByRole('heading', { name: 'Prediction Hub' })).toBeVisible();
  });

  test('public Live Draft Lab records a legal draft action without login', async ({ page }) => {
    await page.goto('/live-draft');
    await expect(page.getByRole('heading', { name: /Build the draft/i })).toBeVisible();
    await expect.poll(() => page.evaluate(() => performance.getEntriesByType('resource').some(entry => entry.name.includes('/api/draft-model')))).toBeTruthy();
    await page.getByRole('button', { name: 'BAN slot 1', exact: true }).first().click();
    const pickerDialog=page.getByRole('dialog', { name: /SELECT THE HERO TO BAN/i });
    await expect(pickerDialog).toBeVisible();
    await expect(page.locator('body')).toHaveCSS('overflow', 'hidden');
    const pickerFit=await pickerDialog.evaluate(element=>{const rect=element.getBoundingClientRect();return{top:rect.top,left:rect.left,right:rect.right,bottom:rect.bottom,width:innerWidth,height:innerHeight,overflow:document.documentElement.scrollWidth>document.documentElement.clientWidth+1}});
    expect(pickerFit.top).toBeGreaterThanOrEqual(0);
    expect(pickerFit.left).toBeGreaterThanOrEqual(0);
    expect(pickerFit.right).toBeLessThanOrEqual(pickerFit.width);
    expect(pickerFit.bottom).toBeLessThanOrEqual(pickerFit.height);
    expect(pickerFit.overflow).toBeFalsy();
    const heroPortraits = page.locator('.heroGrid .heroPortrait img');
    await expect(heroPortraits).toHaveCount(133);
    await expect.poll(() => heroPortraits.evaluateAll(images => images.every(image => (image as HTMLImageElement).naturalWidth > 0))).toBeTruthy();
    const hirara = page.getByRole('button', { name: /HIRARA.*JUNGLE/i });
    await hirara.scrollIntoViewIfNeeded();
    await expect(hirara).toBeVisible();
    await expect(hirara.locator('img')).toHaveAttribute('src', /\/heroes\/hirara\.webp$/);
    const atlas = page.getByRole('button', { name: /ATLAS.*ROAM/i });
    await expect(atlas.locator('img')).toHaveAttribute('src', /\/heroes\/atlas\.webp$/);
    await atlas.click();
    await expect(pickerDialog).toHaveCount(0);
    await expect(page.locator('body')).not.toHaveCSS('overflow', 'hidden');
    const selectedAtlas = page.getByRole('button', { name: /BAN slot 1: ATLAS/i });
    await expect(selectedAtlas).toBeVisible();
    await expect(selectedAtlas.locator('img')).toHaveAttribute('src', /\/heroes\/atlas\.webp$/);
    await expect(page.getByText(/Powered by MLBB Public Data API/i)).toBeVisible();
    await expect(page.locator('.draftTurn > span')).toHaveText('RED SIDE');
  });

  test('completed generic draft reveals an evidence-gated report', async ({ page, isMobile }) => {
    test.skip(Boolean(isMobile), 'Desktop report validates the shared completed-draft component.');
    await page.addInitScript(() => localStorage.setItem('fmpl_draft_tool', JSON.stringify({ firstSide:'BLUE', mode:'companion', actions:['AAMON','AKAI','ALDOUS','ALICE','ALUCARD','ANGELA','ARGUS','ARLOTT','ATLAS','AULUS','AURORA','BADANG','BALMOND','BANE','BARATS','BAXIA','BEATRIX','BELERICK','BENEDETTA','BRODY'] })));
    await page.goto('/live-draft');
    await expect(page.getByRole('heading', { name: 'Draft Report' })).toBeVisible();
    await expect(page.getByText(/MODEL LIMITATION/i)).toBeVisible();
    await expect(page.locator('.draftTimeline span')).toHaveCount(20);
  });

  test('authenticated dark Draft Report has no light surfaces on desktop or mobile', async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem('fmpl_color_mode', 'dark');
      localStorage.setItem('fmpl_session', JSON.stringify({
        dataVersion: 4, name: 'DraftReportManager', email: 'draft-report@example.com', country: 'MY',
        fullName: 'Draft Report Manager', address: '', bio: '', dob: '', avatar: '', termsAccepted: true,
        accountRole: 'user', joined: ['MY'], active: 'MY', picks: {}, exactScores: {}, submittedAt: {}, captains: {}, rosters: {}, transfers: {}
      }));
      localStorage.setItem('fmpl_draft_tool', JSON.stringify({ firstSide:'BLUE', mode:'companion', actions:['AAMON','AKAI','ALDOUS','ALICE','ALUCARD','ANGELA','ARGUS','ARLOTT','ATLAS','AULUS','AURORA','BADANG','BALMOND','BANE','BARATS','BAXIA','BEATRIX','BELERICK','BENEDETTA','BRODY'] }));
    });
    await page.goto('/my#draftlab');
    const report=page.locator('.draftReport');
    await expect(report.getByRole('heading', { name: 'Draft Report' })).toBeVisible();
    const audit=await report.evaluate(root=>{
      const leaks:string[]=[];
      for(const element of root.querySelectorAll('*')){
        const rect=element.getBoundingClientRect();
        if(rect.width*rect.height<1200)continue;
        const match=getComputedStyle(element).backgroundColor.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?/);
        if(!match)continue;
        const alpha=match[4]==null?1:Number(match[4]);
        if(alpha>.5&&Number(match[1])>225&&Number(match[2])>225&&Number(match[3])>225)leaks.push((element.className||element.tagName).toString());
      }
      return{leaks,overflow:document.documentElement.scrollWidth>document.documentElement.clientWidth+1};
    });
    expect(audit.leaks).toEqual([]);
    expect(audit.overflow).toBeFalsy();
    await expect(report.locator('.draftEstimate')).toHaveCSS('background-color','rgb(9, 24, 39)');
    await expect(report.locator('.draftStatGrid>article').first()).toHaveCSS('background-color','rgb(16, 36, 56)');
    await expect(report.locator('.estimateDisclaimer')).toHaveCSS('background-color','rgb(43, 38, 24)');
  });

  test('policy pages and metadata routes are available', async ({ page, request }) => {
    for (const route of ['/privacy', '/terms', '/rules', '/community-guidelines']) {
      const response = await page.goto(route);
      expect(response?.status()).toBe(200);
      await expect(page.locator('h1')).toBeVisible();
    }

    for (const route of ['/robots.txt', '/sitemap.xml', '/manifest.webmanifest', '/icon.png', '/favicon.ico']) {
      const response = await request.get(route);
      expect(response.status()).toBe(200);
    }

    await page.goto('/');
    await expect(page.locator('link[rel="canonical"]')).toHaveAttribute('href', /^https:\/\//);
  });

  test('PandaScore synchronization endpoint rejects unauthenticated callers', async ({ request }) => {
    expect((await request.get('/api/integrations/pandascore/sync')).status()).toBe(401);
    expect((await request.post('/api/integrations/pandascore/sync')).status()).toBe(401);
  });

  test('security headers are attached to application pages', async ({ request }) => {
    const response = await request.get('/');
    expect(response.headers()['content-security-policy']).toContain("default-src 'self'");
    expect(response.headers()['x-content-type-options']).toBe('nosniff');
    expect(response.headers()['x-frame-options']).toBe('DENY');
    expect(response.headers()['referrer-policy']).toBe('strict-origin-when-cross-origin');
  });
});
