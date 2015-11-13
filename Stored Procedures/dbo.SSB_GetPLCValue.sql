SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[SSB_GetPLCValue]
		@ColumnName nvarchar(20),
		@OrderID	nvarchar(20)
AS

DECLARE @sSQL nvarchar(MAX)
SELECT @sSQL= 'SELECT [' + @ColumnName + '] FROM [SSB].[dbo].[MES2LC] WHERE [JobID] =' + @OrderID
EXEC sp_executesql @sSQL
GO
