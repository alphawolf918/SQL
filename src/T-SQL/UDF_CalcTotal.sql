USE [InvoiceDM];
GO
IF OBJECT_ID(N'dbo.CalcTotal', N'FN') IS NOT NULL  
    DROP FUNCTION dbo.CalcTotal;  
GO
CREATE FUNCTION dbo.CalcTotal(@amountPayable AS MONEY, 
                              @salesTax      AS MONEY,
							  @discount      AS MONEY) RETURNS MONEY
AS
BEGIN
	DECLARE @subTotal MONEY;
	SET @subTotal = (@amountPayable - (@amountPayable * @discount))
	SET @subTotal = (@subTotal      + (@subTotal      * @salesTax))
	SET @subTotal = ROUND(@subTotal, 2)
	RETURN @subTotal;
END;
GO
SELECT dbo.CalcTotal(340.66, .07, .25) AS Subtotal;