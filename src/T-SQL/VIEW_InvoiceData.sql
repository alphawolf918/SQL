USE [InvoiceDM];
GO
CREATE OR ALTER VIEW [dbo].[VIEW_InvoiceData]
AS
SELECT IV.[ID]                                     AS [InvoiceID]
      ,[dbo].CreateInvoiceNr(IV.[ID])              AS [InvoiceNr]
	  ,CONCAT('$', IV.[Amount_Payable])            AS [AmountDue]
	  ,FORMAT(IV.[Sales_Tax], 'P0')                AS [TaxPct]
	  ,FORMAT(IV.[Discount],  'P0')                AS [DiscountPct]
	  ,CONCAT('$', [dbo].CalcTotal(IV.[Amount_Payable], 
	                               IV.[Sales_Tax],
					               IV.[Discount])) AS [Subtotal]
	  ,[dbo].FormatDate(IV.[Invoice_Dt])           AS [IssueDt]
	  ,[dbo].FormatDate(IV.[Due_Dt])               AS [DueDt]
	  ,[dbo].FormatDate(IV.[Supply_Dt])            AS [SupplyDt]
	  ,(CASE
			WHEN(IV.[Paid_Dt] < IV.[Invoice_Dt]
			  OR IV.[Paid_Dt] IS NULL) THEN
				'N/A'
		    ELSE [dbo].FormatDate(IV.[Paid_Dt])
		END)                                       AS [PaidDt]
	  ,(CASE
	        WHEN(IV.[Paid_Dt] IS NOT NULL
			AND (IV.[Paid_Dt] > IV.[Invoice_Dt])) THEN 'Yes'
			ELSE 'No'
	    END)                                       AS [Paid]
	  ,IV.[Summary]                                AS [Summary]
	  ,IV.[Payment_Terms]                          AS [PayTerms]
	  ,IV.[Notes]                                  AS [Notes]
	  ,[dbo].NVL(CL.[Name],         '--')          AS [Client]
	  ,[dbo].NVL(CMP.[CompanyName], '--')          AS [Company]
	  ,[dbo].NVL(CMP.[CompanyAddress], '--')       AS [Company_Address]
	  ,[dbo].NVL(CMP.[CompanyPhoneNr], '--')       AS [Company_Phone]
	  ,[dbo].NVL(CMP.[CompanyWebsite], '--')       AS [Company_Website]
	  ,[dbo].NVL(BI.[BusinessName], '--')          AS [Business]
	  ,[dbo].NVL(BI.[BusinessAddress], '--')       AS [Business_Address]
	  ,[dbo].NVL(BI.[BusinessPhone], '--')         AS [Business_Phone]
	  ,[dbo].NVL(BI.[BusinessWebsite], '--')       AS [Business_Website]
	  ,IV.[CompanyID]                              AS [CompanyID]
	  ,IV.[ClientID]                               AS [ClientID]
	  ,IV.[BusinessID]                             AS [BusinessID]
FROM [dbo].[Invoices]                AS IV
LEFT OUTER JOIN [dbo].[BusinessInfo] AS BI
	ON BI.[ID] = IV.[BusinessID]
LEFT OUTER JOIN [dbo].[Company]      AS CMP
    ON CMP.[ID] = IV.[CompanyID]
LEFT OUTER JOIN [dbo].[Clients]      AS CL
    ON CL.[ID] = IV.[ClientID];
GO
SELECT *
FROM [dbo].[VIEW_InvoiceData];