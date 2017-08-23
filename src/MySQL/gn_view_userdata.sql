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