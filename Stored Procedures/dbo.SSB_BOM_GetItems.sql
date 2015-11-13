SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[SSB_BOM_GetItems]
		@PartNo nvarchar(255)	
AS

SELECT MBOMItems.AltGroupID,MBOMItems.ItemAltName,MMDef.Descript
FROM [SitMesDB].[dbo].[MMDefinitions] MDef
	INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
	INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
	INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMDef on MMDef.DefID=MBOMItems.ItemAltName
WHERE MDef.DefID=@PartNo /*'QPAY-500070553-1050' */
ORDER BY MBOMItems.BomItemAltPK
GO
