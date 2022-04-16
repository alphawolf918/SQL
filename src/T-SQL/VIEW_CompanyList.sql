SELECT C.[ID]             AS [CompanyID]
      ,C.[CompanyName]    AS [Name]
      ,C.[CompanyAddress] AS [Address]
	  ,C.[CompanyPhoneNr] AS [Phone Number]
	  ,C.[CompanyWebSite] AS [Web Site]
FROM InvoiceDM.dbo.Company C;