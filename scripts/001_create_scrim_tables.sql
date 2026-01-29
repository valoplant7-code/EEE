-- Scrim Notes table
CREATE TABLE IF NOT EXISTS scrim_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  map TEXT NOT NULL,
  side TEXT NOT NULL CHECK (side IN ('attack', 'defense', 'both')),
  category TEXT NOT NULL CHECK (category IN ('setup', 'execute', 'rotate', 'callout', 'timing', 'other')),
  content TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scrim Matches table
CREATE TABLE IF NOT EXISTS scrim_matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  opponent TEXT NOT NULL,
  map TEXT NOT NULL,
  our_score INTEGER NOT NULL DEFAULT 0,
  their_score INTEGER NOT NULL DEFAULT 0,
  result TEXT GENERATED ALWAYS AS (
    CASE 
      WHEN our_score > their_score THEN 'win'
      WHEN our_score < their_score THEN 'loss'
      ELSE 'draw'
    END
  ) STORED,
  notes TEXT,
  vod_link TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Player Stats table
CREATE TABLE IF NOT EXISTS player_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES scrim_matches(id) ON DELETE CASCADE,
  player_name TEXT NOT NULL,
  agent TEXT NOT NULL,
  kills INTEGER NOT NULL DEFAULT 0,
  deaths INTEGER NOT NULL DEFAULT 0,
  assists INTEGER NOT NULL DEFAULT 0,
  acs INTEGER NOT NULL DEFAULT 0,
  adr NUMERIC(5,1) NOT NULL DEFAULT 0,
  hs_percent NUMERIC(4,1) NOT NULL DEFAULT 0,
  first_kills INTEGER NOT NULL DEFAULT 0,
  first_deaths INTEGER NOT NULL DEFAULT 0,
  kast NUMERIC(4,1) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Uploaded Files tracking table
CREATE TABLE IF NOT EXISTS uploaded_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  filename TEXT NOT NULL,
  upload_date TIMESTAMPTZ DEFAULT NOW(),
  match_count INTEGER NOT NULL DEFAULT 0,
  player_stat_count INTEGER NOT NULL DEFAULT 0
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_scrim_notes_map ON scrim_notes(map);
CREATE INDEX IF NOT EXISTS idx_scrim_notes_category ON scrim_notes(category);
CREATE INDEX IF NOT EXISTS idx_scrim_matches_date ON scrim_matches(date);
CREATE INDEX IF NOT EXISTS idx_scrim_matches_map ON scrim_matches(map);
CREATE INDEX IF NOT EXISTS idx_player_stats_match_id ON player_stats(match_id);
CREATE INDEX IF NOT EXISTS idx_player_stats_player_name ON player_stats(player_name);

-- Disable RLS for this app (no auth required based on user's original code)
ALTER TABLE scrim_notes DISABLE ROW LEVEL SECURITY;
ALTER TABLE scrim_matches DISABLE ROW LEVEL SECURITY;
ALTER TABLE player_stats DISABLE ROW LEVEL SECURITY;
ALTER TABLE uploaded_files DISABLE ROW LEVEL SECURITY;
