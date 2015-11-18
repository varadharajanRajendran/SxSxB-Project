SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[xl_RptGetMUSchedule]	
	@ProdLine NVARCHAR(20)	
 AS

DECLARE @SQLStringCreatetable NVARCHAR(Max)
SET @SQLStringCreateTable = ('SELECT 
										   LC.[JobID]						as ''OrderNo''	,
										   LC.[SKUNo]						as ''SKU''		,
										   LC.[Product]						AS ''SKUDesc''	,
										   LC.[UnitSize]					as ''UnitSize''	,
										   ISNULL(M1.Descript,'''')			AS ''L1Desc''	,
										   ISNULL(M2.Descript,'''')			as ''L2Desc''	,
										   ISNULL(M3.Descript,'''')			AS ''L3Desc''	,
										   ISNULL(M4.Descript,'''')			AS ''L4Desc''	,
										   ISNULL(M5.Descript,'''')			AS ''L5Desc''	,
										   ISNULL(M6.Descript,'''')			AS ''L6Desc''		
									  FROM [SSB].[dbo].[PLC_BC_'+ @ProdLine + '] LC
										LEFT JOIN SitMesDB.dbo.MMDefinitions M1 ON M1.DefID=LC.L1PNo
										LEFT JOIN SitMesDB.dbo.MMDefinitions M2 ON M2.DefID=LC.L2PNo
										LEFT JOIN SitMesDB.dbo.MMDefinitions M3 ON M3.DefID=LC.L3PNo
										LEFT JOIN SitMesDB.dbo.MMDefinitions M4 ON M4.DefID=LC.L4PNo
										LEFT JOIN SitMesDB.dbo.MMDefinitions M5 ON M5.DefID=LC.L5PNo
										LEFT JOIN SitMesDB.dbo.MMDefinitions M6 ON M6.DefID=LC.L6PNo
									  ORDER BY [EstSeq] , [JobID] ASC ')
EXEC (@SQLStringCreateTable)
GO
