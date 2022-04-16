USE [InvoiceDM];
GO
CREATE OR ALTER VIEW [dbo].[VIEW_Users]
AS
SELECT U.[ID]                            AS [UserID]
	  ,U.[Email]                         AS [Email]
	  ,U.[RoleID]                        AS [RoleID]
      ,R.[Role_Name]                     AS [RoleName]
	  ,(CASE
			WHEN (U.[IS_LOCKED] = 1) THEN 'Yes'
			WHEN (U.[IS_LOCKED] = 0) THEN 'No'
			ELSE '?'
	    END)                             AS [Locked]
	  ,(CASE
			WHEN (U.[RoleID] = 4) THEN 'Yes'
			ELSE 'No'
	    END)                             AS [Forbidden]
	  ,[dbo].NVL(B.[ID], '0')            AS [BusinessID]
	  ,[dbo].NVL(B.[BusinessName], '--') AS [Business]
FROM [Users] U
LEFT OUTER JOIN [Roles] R
    ON R.[ID] = U.[RoleID]
LEFT OUTER JOIN [BusinessInfo] B
    ON B.[ID] = U.[BusinessID]
GO
SELECT *
FROM [VIEW_Users];