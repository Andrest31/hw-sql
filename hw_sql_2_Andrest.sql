/*
ФИО: Андрест Владислав Дмитриевич
Вариант: 2

Задание 1: Выбрать гонщиков, занявших первое место и набравших меньше 26 очков,
отсортировав по убыванию количества кругов лидирования.

Задание 2: Выбрать имена и фамилии всех гонщиков и сумму очков,
набранных по результатам гонок, в порядке убывания.

ЗАПУСК: psql -d formula1_hw2 -v ON_ERROR_STOP=1 -f hw_sql_2_Andrest.sql
*/

DROP TABLE IF EXISTS race_results, team_lineups, grand_prix, teams, drivers, seasons CASCADE;

CREATE TABLE seasons (
    season_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    year INTEGER NOT NULL UNIQUE
        CHECK (year >= 1950)
);


CREATE TABLE drivers (
    driver_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    country VARCHAR(100) NOT NULL,
    wins INTEGER NOT NULL DEFAULT 0
        CHECK (wins >= 0)
);


CREATE TABLE teams (
    team_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    engine_manufacturer VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);


CREATE TABLE grand_prix (
    grand_prix_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    season_id INTEGER NOT NULL,
    name VARCHAR(150) NOT NULL,
    round_number INTEGER NOT NULL
        CHECK (round_number > 0),
    race_date DATE NOT NULL,
    country VARCHAR(100) NOT NULL,
    location VARCHAR(150) NOT NULL,

    FOREIGN KEY (season_id)
        REFERENCES seasons(season_id),

    UNIQUE (season_id, round_number)
);


CREATE TABLE team_lineups (
    lineup_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    season_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    role VARCHAR(10) NOT NULL,
    car_number INTEGER,

    FOREIGN KEY (season_id)
        REFERENCES seasons(season_id),

    FOREIGN KEY (team_id)
        REFERENCES teams(team_id),

    FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id),

    CHECK (role IN ('main', 'reserve')),

    CHECK (
        (role = 'main' AND car_number IS NOT NULL)
        OR
        (role = 'reserve' AND car_number IS NULL)
    ),

    CHECK (
        car_number IS NULL
        OR car_number BETWEEN 1 AND 99
    ),

    UNIQUE (season_id, driver_id),
    UNIQUE (season_id, team_id, car_number)
);


CREATE TABLE race_results (
    result_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    grand_prix_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    position INTEGER,
    points NUMERIC(5, 2) NOT NULL DEFAULT 0,
    race_time INTERVAL,
    retirement_reason TEXT,
    laps_led INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (grand_prix_id)
        REFERENCES grand_prix(grand_prix_id),

    FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id),

    UNIQUE (grand_prix_id, driver_id),

    CHECK (
        position IS NULL
        OR position > 0
    ),

    CHECK (points >= 0),

    CHECK (laps_led >= 0),

    CHECK (
        (race_time IS NOT NULL AND retirement_reason IS NULL)
        OR
        (race_time IS NULL AND retirement_reason IS NOT NULL)
    )
);


-- Наполнение таблиц (не менее 5 записей в каждой)
INSERT INTO seasons (year) VALUES (2021), (2022), (2023), (2024), (2025);

INSERT INTO drivers (last_name, first_name, birth_date, country, wins) VALUES
('Verstappen', 'Max', '1997-09-30', 'Netherlands', 63),
('Hamilton', 'Lewis', '1985-01-07', 'United Kingdom', 105),
('Leclerc', 'Charles', '1997-10-16', 'Monaco', 8),
('Norris', 'Lando', '1999-11-13', 'United Kingdom', 4),
('Piastri', 'Oscar', '2001-04-06', 'Australia', 2);

INSERT INTO teams (name, engine_manufacturer, country) VALUES
('Red Bull Racing', 'Honda', 'Austria'),
('Ferrari', 'Ferrari', 'Italy'),
('McLaren', 'Mercedes', 'United Kingdom'),
('Mercedes', 'Mercedes', 'Germany'),
('Aston Martin', 'Mercedes', 'United Kingdom');

INSERT INTO grand_prix (season_id, name, round_number, race_date, country, location) VALUES
(4, 'Bahrain Grand Prix', 1, '2024-03-02', 'Bahrain', 'Sakhir'),
(4, 'Saudi Arabian Grand Prix', 2, '2024-03-09', 'Saudi Arabia', 'Jeddah'),
(4, 'Australian Grand Prix', 3, '2024-03-24', 'Australia', 'Melbourne'),
(5, 'Australian Grand Prix', 1, '2025-03-16', 'Australia', 'Melbourne'),
(5, 'Chinese Grand Prix', 2, '2025-03-23', 'China', 'Shanghai');

INSERT INTO team_lineups (season_id, team_id, driver_id, role, car_number) VALUES
(4, 1, 1, 'main', 1),
(4, 4, 2, 'main', 44),
(4, 2, 3, 'main', 16),
(4, 3, 4, 'main', 4),
(4, 3, 5, 'main', 81),
(5, 1, 1, 'main', 1),
(5, 2, 2, 'main', 44),
(5, 2, 3, 'main', 16),
(5, 3, 4, 'main', 4),
(5, 3, 5, 'main', 81);

INSERT INTO race_results
(grand_prix_id, driver_id, position, points, race_time, retirement_reason, laps_led) VALUES
(1, 1, 1, 25, INTERVAL '1 hour 31 minutes', NULL, 50),
(1, 2, 2, 18, INTERVAL '1 hour 32 minutes', NULL, 5),
(1, 3, 3, 15, INTERVAL '1 hour 33 minutes', NULL, 2),
(1, 4, 4, 12, INTERVAL '1 hour 34 minutes', NULL, 0),
(1, 5, NULL, 0, NULL, 'Engine failure', 0),
(2, 1, 1, 25, INTERVAL '1 hour 20 minutes', NULL, 45),
(2, 3, 2, 18, INTERVAL '1 hour 21 minutes', NULL, 5),
(2, 4, 3, 15, INTERVAL '1 hour 22 minutes', NULL, 0),
(2, 2, 4, 12, INTERVAL '1 hour 23 minutes', NULL, 0),
(2, 5, 5, 10, INTERVAL '1 hour 24 minutes', NULL, 0),
(3, 3, 1, 25, INTERVAL '1 hour 40 minutes', NULL, 30),
(3, 4, 2, 18, INTERVAL '1 hour 41 minutes', NULL, 15),
(3, 5, 3, 15, INTERVAL '1 hour 42 minutes', NULL, 5),
(3, 2, 4, 12, INTERVAL '1 hour 43 minutes', NULL, 0),
(3, 1, NULL, 0, NULL, 'Brake failure', 0),
(4, 4, 1, 25, INTERVAL '1 hour 35 minutes', NULL, 40),
(4, 1, 2, 18, INTERVAL '1 hour 36 minutes', NULL, 10),
(4, 5, 3, 15, INTERVAL '1 hour 37 minutes', NULL, 5),
(4, 3, 4, 12, INTERVAL '1 hour 38 minutes', NULL, 0),
(4, 2, 5, 10, INTERVAL '1 hour 39 minutes', NULL, 0),
(5, 5, 1, 25, INTERVAL '1 hour 30 minutes', NULL, 35),
(5, 4, 2, 18, INTERVAL '1 hour 31 minutes', NULL, 15),
(5, 1, 3, 15, INTERVAL '1 hour 32 minutes', NULL, 5),
(5, 3, 4, 12, INTERVAL '1 hour 33 minutes', NULL, 0),
(5, 2, NULL, 0, NULL, 'Collision', 0);

-- Задание 1
SELECT d.first_name, d.last_name, r.position, r.points, r.laps_led
FROM race_results AS r
JOIN drivers AS d ON r.driver_id = d.driver_id
WHERE r.position = 1 AND r.points < 26
ORDER BY r.laps_led DESC;

-- Задание 2
SELECT d.first_name, d.last_name, COALESCE(SUM(r.points), 0) AS total_points
FROM drivers AS d
LEFT JOIN race_results AS r ON d.driver_id = r.driver_id
GROUP BY d.driver_id, d.first_name, d.last_name
ORDER BY total_points DESC;
