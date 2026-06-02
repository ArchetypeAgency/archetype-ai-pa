# QVC — Suite

**Status:** Active — maintenance retainer
**Hosting:** WPEngine
**Stack:** WordPress

## Repo structure

### qvc-core-wp-engine (`./qvc-core-wp-engine`)
Base repo for 7 of the 8 sites. Sites are differentiated by a per-site theme inside `wp-content/plugins/newsroom/themes/`:

| Site | Newsroom theme folder | Workflow prefix |
|---|---|---|
| QVCGRP (formerly Qurate) | `qvc-qurate` | `deploy-group-*` |
| QVC Corporate | `qvc-corporate` | `deploy-corporate-*` |
| QVC HSN | `qvc-hsn` | `deploy-hsn-*` |
| QVC Presse (Germany) | `qvc-presse` | `deploy-presse-*` |
| QVC Italy | `qvc-italy` | `deploy-italy-*` |
| QVC Japan | `qvc-japan` | `deploy-japan-*` |
| QVC UK | `qvc-uk` | `deploy-uk-*` |

Each site has 3 GitHub Actions workflows: `deploy-[site]-dev.yml`, `deploy-[site]-stg.yml`, `deploy-[site]-prod.yml` (21 workflow files total). Deployment is via WPEngine rsync.

**Current PHP in workflows:** 8.2 — must be updated to 8.4 when upgrading.

### qvc-careers-wp-engine (`./qvc-careers-wp-engine`)
Separate repo with a different structure. Deploys via **git push** (no workflow files). QVC Careers is the 8th site.

## Current PHP version
All sites currently on **PHP 8.2.27** — target is **8.4** on WPEngine.

## Current tasks
- Plugin updates across all 8 sites
- PHP upgrade to 8.4 on WPEngine (all 8 sites)
  - For the 7 core sites: also update `php-version` in all 21 workflow files
  - For Careers: update via git push only

## Outstanding
- [ ] Plugin updates — any specific plugins flagged, or full sweep?
- [ ] PHP 8.4 upgrade — test for compatibility issues before pushing to prod
