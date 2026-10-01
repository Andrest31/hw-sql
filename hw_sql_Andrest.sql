/*
ФИО: Андрест Владислав Дмитриевич
Вариант: 2

Условие:
Необходимо создать базу данных для хранения информации о соревнованиях
Формулы-1: календаре чемпионата, гонщиках, командах и результатах гонок.

В одной стране в течение одного года может проводиться несколько Гран-при.
Состав команды в течение одного года не меняется.


Описание структуры базы данных:

База данных состоит из шести таблиц: seasons, drivers, teams,
grand_prix, team_lineups и race_results.

1. seasons
Хранит сезоны чемпионата. Для каждого сезона указывается год.
Отдельная таблица сезонов нужна, чтобы можно было привязать к конкретному
году календарь Гран-при и составы команд.

2. drivers
Хранит информацию о гонщиках: имя, фамилию, дату рождения,
страну и количество побед.

3. teams
Хранит основную информацию о командах: название команды,
производителя двигателя и страну происхождения.

Гонщики не записываются непосредственно в teams, потому что состав
одной команды может быть разным в разные годы.

4. grand_prix
Хранит календарь чемпионата. Каждый Гран-при относится к определённому
сезону через season_id.

Для Гран-при хранятся название, номер этапа, дата проведения,
страна и место проведения.

Связь seasons -> grand_prix является связью "один ко многим":
в одном сезоне проводится много Гран-при, но каждый Гран-при
относится к одному сезону.

5. team_lineups
Хранит составы команд по сезонам.

Таблица связывает season, team и driver и показывает, какой гонщик
выступает за какую команду в конкретном сезоне.

Также здесь хранится роль гонщика:
main — основной гонщик;
reserve — запасной гонщик.

Для основного гонщика указывается номер машины, а для запасного
номер машины отсутствует.

Такая отдельная таблица позволяет хранить разные составы команды
в разные годы и при этом фиксировать состав внутри одного сезона.

6. race_results
Хранит результаты гонщиков на каждом Гран-при.

Таблица связывает grand_prix и driver. Для результата хранятся:
занятое место, заработанные очки, время прохождения гонки
или причина схода, а также количество кругов лидирования.

Один гонщик может участвовать во многих Гран-при, а один Гран-при
содержит результаты многих гонщиков. Поэтому race_results реализует
связь "многие ко многим" между гонщиками и Гран-при.


Основные связи:

seasons -> grand_prix
Один сезон содержит несколько Гран-при.

seasons -> team_lineups
В каждом сезоне определяются составы команд.

teams -> team_lineups <- drivers
Таблица team_lineups связывает команды с их гонщиками.

grand_prix -> race_results <- drivers
Таблица race_results связывает гонщиков с конкретными Гран-при
и хранит результаты их участия.


Основные ограничения:

- год сезона должен быть уникальным;
- номер этапа должен быть уникальным внутри одного сезона;
- в одной стране разрешено проведение нескольких Гран-при за год;
- количество побед, очков и кругов лидирования не может быть отрицательным;
- основной гонщик должен иметь номер машины;
- запасной гонщик не должен иметь номер машины;
- один гонщик не может дважды присутствовать в результатах одного Гран-при;
- для результата указывается либо время прохождения гонки,
  либо причина схода.
*/


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
