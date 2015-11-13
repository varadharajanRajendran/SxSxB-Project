SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get FEC Recipe Property

  Output Parameters:
	Recipe Table
	Issue Log

  Input Parameters:
	@SubAssembly Part No - FEC Subassembly Part No from FG Mattress


  Trigger:
	From SIT BPM ADO Connection

  Data Read Other Inputs:  
	---

  Data Written Results:
	---

  Assumptions:
	---

  Dependencies 

	---

  Variables:
	---

  Tables Modified
	---

  Modification Change History:
  ---------------------------
  10/24/2014	Varadharajan R	C00V00 - Intial code
  
  
*/
CREATE PROCEDURE [dbo].[SSB_BOM_GetItemCount]
		@PartNo nvarchar(255),
		@PartsItemCount int OUTPUT	
AS
 
SELECT COUNT(MBOMItems.ItemAltName)
FROM [SitMesDB].[dbo].[MMDefinitions] MDef
	INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
	INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
	INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMDef on MMDef.DefID=MBOMItems.ItemAltName
WHERE MDef.DefID=@PartNo
GO
