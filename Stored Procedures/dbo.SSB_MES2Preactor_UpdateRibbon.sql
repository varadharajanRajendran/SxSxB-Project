SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateRibbon]	
AS

DECLARE @tblSABOM as Table		(	RowId			int IDENTITY	,
									SAPartNo		nvarchar(50)	)

DECLARE @tblEntryBOM as Table	(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									ItemClass		nvarchar(255)	,
									PartNo			nvarchar(50)	,
									[UID]			nvarchar(50)	)

INSERT INTO @tblSABOM(SAPartNo)
	SELECT DISTINCT(OrderID)
	FROM [SSB].[dbo].Temp_MES2Preactor	
INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo)
	SELECT Po.SAPartNo,ml.class, ml.def_id
	FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
		INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
		INNER JOIN @tblSABOM Po ON Po.SAPartNo=o.pom_order_id
	WHERE ms.name='CONSUMED'
		AND e.pom_entry_id=Po.SAPartNo + '.Ribbon1'
		AND ml.class IN ('RMTP')							
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* ThreadLineColor */
	SET	ThreadLineColor	 = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='RMTP'
		AND Po.ProcessType='MCCH'
GO
