CREATE TABLE IF NOT EXISTS ventilation_rooms (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE CHECK (length(trim(name)) > 0),
    sort_order INTEGER NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true
);

INSERT INTO ventilation_rooms (name, sort_order)
VALUES
    ('Wohnzimmer', 1),
    ('Schlafzimmer', 2),
    ('Flur', 3),
    ('Bad', 4),
    ('Küche', 5),
    ('GaesteBad', 6),
    ('Abstellkammer', 7),
    ('Witchy', 8)
ON CONFLICT (name) DO UPDATE SET
    sort_order = EXCLUDED.sort_order,
    active = true;

CREATE TABLE IF NOT EXISTS ventilation_entries (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    telegram_user_id BIGINT NOT NULL,
    room TEXT NOT NULL CHECK (length(trim(room)) > 0),
    ventilated_at TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    ventilation_method TEXT CHECK (
        ventilation_method IS NULL OR ventilation_method IN ('shock', 'cross', 'tilted_window', 'other')
    ),
    temperature_c NUMERIC(5, 2) CHECK (
        temperature_c IS NULL OR temperature_c BETWEEN -30 AND 80
    ),
    relative_humidity_percent NUMERIC(5, 2) CHECK (
        relative_humidity_percent IS NULL OR relative_humidity_percent BETWEEN 0 AND 100
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE ventilation_entries
    ADD COLUMN IF NOT EXISTS ventilation_method TEXT CHECK (
        ventilation_method IS NULL OR ventilation_method IN ('shock', 'cross', 'tilted_window', 'other')
    );

CREATE INDEX IF NOT EXISTS ventilation_entries_user_time_idx
    ON ventilation_entries (telegram_user_id, ventilated_at DESC);

CREATE TABLE IF NOT EXISTS telegram_conversations (
    telegram_user_id BIGINT PRIMARY KEY,
    chat_id BIGINT NOT NULL,
    state TEXT NOT NULL CHECK (
        state IN ('room', 'ventilated_at', 'duration', 'ventilation_method', 'temperature', 'humidity', 'confirm')
    ),
    draft JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE telegram_conversations
    DROP CONSTRAINT IF EXISTS telegram_conversations_state_check;

ALTER TABLE telegram_conversations
    ADD CONSTRAINT telegram_conversations_state_check CHECK (
        state IN ('room', 'ventilated_at', 'duration', 'ventilation_method', 'temperature', 'humidity', 'confirm')
    );
