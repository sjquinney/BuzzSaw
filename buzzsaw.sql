DROP TABLE log;
DROP TABLE event;
DROP TABLE tag;

CREATE DOMAIN BASE64 AS VARCHAR(200) CHECK( VALUE ~ '^[A-Za-z0-9+/:_.-]+$' );

BEGIN;

CREATE TABLE log (
    id       SERIAL                        PRIMARY KEY,
    name     VARCHAR(200)                  NOT NULL,
    digest   BASE64                        NOT NULL UNIQUE,
    CONSTRAINT name_digest UNIQUE(name,digest)
);

CREATE INDEX log_name ON log (name);

CREATE TABLE current_processing (
    id        SERIAL                       PRIMARY KEY,
    name      VARCHAR(200)                 NOT NULL UNIQUE,
    starttime TIMESTAMP WITH TIME ZONE     NOT NULL DEFAULT current_timestamp
);

CREATE OR REPLACE FUNCTION register_current_processing(n current_processing.name%TYPE) RETURNS void AS $$
DECLARE logcount INTEGER;
BEGIN

    LOCK TABLE current_processing IN ACCESS EXCLUSIVE MODE;

    -- Timeout any processing entries after 1 hour
    DELETE FROM current_processing
      WHERE starttime < current_timestamp - interval '1 hour';

    SELECT COUNT(*) INTO logcount
      FROM current_processing
      WHERE name = n;

    IF logcount > 0 THEN
      RAISE EXCEPTION 'File already being processed';
    ELSE
      INSERT INTO current_processing (name) VALUES (n);
    END IF;

END;
$$  LANGUAGE plpgsql;

CREATE TABLE event (
    id       SERIAL                        PRIMARY KEY,
    raw      VARCHAR(1000)                 NOT NULL,
    digest   BASE64                        NOT NULL UNIQUE,
    logtime  TIMESTAMP WITH TIME ZONE      NOT NULL,
    hostname VARCHAR(100)                  NOT NULL,
    message  VARCHAR(1000)                 NOT NULL,
    program  VARCHAR(100),
    pid      INTEGER,
    userid   VARCHAR(20)     
);

CREATE TABLE tag (
    id       SERIAL                        PRIMARY KEY,
    name     VARCHAR(20)                   NOT NULL,
    event    INTEGER                       NOT NULL REFERENCES event(id),
    CONSTRAINT name_event UNIQUE(name,event)
);

COMMIT;
