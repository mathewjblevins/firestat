# FireStat — NFIRS Fire Department Analytics

Live analytics dashboard for NFIRS 2024 fire department performance data.  
**9,733 departments · 51 states · quality-filtered**

🔗 **Live app:** `https://[your-username].github.io/firestat`

---

## What it does

FireStat is a browser-based analytics platform that lets fire departments and researchers explore NFIRS performance data without any software installation. All analysis runs client-side in JavaScript.

**Views:**
- Dashboard — national KPIs, response time distribution, containment by peer group
- Department Lookup — full performance profile vs. peer group and national benchmarks
- State Map — choropleth of any metric across all 51 states
- Multi-Dept Compare — pin up to 6 departments, radar + bar comparison
- Time Series — group trends by peer group, state, or department type
- Peer Groups — workload-adjusted comparisons within incident volume tiers
- Correlations — Pearson correlation matrix, auto-highlights strongest relationships
- Scatter Explorer — any two variables, colored by group, with OLS fit
- Regression — full OLS output with residual plot
- Rankings — top/bottom 5 per metric nationally
- Distributions — histogram, percentile curve, descriptive stats
- SQL Query — live queries against Supabase (requires `exec_sql` function)
- Raw Data — browse and filter all 9,733 departments

---

## Data

**Source:** NFIRS 2024 (National Fire Incident Reporting System)  
**Original:** 18,399 departments  
**Clean sample:** 9,733 departments (47% removed for data quality)

### Why departments were removed

NFIRS participation is voluntary and uneven. The 8,666 removed departments submitted incident counts but lacked usable performance data (null response times, null containment rates). They were not poor performers — they were non-reporters.

**Filter applied:**
```sql
-- XS / S / M peer groups
response_time BETWEEN 2 AND 45
AND containment_pct BETWEEN 1 AND 99
AND total_incidents >= 10

-- L / XL peer groups (major urban departments)
response_time BETWEEN 1 AND 45
AND total_incidents >= 100
```

Full methodology: `docs/NFIRS_Data_Quality_Filtering_Documentation.docx`

### Peer groups (incident volume tiers)

| Code | Range | n |
|------|-------|---|
| XS | < 500 incidents/year | 9,116 |
| S  | 500 – 2,000 | 516 |
| M  | 2,000 – 10,000 | 95 |
| L  | 10,000 – 50,000 | 5 |
| XL | > 50,000 | 1 |

---

## Setup

### 1. Create Supabase project

1. Go to [supabase.com](https://supabase.com) → New project
2. Open **SQL Editor** → paste and run `sql/01_schema.sql`
3. Go to **Settings → API** → copy your Project URL and `anon` key

### 2. Upload data

```bash
pip install supabase
export SUPABASE_URL="https://xxxxxxxxxxxx.supabase.co"
export SUPABASE_SERVICE_KEY="eyJ..."   # service key, not anon
python scripts/upload_to_supabase.py
```

This uploads all 9,733 departments in batches of 500. Takes ~2 minutes.

### 3. Enable GitHub Pages

1. Push this repo to GitHub
2. Go to **Settings → Pages → Source → GitHub Actions**
3. The workflow in `.github/workflows/deploy.yml` handles deployment automatically on every push to `main`
4. Your app will be live at `https://[username].github.io/firestat`

### 4. Open the app

Visit your GitHub Pages URL. On first load, enter your:
- **Supabase Project URL** (e.g. `https://xxxxxxxxxxxx.supabase.co`)
- **Supabase anon key** (the public key — safe for browsers)

These are saved to localStorage so you only enter them once per browser.

---

## Optional: Enable SQL Query tab

The SQL Query tab needs a helper function in Supabase to run arbitrary SQL from the browser. Run this in your Supabase SQL Editor:

```sql
CREATE OR REPLACE FUNCTION exec_sql(sql text)
RETURNS json LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE result json;
BEGIN
  EXECUTE 'SELECT json_agg(t) FROM (' || sql || ') t' INTO result;
  RETURN result;
END;
$$;
```

> ⚠️ This grants broad SQL access. Only use it if your Supabase project is private or you've restricted access appropriately. For public-facing deployments, remove or restrict this function.

---

## Repository structure

```
firestat/
├── index.html                  # Main app (single file, all JS inline)
├── data/
│   └── departments.csv         # Clean dataset (9,733 departments)
├── sql/
│   └── 01_schema.sql           # Supabase table schema + indexes + views
├── scripts/
│   └── upload_to_supabase.py   # Bulk upload script
├── docs/
│   └── NFIRS_Data_Quality_Filtering_Documentation.docx
└── .github/
    └── workflows/
        └── deploy.yml          # GitHub Pages auto-deploy
```

---

## Research context

Built for undergraduate economics research at Valparaiso University examining how fire departments convert resources (labor, capital) into service outcomes, using peer-comparative analytics across NFIRS national data.

Faculty sponsor: Prof. Devaraj, Economics Department  
Methodology: incident volume-based peer groups, workload-adjusted resource metrics, wealth-adjusted property loss

---

## License

Data: NFIRS is public domain (US Fire Administration).  
Code: MIT
