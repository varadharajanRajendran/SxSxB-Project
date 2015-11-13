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
CREATE  PROCEDURE [dbo].[SSB_BOM_GetProperties]
		@PartNo nvarchar(255)	
AS
 
SELECT MMP.PropertyID,CONVERT(nvarchar(255),[SitMesDB].[dbo].MMfBinToPropVal(BAPV.PropValue, 0)) AS PValue
FROM [SitMesDB].[dbo].[MMDefinitions] MDef
	INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
	INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
	INNER JOIN [sitmesDB].[dbo].[MMBomAltPrpVals] BAPV on MAlt.BomAltPK=BAPV.BomAltPK
	INNER JOIN [sitmesDB].[dbo].[MMProperties] MMP on MMP.PropertyPK=BAPV.PropertyPK
WHERE MDef.DefID=@PartNo
GO
