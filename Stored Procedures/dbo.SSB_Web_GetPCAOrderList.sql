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
CREATE PROCEDURE [dbo].[SSB_Web_GetPCAOrderList]
		
AS
 
DECLARE	@tblOrderList AS Table	(	RowId		int	IDENTITY	,
								    OrderID		nvarchar(10)	,
									EntryID		nvarchar(100)	,
									entryPK		int				,
									GroupDesc	nvarchar(100)	)


DECLARE @intStartRow	int				,
        @intEndRow		int				,
        @intelProc		int				,
        @PartNo			nvarchar(100)	,
		@pom_entry_PK	int				,
		@ItemCount		int				,				
		@MUCount		int				,
		@CUCount		int
INSERT INTO @tblOrderList (OrderID,EntryID,entryPK)
	SELECT Po.[pom_order_id],
		   PE.[pom_entry_id],
		   PE.[pom_entry_pk]
	FROM [SitMesDB].[dbo].[POM_ORDER] PO
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PE on PE.pom_order_pk=PO.pom_order_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT on PT.pom_entry_type_pk=PE.pom_entry_type_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] PS on PS.pom_entry_status_pk=PE.pom_entry_status_pk
	WHERE PT.id='HMB_OC_BUY'
		AND PS.id='Scheduled'
    
SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@tblOrderList
    
/* Get Item Description */
WHILE	@intStartRow <=	@intEndRow	
BEGIN    
	SELECT @pom_entry_PK = entryPK
	FROM @tblOrderList
	WHERE RowId=@intStartRow
	
	SELECT @ItemCount=COUNT(ML.[class])
	FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS on MS.pom_material_specification_pk=ML.pom_material_specification_pk
	WHERE MS.pom_entry_pk=@pom_entry_PK
		AND MS.name='CONSUMED'
	
	
	IF @ItemCount>1
		BEGIN
			SELECT @CUCount=COUNT(ML.[class])
			FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML
				INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS on MS.pom_material_specification_pk=ML.pom_material_specification_pk
			WHERE MS.pom_entry_pk=@pom_entry_PK
				AND MS.name='CONSUMED'
				AND ML.[class]='SAMCAY'
			
			IF @CUCount>=1
				BEGIN
					UPDATE @tblOrderList
						SET GroupDesc='CU-HogRing'
						WHERE RowId=@intStartRow
				END
			END
		ELSE IF @ItemCount>1 AND @CUCount =0
			BEGIN
				UPDATE @tblOrderList
					SET GroupDesc='OC-HogRing'
					WHERE RowId=@intStartRow
			END
		ELSE IF @ItemCount=1 
			BEGIN

				SELECT @MUCount=COUNT(ML.[class])
				FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML
					INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS on MS.pom_material_specification_pk=ML.pom_material_specification_pk
				WHERE MS.pom_entry_pk=@pom_entry_PK
					AND MS.name='CONSUMED'
					AND ML.[class]='RMMU'
				
				IF @MUCount=1
					BEGIN
						UPDATE @tblOrderList
						SET GroupDesc='OC-PassThrough'
						WHERE RowId=@intStartRow
					END
			END
	SELECT @intStartRow =@intStartRow + 1
END	


UPDATE @tblOrderList
SET GroupDesc='OC-HogRing'
WHERE GroupDesc is NULL

SELECT	OrderID		,
		GroupDesc
FROM @tblOrderList
GO
