CREATE OR REPLACE VIEW soloq.model_training_early_events AS
SELECT
    -- tracking columns, do not use as model features
    uuid,
    match_id,
    puuid,

    -- target
    CASE 
        WHEN win = TRUE THEN 1 
        ELSE 0 
    END AS win_label,

    -- pre-game / basic context
    champion_name,
    team_position,
    side,
    patch,

    -- first blood event
    CASE 
        WHEN team_first_blood = TRUE THEN 1 
        ELSE 0 
    END AS team_first_blood,

    CASE 
        WHEN enemy_first_blood = TRUE THEN 1 
        ELSE 0 
    END AS enemy_first_blood,

    CASE
        WHEN team_first_blood = TRUE THEN 1
        WHEN enemy_first_blood = TRUE THEN -1
        ELSE 0
    END AS first_blood_advantage,

    -- first dragon
    CASE 
        WHEN dragon_first = TRUE THEN 1 
        ELSE 0 
    END AS team_first_dragon,

    CASE 
        WHEN enemy_dragon_first = TRUE THEN 1 
        ELSE 0 
    END AS enemy_first_dragon,

    CASE
        WHEN dragon_first = TRUE THEN 1
        WHEN enemy_dragon_first = TRUE THEN -1
        ELSE 0
    END AS first_dragon_advantage,

    -- first grubs
    CASE 
        WHEN grub_first = TRUE THEN 1 
        ELSE 0 
    END AS team_first_grub,

    CASE 
        WHEN enemy_grub_first = TRUE THEN 1 
        ELSE 0 
    END AS enemy_first_grub,

    CASE
        WHEN grub_first = TRUE THEN 1
        WHEN enemy_grub_first = TRUE THEN -1
        ELSE 0
    END AS first_grub_advantage,

    -- first herald
    CASE 
        WHEN herald_first = TRUE THEN 1 
        ELSE 0 
    END AS team_first_herald,

    CASE 
        WHEN enemy_herald_first = TRUE THEN 1 
        ELSE 0 
    END AS enemy_first_herald,

    CASE
        WHEN herald_first = TRUE THEN 1
        WHEN enemy_herald_first = TRUE THEN -1
        ELSE 0
    END AS first_herald_advantage,

    -- first tower
    CASE 
        WHEN tower_first = TRUE THEN 1 
        ELSE 0 
    END AS team_first_tower,

    CASE 
        WHEN enemy_tower_first = TRUE THEN 1 
        ELSE 0 
    END AS enemy_first_tower,

    CASE
        WHEN tower_first = TRUE THEN 1
        WHEN enemy_tower_first = TRUE THEN -1
        ELSE 0
    END AS first_tower_advantage

FROM soloq.match_data
WHERE win IS NOT NULL
  AND champion_name IS NOT NULL
  AND champion_name <> ''
  AND team_position IS NOT NULL
  AND team_position <> ''
  AND game_duration >= 300;

SELECT *
FROM soloq.model_training_early_events