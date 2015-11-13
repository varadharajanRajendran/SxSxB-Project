SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get List of Document for the Selected Equipment

  Output Parameters:
	Document Table

  Input Parameters:
	@Machine Name -User Selected machine name


  Trigger:
	From web Socket

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
  10/21/2014	Varadharajan R	C00V00 - Intial code
  
  
*/
CREATE  PROCEDURE [dbo].[SSB_Web_GetAllDocumentsbyMachine]
	@EquipmentName		nvarchar(50)
AS
 

----------------------------------Declare Variables and Tables----------------------
DECLARE @Machinemodel nvarchar(255)

/* Find Machine Model */
  SELECT @Machinemodel=EP.equip_prpty_value
  FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] E
  INNER JOIN [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] EP
  ON E.equip_pk=Ep.equip_pk
  WHERE E.[equip_name]= @EquipmentName
  AND EP.equip_prpty_id='MACHINE_MODEL'

 /* Get List of Documents */
  SELECT  PG.[Description] as Category, DM.[Description] as FileDescription ,DM.[FilePath] as FilePath,DM.[FileType] as FileType
  FROM [SSB].[dbo].[SSB_DocMgmt] DM
  INNER JOIN [SSB].[dbo].[SSB_DocProcessGroup] PG On DM.DocProcessGroup=PG.pk
  INNER JOIN [SSB].[dbo].[SSB_UnitGroup] UG ON DM.UnitGroup=UG.pk
  WHERE DM.[Status]=2 AND
        UG.[Description]=@Machinemodel
  ORDER BY PG.[Description] ASC
 
GO
