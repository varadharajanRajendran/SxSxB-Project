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
CREATE  PROCEDURE [dbo].[SSB_Add_Document]
        @MachineDesc	nvarchar(255)	,
		@FilePath		nvarchar(1000)	,
		@DocGroup		nvarchar(255)	,
		@Model			nvarchar(255)	,
		@FileType		nvarchar(255)	,
		@ActiveUser		nvarchar(255)	
AS
 
----------------------------------Declare Variables and Tables----------------------
DECLARE @DocLifeCycleID int,
		@ModelID		int,
		@DocGroupID		int

SELECT @ModelID=[pk]
FROM [SSB].[dbo].[SSB_UnitGroup]
WHERE [Description]=@Model

SELECT @DocGroupID	=[pk]
FROM [SSB].[dbo].[SSB_DocProcessGroup]
WHERE [Description]=@DocGroup


INSERT INTO [SSB].[dbo].[SSB_DocMgmt] ([Description],[FilePath],[DocProcessGroup],[UnitGroup],[FileType],[Status],[CreatedDataTime],[CreatedBy])
   VALUES (	@MachineDesc			,
			@FilePath				,
			@DocGroupID				,
			@ModelID				,
			@FileType				,
			'2'						,
			GETDATE()				,
			@ActiveUser				)

GO
