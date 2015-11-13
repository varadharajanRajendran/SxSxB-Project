SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*
  Purpose:
	Get List of Properties for MU

  Output Parameters:
	MU Recipe Code

  Input Parameters:
	@SAPartNo - SubAssembly Part No


  Trigger:
	From SIT BPM ADO Socket

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
CREATE  PROCEDURE [dbo].[SSB_Utility_UpdateLotbyOrder]
		@EntrySegment nvarchar(255)	
AS
 
DECLARE @intStartRow int			,
        @intEndRow int				,
        @intelProc int				,
        @PartNo		nvarchar(255)	,
        @LotNo		nvarchar(255)	,
		@MatID		nvarchar(255)	

DECLARE	@tblItems AS Table	(	RowId			int	IDENTITY	,
								entryID			nvarchar(255)	,
								DefID			nvarchar(255)	,
								MaterialID		int				)	 

INSERT INTO @tblItems (entryID,DefID,MaterialID)
 SELECT PE.pom_entry_id,
		 ML.def_id,
		 ML.pom_material_pk
  FROM [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS
	INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] PE on PE.[pom_entry_pk]=Ms.pom_entry_pk
	INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML on ML.pom_material_specification_pk=MS.pom_material_specification_pk
  WHERE MS.name='CONSUMED'
	AND PE.pom_entry_id like '%' + @EntrySegment + '%'

SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@tblItems 

WHILE	@intStartRow <=	@intEndRow	
	BEGIN
		SELECT @PartNo=DefID,
			   @MatID=MaterialID
		FROM @tblItems
		WHERE RowId=@intStartRow
		
		SELECT Top 1 @LotNo=LotID
		FROM [SitMesDB].[dbo].[MMLots] MML
			INNER JOIN [SitMesDB].[dbo].[MMDefVers] MMDV on MMDV.DefVerPK=MML.DefVerPK
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMDef on MMDef.DefPK=MMDV.DefPK
		WHERE MMDef.DefID=@PartNo
		
		UPDATE [SitMesDB].[dbo].[POM_MATERIAL_LIST]
			SET lot=@LotNo
			WHERE pom_material_pk=@MatID
		
		SELECT @intStartRow=@intStartRow + 1
	END
  
GO
