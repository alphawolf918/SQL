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

DELIMITER $ 
DROP FUNCTION IF EXISTS GetInventory$
CREATE DEFINER = CURRENT_USER FUNCTION GetInventory(passed_dimid INT(11), passed_userid INT(11)) RETURNS LONGTEXT
	BEGIN
		RETURN (SELECT inventory FROM player_inventory WHERE dim_id = passed_dimid AND userid = passed_userid);
	END;
	
DELIMITER $
DROP FUNCTION IF EXISTS UC_FIRST$
CREATE DEFINER = CURRENT_USER FUNCTION UC_FIRST (passed_word VARCHAR(255)) RETURNS VARCHAR(255) CHARSET utf8
	BEGIN
		RETURN CONCAT(UCASE(LEFT(passed_word, 1)), LCASE(SUBSTRING(passed_word, 2)));
	END;

DELIMITER $
DROP FUNCTION IF EXISTS GetUserIDByUID$
CREATE DEFINER = CURRENT_USER FUNCTION GetUserIDByUID (passed_uid VARCHAR(200)) RETURNS INT(11)
	BEGIN
		DECLARE userID INT(11);
		SET userID := (SELECT id FROM players WHERE `uid` = passed_uid ORDER BY id DESC LIMIT 1);
		RETURN COALESCE(userID, 0);
	END;

DELIMITER $
DROP FUNCTION IF EXISTS GetUIDByUserID$
CREATE DEFINER = CURRENT_USER FUNCTION GetUIDByUserID (passed_userid INT(11)) RETURNS CHAR(80)
	BEGIN
		DECLARE theUID CHAR(80);
		SET theUID := (SELECT uid FROM players WHERE id = passed_userid);
		RETURN COALESCE(theUID, "empty");
	END;

CREATE TABLE IF NOT EXISTS player_warps (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	userid INT NOT NULL,
	date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
	warp_name VARCHAR(25) NOT NULL,
	warp_category VARCHAR(20) DEFAULT 'master' NOT NULL,
	pos_x VARCHAR(20) DEFAULT '0' NOT NULL,
	pos_y VARCHAR(20) DEFAULT '0' NOT NULL,
	pos_z VARCHAR(20) DEFAULT '0' NOT NULL,
	pitch VARCHAR(5) DEFAULT '0' NOT NULL,
	yaw VARCHAR(5) DEFAULT '0' NOT NULL,
	world_id INT DEFAULT 1 NOT NULL,
	dim_id INT NOT NULL,
	permssions INT DEFAULT 1 NOT NULL,
	can_warp BOOLEAN DEFAULT 1 NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
			REFERENCES players(id)
				ON UPDATE CASCADE
				ON DELETE CASCADE,
	INDEX p_world_id (world_id),
	FOREIGN KEY fk_world_id (world_id)
			REFERENCES worlds(id)
				ON UPDATE CASCADE
				ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS player_homes (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	userid INT NOT NULL UNIQUE,
	date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
		ON UPDATE CURRENT_TIMESTAMP NOT NULL,
	pos_x VARCHAR(20) DEFAULT '0' NOT NULL,
	pos_y VARCHAR(20) DEFAULT '0' NOT NULL,
	pos_z VARCHAR(20) DEFAULT '0' NOT NULL,
	pitch VARCHAR(5) DEFAULT '0' NOT NULL,
	yaw VARCHAR(5) DEFAULT '0' NOT NULL,
	world_id INT DEFAULT 1 NOT NULL,
	dim_id INT NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
			REFERENCES players(id)
				ON UPDATE CASCADE
				ON DELETE CASCADE,
	INDEX p_world_id (world_id),
	FOREIGN KEY fk_world_id (world_id)
			REFERENCES worlds(id)
				ON UPDATE CASCADE
				ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS player_stats (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	userid INT NOT NULL UNIQUE,
	health DOUBLE DEFAULT 20.0 NOT NULL,
	attack DOUBLE DEFAULT 1.0 NOT NULL,
	defense DOUBLE DEFAULT 0.0 NOT NULL,
	jump_height DOUBLE DEFAULT 0.5 NOT NULL,
	fall_resistance DOUBLE DEFAULT 0.0 NOT NULL,
	fortune DOUBLE DEFAULT 0.0 NOT NULL,
	player_level INT DEFAULT 1 NOT NULL,
	player_xp BIGINT DEFAULT 0 NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
			REFERENCES players(id)
				ON UPDATE CASCADE
				ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS player_inventory (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	userid INT NOT NULL,
	inventory LONGTEXT NOT NULL,
	world_id INT DEFAULT 1 NOT NULL,
	dim_id INT NOT NULL,
	gamemode INT NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
			REFERENCES players(id)
				ON UPDATE CASCADE
				ON DELETE CASCADE,
	INDEX p_world_id (world_id),
	FOREIGN KEY fk_world_id (world_id)
			REFERENCES worlds(id)
				ON UPDATE CASCADE
				ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS worlds (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(35) DEFAULT 'world' NOT NULL,
	gamemode INT DEFAULT 0 NOT NULL,
	world_data TEXT NULL
);

DELIMITER $
DROP PROCEDURE IF EXISTS CreateWorldInventories$
CREATE DEFINER = CURRENT_USER PROCEDURE CreateWorldInventories(IN passed_userid INT)
BEGIN
	-- SURVIVAL
	INSERT INTO player_inventory
		(userid, inventory, world_id, dim_id, gamemode)
	VALUES
		(passed_userid, '', 1, 0, 0);
	-- CREATIVE
	INSERT INTO player_inventory
		(userid, inventory, world_id, dim_id, gamemode)
	VALUES
		(passed_userid, '', 1, -9999, 1);
	-- HARRAN
	INSERT INTO player_inventory
		(userid, inventory, world_id, dim_id, gamemode)
	VALUES
		(passed_userid, '', 1, 3, 2);
END;

DELIMITER $
DROP PROCEDURE IF EXISTS SendMessage$
CREATE DEFINER = CURRENT_USER PROCEDURE SendMessage (IN p_from_userid INT, IN p_to_userid INT, IN to_message VARCHAR(255))
BEGIN
	INSERT INTO player_mail (from_userid, to_userid, message) VALUES (p_from_userid, p_to_userid, to_message);
END;

DELIMITER $
DROP TRIGGER IF EXISTS SetupUser$
CREATE TRIGGER SetupUser
	   AFTER INSERT
	   ON players
	FOR EACH ROW
	BEGIN
		SET FOREIGN_KEY_CHECKS = 0;
		SET @p := COALESCE((SELECT mc_username
							FROM players
							WHERE id = NEW.id),
				        'undefined');
		IF @p <> 'undefined' THEN
			-- Setup inventories.
			CALL CreateWorldInventories(NEW.id);
			-- Add stats.
			INSERT INTO player_stats (userid) VALUES (NEW.id);
			-- Send them a welcome message.
			CALL SendMessage(0, NEW.id, 'Welcome to the Minecraft Server! We Aim2Please.');
		END IF;
	END;

DELIMITER $
DROP TRIGGER IF EXISTS CreatePlayer$
CREATE TRIGGER CreatePlayer
AFTER INSERT
ON accounts
	FOR EACH ROW
	BEGIN
			INSERT INTO players(mc_username, remote_addr, permissions, `uid`, world_id)
			VALUES ('', '', 1, NEW.uid, 1);
	END;

CREATE TABLE IF NOT EXISTS player_mail (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	from_userid INT NOT NULL,
	to_userid INT NOT NULL,
	message TEXT NOT NULL,
	unread BOOLEAN DEFAULT TRUE NOT NULL,
	INDEX p_to_userid (to_userid),
	FOREIGN KEY fk_to_userid (to_userid)
		REFERENCES players(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	INDEX p_from_userid (from_userid),
	FOREIGN KEY fk_from_userid (from_userid)
		REFERENCES players(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

ALTER TABLE players
ADD CONSTRAINT chk_perms
CHECK (permissions <= 6);

-- 

DELIMITER $$
DROP PROCEDURE IF EXISTS LoopFrom$$
CREATE DEFINER = CURRENT_USER PROCEDURE LoopFrom(IN start_number INT, IN stop_number INT)
BEGIN
	SET @x = start_number;
	SET @y = stop_number;
	SET @str = '';
	WHILE @x <= @y DO
		SET @str = CONCAT(@str, @x);
		IF(@x < @y) THEN
			SET @str = CONCAT(@str, ', ');
		END IF;
		SET @x = @x + 1;
	END WHILE;
	SELECT @str AS "Results";
END;

DELIMITER $$
DROP PROCEDURE IF EXISTS CountTotalMoney$$
CREATE DEFINER = CURRENT_USER PROCEDURE CountTotalMoney(OUT total INT)
BEGIN
	SELECT SUM(accounts.dollar_balance) INTO total FROM accounts;
END;

DELIMITER //
DROP FUNCTION IF EXISTS GetTotalMoney//
CREATE DEFINER = CURRENT_USER FUNCTION GetTotalMoney() RETURNS CHAR(80)
BEGIN
	CALL CountTotalMoney(@total);
	SET @formattedTotal = CONCAT('$', CAST(COALESCE(FORMAT(@total, 2), 0.00) AS CHAR (80)));
	RETURN @formattedTotal;
END;