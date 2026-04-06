-- FireStat NFIRS Analytics — Supabase Schema
-- Run this in Supabase SQL Editor before importing data
-- Source: NFIRS 2024, 9,733 departments (quality-filtered)

CREATE TABLE IF NOT EXISTS departments (
    state_fdid          TEXT PRIMARY KEY,
    state               TEXT,
    fdid                INTEGER,
    dept_name           TEXT,
    dept_type           TEXT,           -- Career | Volunteer | Combo
    total_incidents     INTEGER,
    fire_incidents      INTEGER,
    struct_fires        INTEGER,
    ems_incidents       INTEGER,
    response_time_avg   REAL,           -- minutes, alarm→arrival
    containment_rate    REAL,           -- % fires confined to room/floor/bldg
    prop_loss_adj       REAL,           -- wealth-adjusted property loss %
    prop_loss_usd       REAL,           -- raw property loss $
    total_ff            INTEGER,        -- total firefighters
    ff_per_1000_inc     REAL,           -- workload-adjusted staffing
    stations            INTEGER,
    sta_per_1000        REAL,
    career_pct          REAL,           -- % career staff
    civ_cas_per_1000    REAL,
    ff_inj_per_1000     REAL,
    data_quality        INTEGER,
    peer_group          TEXT,           -- XS | S | M | L | XL
    resp_np             REAL,           -- national percentile: response time
    cont_np             REAL,           -- national percentile: containment
    pl_np               REAL,           -- national percentile: prop loss
    ff1000_np           REAL,           -- national percentile: FF/1000
    resp_pp             REAL,           -- peer percentile: response time
    cont_pp             REAL,           -- peer percentile: containment
    pl_pp               REAL,           -- peer percentile: prop loss
    ff1000_pp           REAL            -- peer percentile: FF/1000
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_state       ON departments(state);
CREATE INDEX IF NOT EXISTS idx_peer_group  ON departments(peer_group);
CREATE INDEX IF NOT EXISTS idx_dept_type   ON departments(dept_type);
CREATE INDEX IF NOT EXISTS idx_resp_time   ON departments(response_time_avg);
CREATE INDEX IF NOT EXISTS idx_containment ON departments(containment_rate);
CREATE INDEX IF NOT EXISTS idx_incidents   ON departments(total_incidents);

-- Enable Row Level Security (read-only public access)
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access"
    ON departments FOR SELECT
    USING (true);

-- Helpful views
CREATE OR REPLACE VIEW state_summary AS
SELECT
    state,
    COUNT(*)                                AS dept_count,
    ROUND(AVG(response_time_avg)::numeric, 3) AS avg_response_time,
    ROUND(AVG(containment_rate)::numeric, 3)  AS avg_containment,
    ROUND(AVG(prop_loss_adj)::numeric, 3)     AS avg_prop_loss,
    ROUND(AVG(ff_per_1000_inc)::numeric, 3)   AS avg_ff_per_1000,
    ROUND(AVG(career_pct)::numeric, 3)         AS avg_career_pct,
    SUM(total_incidents)                        AS total_incidents,
    SUM(struct_fires)                           AS total_struct_fires
FROM departments
WHERE state IS NOT NULL
GROUP BY state
ORDER BY state;

CREATE OR REPLACE VIEW peer_summary AS
SELECT
    peer_group,
    COUNT(*)                                    AS dept_count,
    ROUND(AVG(response_time_avg)::numeric, 3)  AS avg_response_time,
    ROUND(AVG(containment_rate)::numeric, 3)   AS avg_containment,
    ROUND(AVG(prop_loss_adj)::numeric, 3)      AS avg_prop_loss,
    ROUND(AVG(ff_per_1000_inc)::numeric, 3)    AS avg_ff_per_1000,
    ROUND(MIN(response_time_avg)::numeric, 3)  AS min_rt,
    ROUND(MAX(response_time_avg)::numeric, 3)  AS max_rt,
    ROUND(MIN(containment_rate)::numeric, 3)   AS min_contain,
    ROUND(MAX(containment_rate)::numeric, 3)   AS max_contain
FROM departments
GROUP BY peer_group
ORDER BY peer_group;
