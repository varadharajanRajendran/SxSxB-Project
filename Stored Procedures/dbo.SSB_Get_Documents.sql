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
CREATE PROCEDURE [dbo].[SSB_Get_Documents]		
AS
 
SELECT  DM.[pk] as [ID]
      , DM.[Description] as [Description]
      , DM.[FilePath] as [Fil ePath]
      , DPG.[Description] as [Document Group]
      , UG.[Description] as [Machine Model]
      , DM.[FileType] as [File Type]
      , DBLC.[Description] as [Status]
FROM [SSB].[dbo].[SSB_DocMgmt] as DM
INNER JOIN [SSB].[dbo].[SSB_UnitGroup] as UG ON UG.pk = DM.UnitGroup
INNER JOIN [SSB].[dbo].[SSB_DocProcessGroup] as DPG ON DPG.pk=DM.DocProcessGroup
INNER JOIN [SSB].[dbo].[SSB_DBLifeCycle] as DBLC ON DBLC.pk=DM.Status

exec sp_trace_generateevent 82, N'this is Test event'
exec sp_trace_generateevent 82, N'this is Testing event'
GO
