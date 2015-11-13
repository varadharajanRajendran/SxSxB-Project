SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get List of Equipments assigned to the Terminal

  Output Parameters:
	List of Machines by Decription

  Input Parameters:
	NULL


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
CREATE  PROCEDURE [dbo].[SSB_Get_Machine_Model]	
	@MachineName	nvarchar(10)	
AS
 
DECLARE @intLenDesc int	

SELECT @intLenDesc = LEN(@MachineName)

SELECT DISTINCT(Eq_Property.equip_prpty_value)
FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] as Eq_Property
	INNER JOIN   [SitMesDB].[dbo].[BPM_EQUIPMENT] as Eq ON EQ.equip_pk=Eq_Property.equip_pk
WHERE eq_Property.equip_prpty_id ='MACHINE_MODEL'
	AND eq.equip_label like @MachineName
	AND LEN(eq.equip_label)=@intLenDesc + 3
GO
