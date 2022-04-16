USE InvoiceDM;

SELECT I.[ID]                         AS [ItemID]
      ,I.[ItemName]                   AS [Name]
	  ,I.[ItemText]                   AS [Description]
	  ,ROUND(I.[ItemPrice], 2)        AS [Price]
	  ,ROUND(I.[ItemDiscount], 2)     AS [Discount]
	  ,dbo.NVL(C.[CompanyName], '--') AS [Company]
	  ,I.[ItemColor]                  AS [Color]
FROM [Items] AS I
LEFT OUTER JOIN [ItemGroups] IG
    ON IG.[ID] = I.[ItemGroupID]
LEFT OUTER JOIN [Company] C
    ON C.[ID] = I.[CompanyID];