SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateHGA]	
AS


DECLARE @tblOrder as Table		(	RowId		int IDENTITY	,
									OrderID		nvarchar(50)	)

DECLARE @tblEntryBOM as Table	(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									ItemClass		nvarchar(255)	,
									PartNo			nvarchar(50)	,
									[UID]			nvarchar(50)	)

INSERT INTO @tblOrder(OrderID)
	SELECT DISTINCT(OrderID)
	FROM [SSB].[dbo].Temp_MES2Preactor
	WHERE ProcessType='CU'	
	
INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo)
	SELECT o.OrderID,ml.class, ml.def_id
	FROM  @tblOrder AS o
		INNER JOIN [SitMesDB].dbo.POM_ORDER AS Po ON Po.pom_order_id = o.OrderID
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON  e.pom_order_pk =Po.pom_order_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE ms.name='CONSUMED'
		AND e.pom_entry_id like '%.PurchaseCoilAssem1'
		AND ml.class='SAMCAY'

UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderWire	  */
	SET	BorderWire	 = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE Po.ProcessType='CU'	

				
GO
