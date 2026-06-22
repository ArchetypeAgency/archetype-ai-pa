# Security Hardening — Evergreen Findings

Maintained by Cass. Updated on Monday and Thursday during Atlas session start.  
Entries are actionable checks and recommendations, not news. Each has a first-seen date and a status.

**Stack in scope:** WordPress (WPEngine), Next.js, Node.js, Render.com, AWS (S3/SES), GitHub Actions.

---

## Format

```
### [Finding title]
**First seen:** YYYY-MM-DD  
**Stack:** [which stack this applies to]  
**Status:** [ ] open / [x] verified / [!] flagged for review  
**Finding:** What the risk or recommendation is.  
**Check:** How to verify the current state.  
**Action:** What to do if the check fails.
```

---

<!-- Cass adds entries below this line -->

### Next.js middleware auth bypass (CVE-2025-29927)
**First seen:** 2026-06-18
**Stack:** Next.js 15 / Render.com
**Status:** [ ] open
**Finding:** Attackers can bypass Next.js middleware entirely — including auth checks — by sending a crafted `x-middleware-subrequest` header. CVSS 9.1. If any route protection is implemented in middleware rather than at the page/API-route level, this silently grants unauthenticated access.
**Check:** Run `next --version` in the project root. Versions below 15.5.18 are vulnerable (May 2026 batch supersedes the earlier 15.2.3 target). Also grep for auth logic in `middleware.ts` / `middleware.js` — any `redirect` or `return NextResponse.next()` guarding a protected route is at risk.
**Action:** Upgrade Next.js to 15.5.18 or later (covers this CVE and the full May 2026 batch of 13 CVEs). Move critical auth checks to the page/API layer as a defence-in-depth measure — never rely solely on middleware for access control.

---

### Next.js React Server Components RCE (CVE-2025-55182 / CVE-2025-66478)
**First seen:** 2026-06-18
**Stack:** Next.js 15 / Render.com
**Status:** [ ] open
**Finding:** A CVSS 10.0 flaw in the React RSC "Flight" protocol allows unauthenticated remote code execution in default App Router configurations. Disclosed December 2025. Any Next.js app using the App Router and deployed without additional hardening is potentially affected.
**Check:** Confirm the Next.js version in use (`package.json`). Check whether the project uses the App Router (`app/` directory). 15.5.18 is the confirmed patched floor as of May 2026.
**Action:** Upgrade to 15.5.18 or later (covers this CVE and the full May 2026 batch). If not yet patched, treat this as urgent — restrict public access to the Render.com service via IP allowlist or deploy a WAF rule to block malformed RSC requests while the upgrade is scheduled.

---

### GitHub Actions classic PAT exposure risk
**First seen:** 2026-06-18
**Stack:** GitHub Actions CI/CD (WPEngine deploy, Render.com deploy)
**Status:** [ ] open
**Finding:** Classic PATs (ghp_ tokens) grant broad access across all repos a user can access and have no mandatory expiry. The March 2025 tj-actions incident — which started with a stolen PAT — compromised 23,000+ repositories. This team uses classic PATs for WPEngine SSH and deploy workflows.
**Check:** Go to GitHub org → Settings → Personal access tokens → Active tokens. Identify any classic PATs. Check workflow files in `.github/workflows/` for references to secrets containing PATs (e.g. `WPENGINE_SSH_KEY`, deploy tokens). Confirm whether they are classic or fine-grained.
**Action:** Migrate WPEngine deploy workflows to use OIDC or fine-grained PATs scoped to only the required repo and permission. Set a maximum token lifetime. Where possible, replace long-lived secrets with OIDC-based short-lived tokens for Render.com deployments.

---

### GitHub Actions third-party action pinning
**First seen:** 2026-06-18
**Stack:** GitHub Actions CI/CD
**Status:** [ ] open
**Finding:** Pinning actions to a tag (e.g. `actions/checkout@v4`) rather than a commit SHA means a compromised or force-pushed tag silently changes what code runs in your pipeline. In March 2026, attackers rewrote 75 of 76 trivy-action version tags, exfiltrating secrets from every affected pipeline.
**Check:** Search all files under `.github/workflows/` for action `uses:` lines that reference a tag or `@main` rather than a full commit SHA (40-character hex string).
**Action:** Pin every third-party action to a full commit SHA. Use a tool like `pin-github-action` or Dependabot to automate SHA pinning and keep them updated.

---

### AWS SES IAM key abuse — phishing infrastructure risk
**First seen:** 2026-06-18
**Stack:** AWS SES (transactional email)
**Status:** [ ] open
**Finding:** Compromised AWS access keys were used in a May 2025 campaign to send 50,000+ phishing emails per day via SES, shifting cost and reputational damage to the key owner. SES abuse can result in domain blacklisting that breaks all transactional email for clients.
**Check:** In IAM, review which users and roles have `ses:SendEmail` or `ses:SendRawEmail` permissions. Confirm no long-lived access keys are attached to those principals. Check CloudTrail for any unusual SES API calls (SendEmail volume spikes, new identity verifications, PutAccountDetails calls outside normal hours).
**Action:** Scope SES permissions to the minimum required principal. Enable CloudTrail and set a CloudWatch alarm on `ses:SendEmail` call rate exceeding a normal daily threshold. Rotate any long-lived IAM keys that have SES send permissions. Enable SES sending limits appropriate to expected volume.

---

### Gravity SMTP unauthenticated API key exposure (CVE-2026-4020)
**First seen:** 2026-06-22
**Stack:** WordPress / WPEngine
**Status:** [ ] open
**Finding:** A REST endpoint at `/wp-json/gravitysmtp/v1/tests/mock-data` is registered with `permission_callback: true` (fully public). Appending `?page=gravitysmtp-settings` returns ~365 KB of System Report data including live API keys and OAuth tokens for Amazon SES, Google, Mailjet, Resend, and Zoho. Under active mass exploitation since May 2026 — Wordfence blocked 17 million attempts. CVSS medium but consequence is high (SES key compromise → phishing infrastructure, domain blacklisting).
**Check:** `wp plugin list | grep gravity-smtp`. If installed, check version: `wp plugin get gravity-smtp --field=version`. Versions through 2.1.4 are vulnerable. Quick test: `curl -s "https://[site]/wp-json/gravitysmtp/v1/tests/mock-data?page=gravitysmtp-settings"` — any JSON response containing API keys confirms exposure.
**Action:** Update Gravity SMTP to 2.1.5 or later immediately. If update cannot be applied now, add a WPEngine Access Rule blocking `/wp-json/gravitysmtp/` from public IPs as a temporary control.

---

### Next.js May 2026 security batch — SSRF, DoS, XSS, cache poisoning (13 CVEs)
**First seen:** 2026-06-22
**Stack:** Next.js 15 / Render.com
**Status:** [ ] open
**Finding:** May 2026 Vercel patch batch covering 13 CVEs. Key risks for self-hosted Render.com deployments: CVE-2026-44578 (CVSS 8.6, SSRF) — crafted WebSocket requests with malicious `X-Forwarded-Host` header cause the built-in Node.js server to proxy to internal destinations including AWS IMDS `169.254.169.254`, enabling IAM credential extraction. CVE-2026-23870 (high, DoS) — expensive deserialisation on Server Function endpoints triggers excessive CPU. CVE-2026-44573 (auth bypass) — Pages Router apps using i18n + middleware auth: locale-less requests skip middleware entirely. Vercel-hosted apps are not affected by the SSRF; Render.com deployments are fully exposed.
**Check:** `cat package.json | grep '"next"'` in each project. Versions below 15.5.18 are unpatched. For SSRF: confirm the Render.com service uses the built-in Next.js Node.js server (standard for Render) — if yes, it is affected.
**Action:** Upgrade all Next.js projects to 15.5.18 (or 16.2.6 if on 16.x) and redeploy. One upgrade covers all 13 CVEs plus the earlier middleware bypass and RSC RCE entries. Priority: high for Render.com-hosted apps.

---

### ACF Pro unauthenticated post modification via front-end forms (CVE-2026-8382)
**First seen:** 2026-06-22
**Stack:** WordPress / WPEngine / ACF Pro
**Status:** [ ] open
**Finding:** ACF versions through 6.8.1 have improper authorisation in front-end form handling. Where `acf_form()` is rendered on a public page, unauthenticated attackers can inject `_post_title` and `_post_content` values to overwrite those fields on the bound post. CVSS 5.3 (medium). Related CVE-2026-4812 (also medium) allows unauthenticated enumeration of draft/private post data via AJAX field endpoints on sites with public ACF forms. ACF 6.8.3 (2026-06-02) adds a further fix: oEmbed AJAX preview no longer performs URL discovery for users without `edit_posts` capability — prevents SSRF-like abuse by low-privilege contributors. ACF 6.8.4 released shortly after as a non-security maintenance release.
**Check:** `wp plugin get advanced-custom-fields-pro --field=version`. Below 6.8.2 = CVE-2026-8382 vulnerable; below 6.7.1 = CVE-2026-4812 vulnerable; below 6.8.3 = oEmbed SSRF risk for contributor-level users.
**Action:** Update ACF Pro to 6.8.4 or later (covers all three fixes). If `acf_form()` is used on public pages, review what post types are bound and consider restricting to logged-in users or adding nonce validation.

---

### WPGraphQL unauthenticated SQL injection (2026-04-21)
**First seen:** 2026-06-18
**Stack:** WPGraphQL / Faust.js headless WordPress
**Status:** [ ] open
**Finding:** WPGraphQL versions before 2.11.1 contain an unauthenticated SQL injection vulnerability (CVSS 7.5, published April 2026). An attacker with no credentials can query the GraphQL endpoint and extract data from the WordPress database.
**Check:** In the WordPress admin or via WP-CLI, check the installed WPGraphQL version: `wp plugin get wp-graphql --field=version`. Compare against 2.11.1.
**Action:** Update WPGraphQL to 2.11.1 or later immediately. If the update cannot be applied right away, consider temporarily disabling public access to the `/graphql` endpoint (nginx/WPEngine rule) and allowing only the Faust.js origin IP or a shared secret header.

---

### npm supply chain — install-time script execution
**First seen:** 2026-06-18
**Stack:** Node.js / Next.js / GitHub Actions CI/CD
**Status:** [ ] open
**Finding:** The September 2025 Shai-Hulud worm and subsequent attacks (Axios March 2026, TanStack May 2026) demonstrate that compromised npm packages execute malicious code at `npm install` time via `postinstall` scripts. CI/CD pipelines running `npm install` on every build are a primary attack surface — stolen secrets in the build environment are the target.
**Check:** In each project, check `.npmrc` for `ignore-scripts=true`. Audit `package.json` for any dependency using a `postinstall` script (`npm ls --parseable | xargs -I{} cat {}/package.json | grep postinstall`). Review GitHub Actions workflow files for `npm install` without `--ignore-scripts`.
**Action:** Add `ignore-scripts=true` to `.npmrc` in all Node.js projects. For packages that legitimately require build scripts (e.g. native modules), allowlist them explicitly. Consider `npm audit` as a required CI step that fails the build on high-severity findings.

---

### Breeze Cache unauthenticated file upload RCE (CVE-2026-3844)
**First seen:** 2026-06-22
**Stack:** WordPress / WPEngine
**Status:** [ ] open
**Finding:** CVSS 9.8 critical. The Breeze Cache plugin (WPEngine's own performance/caching plugin, 400,000+ installs) fails to validate file types in `fetch_gravatar_from_remote` (`class-breeze-cache-cronjobs.php`). When "Host Files Locally - Gravatars" is enabled, an unauthenticated attacker can point the Gravatar source to a PHP webshell and trigger a remote code execution. Actively exploited — Wordfence blocked 3,936 attempts in a single 24-hour window in late April 2026; over 170 confirmed exploitation attempts observed. PoC exploit is public on GitHub.
**Check:** `wp plugin list | grep breeze`. If installed, check version: `wp plugin get breeze --field=version`. Versions up to and including 2.4.4 are vulnerable. Confirm whether "Host Files Locally - Gravatars" is enabled in Breeze settings (WP Admin → Breeze → CDN/Media).
**Action:** Update Breeze to 2.4.7 or later immediately. If the update cannot be applied now, disable the "Host Files Locally - Gravatars" setting to eliminate the attack surface. Note: Breeze is installed by default on WPEngine-hosted WordPress sites — check all WPEngine environments, not just sites with explicit Breeze configuration.

---

### GitHub Actions OIDC token abuse — Miasma supply chain attack (June 2026)
**First seen:** 2026-06-22
**Stack:** GitHub Actions CI/CD
**Status:** [ ] open
**Finding:** On 1 June 2026, attackers compromised a Red Hat employee GitHub account and pushed malicious orphan commits that triggered GitHub Actions workflows requesting OIDC identity tokens (`id-token: write`). The resulting packages were published with valid SLSA cryptographic provenance attestations — indistinguishable from legitimate builds. This is a new TTPs evolution from the earlier tj-actions/Shai-Hulud campaigns: OIDC tokens are now being weaponised to produce trusted artefacts, not just exfiltrate secrets. The workflow's `id-token: write` permission is the enabler.
**Check:** Audit all workflow files under `.github/workflows/` for `id-token: write` permission. Identify which workflows actually require it (e.g. Render OIDC deploy, AWS assume-role). Any workflow that has `id-token: write` but does not explicitly use OIDC for deployment should have the permission removed. Also confirm that third-party actions in those workflows are pinned to full commit SHAs (see action-pinning entry).
**Action:** Apply least-privilege to OIDC permissions: only grant `id-token: write` on workflows that genuinely require it; scope permissions to the job level, not the workflow level. Add `permissions: {}` at the top of every workflow file to make grants explicit. Review SLSA provenance attestations as a verification layer but do not rely on them as the only control — provenance only proves the build ran; it does not prove the build inputs were clean.

---

### WordPress plugin patch window — 97% of CVEs are plugin/theme origin
**First seen:** 2026-06-18
**Stack:** WordPress / WPEngine
**Status:** [ ] open
**Finding:** Patchstack's 2025 annual report recorded 11,334 new WordPress ecosystem vulnerabilities — a 42% year-on-year increase — with 97% originating in plugins and themes, not core. The first 24 hours after a public CVE disclosure are the highest-risk window, as exploit code is typically available immediately.
**Check:** In WPEngine dashboard or via WP-CLI (`wp plugin list --update=available`), confirm all plugins are on current versions. Identify any plugins not updated in the last 30 days. Cross-reference installed plugins against the Wordfence Intelligence or Patchstack vulnerability database.
**Action:** Establish a weekly plugin patch window (e.g. Monday morning, pre-deploy). Subscribe to Wordfence Intelligence or Patchstack alerts for all installed plugins so critical CVEs trigger same-day patches rather than waiting for the next window. Audit and remove any plugins that are inactive or unmaintained.
