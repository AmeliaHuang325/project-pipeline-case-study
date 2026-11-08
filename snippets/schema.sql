-- Simplified schema (PostgreSQL)

CREATE TABLE projects (
    id                 BIGSERIAL PRIMARY KEY,
    project_code       TEXT UNIQUE NOT NULL,          -- e.g. 'P-2025-014'
    status             TEXT NOT NULL,                 -- proposal, submitted, awarded, active, closed
    funder             TEXT,
    lead               TEXT,
    co_lead            TEXT,
    partner_lead       TEXT,
    project_director   TEXT,
    probability        INTEGER CHECK (probability BETWEEN 0 AND 100),
    budget_total       NUMERIC(14, 2),
    budget_remaining   NUMERIC(14, 2),
    notes              TEXT,
    created_at         DATE NOT NULL DEFAULT CURRENT_DATE,
    last_updated_at    DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Change history
CREATE TABLE audit_log (
    id           BIGSERIAL PRIMARY KEY,
    project_id   BIGINT NOT NULL REFERENCES projects (id),
    field        TEXT NOT NULL,
    old_value    TEXT,
    new_value    TEXT,
    changed_by   TEXT NOT NULL,
    changed_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX audit_log_project_idx ON audit_log (project_id, changed_at DESC);

-- Example: recent changes
-- SELECT p.project_code, a.field, a.old_value, a.new_value, a.changed_by, a.changed_at
-- FROM audit_log a JOIN projects p ON p.id = a.project_id
-- ORDER BY a.changed_at DESC
-- LIMIT 50;
