CREATE OR REPLACE 
    ALGORITHM = MERGE 
    DEFINER = CURRENT_USER 
VIEW mc_view_playerinfo AS
    SELECT 
        players.id AS 'UserID',
        players.mc_username AS 'MinecraftUsername',
        COALESCE(CASE mc_username
                    WHEN 'alphawolf918' THEN 'Paul'
                    WHEN 'nascarmpfan' THEN 'Mike'
                    WHEN 'master_zane' THEN 'Jon'
                    WHEN 'lazy_logic' THEN 'Catie'
                    WHEN 'ChronoxShift' THEN 'Danny'
                    ELSE NULL
                END,
                'Unknown') AS 'PlayerName',
        players.uid AS 'MCUID',
        CASE players.permissions
            WHEN 0 THEN 'Placeholder'
            WHEN 1 THEN 'User'
            WHEN 2 THEN 'Premium User'
            WHEN 3 THEN 'Lower Moderator'
            WHEN 4 THEN 'High Moderator'
            WHEN 5 THEN 'Administrator'
            WHEN 6 THEN 'Super User'
            ELSE 'Uninitialized'
        END AS 'AuthLevel',
        players.remote_addr AS 'UserIP',
        CONCAT('$',
                CAST(COALESCE(FORMAT(accounts.dollar_balance, 2), 0.00)
                    AS CHAR (21))) AS 'Money',
        CONCAT(UCASE(LEFT(accounts.job, 1)),
                LCASE(SUBSTRING(accounts.job, 2))) AS 'Job',
        CAST(CASE accounts.job
                WHEN 'miner' THEN experience.miner
                WHEN 'lumberjack' THEN experience.lumberjack
                WHEN 'warrior' THEN experience.warrior
                WHEN 'fisherman' THEN experience.fisherman
                ELSE 0
            END
            AS DECIMAL (10 , 2 )) AS 'JobXP',
        DATE_FORMAT(CONVERT_TZ(players.date_added, '+00:00', '-04:00'),
                '%W, %M %e, %Y @ %h:%i %p') AS 'DateAdded',
        DATE_FORMAT(CONVERT_TZ(players.date_modified,
                        '+00:00',
                        '-04:00'),
                '%W, %M %e, %Y @ %h:%i %p') AS 'DateModified',
        CASE accounts.job
            WHEN 'miner' THEN levels.miner
            WHEN 'lumberjack' THEN levels.lumberjack
            WHEN 'warrior' THEN levels.warrior
            WHEN 'fisherman' THEN levels.fisherman
            ELSE 0
        END AS 'JobLevel',
        IF(accounts.job_notifications = 0,
            'No',
            'Yes') AS 'ShowJobNotifications',
        COALESCE(player_homes.pos_x, 0) AS 'HomePosX',
        COALESCE(player_homes.pos_y, 70) AS 'HomePosY',
        COALESCE(player_homes.pos_z, 0) AS 'HomePosZ',
        COALESCE((SELECT 
                        name
                    FROM
                        worlds
                    WHERE
                        id = player_homes.world_id),
                'world') AS 'HomeWorld',
        COALESCE(player_homes.dim_id, 0) AS 'HomeDimension',
        player_stats.health AS 'Health',
        player_stats.attack AS 'AttackDamage',
        player_stats.defense AS 'Defense',
        player_stats.jump_height AS 'JumpHeight',
        player_stats.fall_resistance AS 'FallResistance',
        player_stats.fortune AS 'Fortune',
        player_stats.player_level AS 'PowerLevel',
        player_stats.player_xp AS 'PlayerXP',
        worlds.name AS 'CurrentWorld',
        (SELECT 
                player_inventory.inventory
            FROM
                player_inventory
            WHERE
                userid = players.id AND dim_id = 0) AS 'SurvivalInventory',
        (SELECT 
                player_inventory.inventory
            FROM
                player_inventory
            WHERE
                userid = players.id AND dim_id = - 9999) AS 'CreativeInventory',
        (SELECT 
                player_inventory.inventory
            FROM
                player_inventory
            WHERE
                userid = players.id AND dim_id = 3) AS 'HarranInventory',
        (SELECT 
                COUNT(id)
            FROM
                player_mail
            WHERE
                to_userid = players.id) AS 'MessagesReceived',
        (SELECT 
                COUNT(id)
            FROM
                player_mail
            WHERE
                from_userid = players.id) AS 'MessagesSent'
    FROM
        players
            INNER JOIN
        accounts ON (players.uid = accounts.uid)
            LEFT JOIN
        experience ON (accounts.uid = experience.uid)
            LEFT JOIN
        levels ON (experience.uid = levels.uid)
            LEFT JOIN
        player_homes ON (players.id = player_homes.userid)
            LEFT JOIN
        player_stats ON (players.id = player_stats.userid)
            LEFT JOIN
        player_inventory ON (players.inv_id = player_inventory.id)
            LEFT JOIN
        worlds ON (players.world_id = worlds.id)
            LEFT JOIN
        player_mail ON (players.id = player_mail.to_userid
            AND players.id = player_mail.from_userid)
    WHERE
        players.uid <> ''
    ORDER BY players.mc_username ASC;