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
CREATE  PROCEDURE [dbo].[SSB_Get_Machine_By_Description]	
AS

DECLARE	@Machines AS Table	(	RowId			int	IDENTITY	,
								MachineID		nvarchar(255)	,	
								MachineDesc		nvarchar(255)	,
								MachineModel	nvarchar(255)	)
 
 DECLARE @intStartRow int			,
        @intEndRow int				,
        @intelProc int				,
        @MachineID nvarchar(255)	,
        @MachineDesc nvarchar(255)	,
		@MachinePK  nvarchar(255)	,
		@MachineModel	nvarchar(255)


 INSERT INTO @Machines(MachineID)
	 SELECT DISTINCT(equip_label)
	 FROM [SitMesDB].[dbo].[BPM_EQUIPMENT]
	 WHERE [equip_id] like 'SSB-WPALMBEACH.WPB.CML01.%'
		AND [equip_label] IS NOT NULL


SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@Machines 
    
/* Get Equipment Name from Equipment ID*/
WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT @MachineID=MachineID 
	FROM @Machines 
	WHERE RowId=@intStartRow
	IF @MachineID <>''
		BEGIN
			SELECT @MachineModel=(Eq_Property.equip_prpty_value)
			FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] as Eq_Property
				INNER JOIN   [SitMesDB].[dbo].[BPM_EQUIPMENT] as Eq ON EQ.equip_pk=Eq_Property.equip_pk
			WHERE eq_Property.equip_prpty_id ='MACHINE_MODEL'
			AND eq.equip_label like @MachineID
	
			UPDATE @Machines
				SET MachineDesc		= SUBSTRING(@MachineID,1,Len(@MachineID)-3),
					MachineModel	= @MachineModel
				WHERE RowId=@intStartRow
		END
		ELSE
		BEGIN
			DELETE @Machines
			WHERE RowId=@intStartRow
		END
	SELECT @intStartRow=@intStartRow +1
END

SELECT MachineID	as [Machine Description]	,
	   MachineModel as [Machine Model]			,	
	   MachineDesc	as [Machine Group]
 FROM @Machines
GO
