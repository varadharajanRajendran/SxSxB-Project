SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get List of Equipments assigned to the Terminal

  Output Parameters:
	List of Machines

  Input Parameters:
	@TerminalName - User Logged in/selected Terminal Name


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
CREATE  PROCEDURE [dbo].[SSB_Web_GetMachines]
		@TerminalName	nvarchar(10)	
AS
 
----------------------------------Declare Variables and Tables----------------------
DECLARE @intStartRow int			,
        @intEndRow int				,
        @intelProc int				,
        @MachineID int				,
        @MachineDesc nvarchar(255)	,
		@MachinePK  nvarchar(255)	

DECLARE	@Machines AS Table	(	RowId			int	IDENTITY	,
								MachineID		int				,
								MachineDesc		nvarchar(255)	,	
								MachinePK		nvarchar(255)	)

/* Find the Equipment ID Mapped for the Terminal */
IF @TerminalName='WC17'
	BEGIN
		INSERT INTO	@Machines (MachineID)
			 SELECT [equip_pk]
			 FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY]
			 WHERE equip_prpty_id ='Terminalname' 
	END
	ELSE
	BEGIN
		INSERT INTO	@Machines (MachineID)
			 SELECT [equip_pk]
			 FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY]
			 WHERE equip_prpty_id ='Terminalname' 
				  AND equip_prpty_value=@TerminalName
	END

SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@Machines 
    
/* Get Equipment Name from Equipment ID*/
WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT @MachineID=MachineID 
	FROM @Machines 
	WHERE RowId=@intStartRow
	
	SELECT @MachineDesc=[equip_name],@MachinePK=[equip_id]
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT]
	WHERE [equip_pk]=@MachineID 
	

	UPDATE	@Machines
		SET	MachineDesc	 =	@MachineDesc,
			MachinePK	 =	@MachinePK
		WHERE	RowId	=	@intStartRow
		
	SELECT	@intStartRow	=	@intStartRow	+	1
END

SELECT	DISTINCT(MachineDesc)	 FROM	@Machines
WHERE MachinePk like 'SSB-WPALMBEACH.%'
GO
