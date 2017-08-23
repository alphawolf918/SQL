CREATE OR REPLACE VIEW gn_view_userdata AS
    SELECT 
        accounts.id AS 'ID',
        accounts.employee_name AS 'EmployeeName',
        accounts.LOGON_USER AS 'LogonUser',
        COALESCE(CASE accounts.computer_name
                    WHEN 0 THEN 'Not set'
                    ELSE accounts.computer_name
                END,
                'Not set') AS 'ComputerName',
        CASE accounts.email
            WHEN '0' THEN 'Not set'
            ELSE accounts.email
        END AS 'Email',
        COALESCE(DATE_FORMAT(accounts.hiredate, '%W, %M %e, %Y'),
                'Not set') AS 'HireDate',
        COALESCE(DATE_FORMAT(accounts.birthday, '%W, %M %e'),
                'Not set') AS 'Birthday',
        DATE_FORMAT(accounts.last_active,
                '%W, %M %e, %Y @ %h:%i %p') AS 'LastActive',
        CASE accounts.phone
            WHEN 0 THEN 'Not set'
            ELSE accounts.phone
        END AS 'WorkPhone',
        IF(user_settings.ae_new = 'y',
            'New',
            'Old') AS 'EventsInterface',
        IF(user_settings.do_site_refresh = 1,
            'Yes',
            'No') AS 'ShouldRefresh',
        IF(user_settings.show_weather_widget = 1,
            'Yes',
            'no') AS 'ShowWeatherWidget',
        COALESCE(CONCAT(UCASE(LEFT(user_settings.notification_type, 1)),
                        LCASE(SUBSTRING(user_settings.notification_type,
                                    2))),
                'Not set') AS 'NotificationType',
        (SELECT 
                COUNT(suggestions.id)
            FROM
                suggestions
            WHERE
                suggestions.userid = accounts.id) AS 'NumSuggestions'
    FROM
        accounts
            LEFT JOIN
        user_settings ON (accounts.id = user_settings.userid)
    WHERE
        accounts.LOGON_USER <> '0'
    ORDER BY employee_name ASC;

DELIMITER $

DROP FUNCTION IF EXISTS `GetIDByEmail`$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetIDByEmail`(`passed_email` VARCHAR(100)) RETURNS INT(11)
	BEGIN
		DECLARE theID INT(11);
		SET theID = (SELECT id FROM accounts WHERE email = passed_email);
		RETURN COALESCE(theID, 0);
	END$

DROP FUNCTION IF EXISTS `GetEmployeeNameByLogon`$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetEmployeeNameByLogon`(passed_logon_user VARCHAR(50)) RETURNS VARCHAR(50) CHARSET utf8
	BEGIN
		DECLARE employeeName VARCHAR(50);
		SET employeeName = (SELECT employee_name FROM accounts WHERE LOGON_USER = passed_logon_user);
		RETURN COALESCE(employeeName, 'Unknown');
	END$

DROP FUNCTION IF EXISTS `GetUserID`$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetUserID`(passed_logon_user VARCHAR(35)) RETURNS INT(11)
	BEGIN
		DECLARE theID INT;
		SET theID = (SELECT id FROM accounts WHERE LOGON_USER = passed_logon_user);
		RETURN theID;
	END$

COPY accounts AS bk_accounts;

XML EXPORT accounts AS accounts.xml;

CUT bk_accounts INTO accounts_2;

DROP FUNCTION IF EXISTS `GetUserLogon`$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetUserLogon`(passed_id INT) RETURNS VARCHAR(50) CHARSET utf8
	BEGIN
		DECLARE theLU VARCHAR(50);
		SET theLU = (SELECT LOGON_USER FROM accounts WHERE id = passed_id);
        RETURN COALESCE(theLU, 'Unknown');
	END$

DROP FUNCTION IF EXISTS `GetEmployeeNameById`$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetEmployeeNameById`(passed_id INT) RETURNS VARCHAR(50) CHARSET utf8
	BEGIN
		DECLARE employeeName VARCHAR(50);
		SET employeeName = (SELECT employee_name FROM accounts WHERE id = passed_id);
		RETURN COALESCE(employeeName, 'Unknown');
	END$

DROP FUNCTION IF EXISTS `GetIDByEmployeeName`$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetIDByEmployeeName`(passed_employee_name VARCHAR(50)) RETURNS INT
	BEGIN
		DECLARE theID INT;
		SET theID = (SELECT id FROM accounts WHERE employee_name = passed_employee_name);
		RETURN COALESCE(theID, 0);
	END

DELIMITER ;

/*
Procedures
*/

DELIMITER $

DROP PROCEDURE IF EXISTS `GetUserDataById`$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserDataById`(IN `passed_id` INT)
BEGIN
	SELECT * FROM accounts WHERE id = passed_id;
END$

DROP PROCEDURE IF EXISTS `GetUserDataByLogon`$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserDataByLogon`(IN `passed_logon_user` VARCHAR(35))
BEGIN
	SELECT * FROM accounts WHERE LOGON_USER = passed_logon_user;
END$

DROP PROCEDURE IF EXISTS `NewVariable`$
CREATE DEFINER=`root`@`localhost` PROCEDURE `NewVariable`(IN `var_name` VARCHAR(35), IN `var_value` TEXT, `data_type` VARCHAR(20))
BEGIN
	IF `data_type` IS NULL THEN
		SET @varType := 'string';
	ELSE
		SET @varType := `data_type`;
	END IF;
	SET @CheckQuery := (SELECT COUNT(id) FROM variables WHERE name = `var_name`);
	IF @CheckQuery > 0 THEN
		UPDATE variables SET `value` = `var_value`, `datatype` = @varType, `about` = 'via script' WHERE `name` = `var_name`;
	ELSE
		INSERT INTO variables(`name`, `value`, `datatype`, `about`)VALUES(`var_name`, `var_value`, @varType, 'via script');
	END IF;
END$

DELIMITER ;

UPDATE suggestions SET categories = 0;

ALTER TABLE suggestions CHANGE categories category_id INT NOT NULL;

CREATE TABLE suggestion_categories (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE,
	userid_added INT NOT NULL,
	userid_last_edited INT NOT NULL,
	added_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_edited TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP,
	userid_owner INT NOT NULL,
	subcategory INT DEFAULT NULL NULL,
	INDEX p_user_added (userid_added),
	INDEX p_user_last_edited (userid_last_edited),
	INDEX p_user_owner (userid_owner),
	INDEX p_parent_category (subcategory),
	FOREIGN KEY (userid_added)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	FOREIGN KEY (userid_last_edited)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	FOREIGN KEY (userid_owner)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	FOREIGN KEY (subcategory)
		REFERENCES suggestion_categories(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

ALTER TABLE suggestions ADD suggestion_mode ENUM('done','acknowledged','unread','viewed') DEFAULT 'unread' NOT NULL;

ALTER TABLE suggestions CHANGE suggestion_mode suggestion_mode ENUM('done','acknowledged','unread','viewed','deleted') DEFAULT 'unread' NOT NULL;

CREATE TABLE owners (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	userid INT NOT NULL,
	category_id INT NOT NULL,
	INDEX p_userid (userid),
	INDEX p_category_id (category_id),
	FOREIGN KEY (userid)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	FOREIGN KEY (category_id)
		REFERENCES suggestion_categories(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

CREATE TABLE notifications (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	userid INT NOT NULL,
	title VARCHAR(80) DEFAULT 'New Notification' NOT NULL,
	message TEXT NOT NULL,
	unread BOOLEAN DEFAULT TRUE NOT NULL,
	viewed BOOLEAN DEFAULT FALSE NOT NULL,
	received TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

ALTER TABLE accounts ADD notification_type ENUM('email','notification','both','neither') DEFAULT 'both' NOT NULL;

ALTER TABLE accounts DROP notification_type;

ALTER TABLE user_settings ADD notification_type ENUM('email','notification','both','neither') DEFAULT 'both' NOT NULL;

DROP TRIGGER IF EXISTS tr_owner;

DELIMITER $
CREATE TRIGGER `tr_owner` AFTER INSERT 
ON `suggestion_categories` FOR EACH ROW
BEGIN
	INSERT INTO owners (owners.userid, owners.category_id) VALUES (NEW.userid_owner, NEW.id);
END$
DELIMITER ;

DROP TRIGGER IF EXISTS tr_owner_del;

DELIMITER $
CREATE TRIGGER tr_owner_del AFTER DELETE
ON suggestion_categories FOR EACH ROW
BEGIN
	DELETE FROM owners WHERE owners.userid = OLD.userid_owner AND owners.category_id = OLD.id;
END$
DELIMITER ;

DROP TRIGGER IF EXISTS tr_owner_upd;

DELIMITER $
CREATE TRIGGER tr_owner_upd BEFORE UPDATE
ON suggestion_categories FOR EACH ROW
BEGIN
	SET @p := OLD.userid_owner;
	UPDATE owners SET owners.userid = NEW.userid_owner WHERE owners.category_id = NEW.id AND owners.userid = @p;
END$
DELIMITER ;

CREATE TABLE roles (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(80) NOT NULL UNIQUE,
	userid INT NOT NULL,
	created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_edited TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
	about TEXT NOT NULL,
	permission_list TEXT NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

CREATE TABLE permissions (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(80) NOT NULL UNIQUE,
	userid INT NOT NULL,
	created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_edited TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
	about TEXT NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

CREATE TABLE departments (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(80) NOT NULL UNIQUE,
	userid INT NOT NULL,
	created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_edited TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
	about TEXT NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

ALTER TABLE accounts DROP department_id;
ALTER TABLE accounts ADD department_id INT DEFAULT NULL NULL;
UPDATE accounts SET department_id = NULL;
ALTER TABLE accounts
ADD FOREIGN KEY fk_department_id (department_id)
	REFERENCES departments(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE;

ALTER TABLE accounts DROP role_id;
ALTER TABLE accounts ADD role_id INT DEFAULT NULL NULL;
UPDATE accounts SET role_id = NULL;
ALTER TABLE accounts
ADD FOREIGN KEY fk_role_id (role_id)
	REFERENCES roles(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE;

CREATE VIEW giga_accounts
AS SELECT A.id UserID,
		  A.employee_name "Employee Name",
		  A.hiredate "Hire Date",
		  B.*
FROM giganet.accounts A
INNER JOIN giga_db_2448.accounts B
ON A.LOGON_USER = B.username

DROP TABLE IF EXISTS menus;
CREATE TABLE IF NOT EXISTS menus (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	page_url VARCHAR(80) NULL,
	page_title VARCHAR(250) NOT NULL,
	userid INT NOT NULL,
	INDEX p_userid (userid),
	FOREIGN KEY fk_userid (userid)
		REFERENCES accounts(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

LOAD XML INFILE 'C:\wamp\www\giganet\accounts.xml' INTO TABLE accounts_temp;