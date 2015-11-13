SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[PLC_GetValuebyTag]
		@ColumnName		NVARCHAR(20),
		@OrderID		NVARCHAR(20),
		@ProdLine		NVARCHAR(20),
		@TransactionType	NVARCHAR(20)
AS

DECLARE @sSQL nvarchar(MAX)
SELECT @sSQL= 'SELECT [' + @ColumnName + '] FROM [SSB].[dbo].[PLC_' + @TransactionType + '_' + @ProdLine + '] WHERE [JobID] =' + @OrderID
EXEC sp_executesql @sSQL
GO
