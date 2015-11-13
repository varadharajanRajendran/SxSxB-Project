SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateMCCH]	
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
		AND e.pom_entry_id=Po.SAPartNo + '.MCCHL1'
		AND ml.class IN ('RMLB','SAHNAY','SABROY','SABRCY','SABRSY','SABNLY','SABBPY')					
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderLabel */
	SET	BorderLabel	 = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='RMLB'
		AND Po.ProcessType='MCCH'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/*BorderHandle */
	SET	BorderHandle = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='SAHNAY'
		AND Po.ProcessType='MCCH'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BDSAPart */
	SET	BDSAPart	 = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass IN  ('SABROY','SABRCY','SABRSY','SABNLY','SABBPY')
		AND Po.ProcessType='MCCH'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BDType */
	SET	BDType	 = CASE (BOM.ItemClass	)
						WHEN 'SABROY' THEN 'Ribbon'	
						WHEN 'SABRCY' THEN 'RibbonCord'
						WHEN 'SABRSY' THEN 'RibbonDecStitch'
						WHEN 'SABNLY' THEN 'Nlet'
						WHEN 'SABBPY' THEN 'ByPass'
					END
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass IN  ('SABROY','SABRCY','SABRSY','SABNLY','SABBPY')
		AND Po.ProcessType='MCCH'
/*
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderCord */
	SET	BorderCord	 = CASE (BOM.ItemClass	)
						WHEN 'SABROY' THEN 'Ribbon'	
						WHEN 'SABRCY' THEN 'RibbonCord'
						WHEN 'SABRSY' THEN 'RibbonDecStitch'
						WHEN 'SABNLY' THEN 'Nlet'
						WHEN 'SABBPY' THEN 'ByPass'
					END
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass IN  ('SABROY','SABRCY','SABRSY','SABNLY','SABBPY')
		AND Po.ProcessType='MCCH'	
*/	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderRibbon */
	SET	BorderRibbon	 = BOM.PartNo
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='SABROY'
		AND Po.ProcessType='MCCH'							
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderStitch */
	SET	BorderStitch	 = BOM.PartNo
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='SABRSY'
		AND Po.ProcessType='MCCH'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderRibbonCord */
	SET	BorderRibbonCord	 = BOM.PartNo
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='SABRCY'
		AND Po.ProcessType='MCCH'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderCord */
	SET	BorderCord	 = BOM.PartNo
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='SABRCY'
		AND Po.ProcessType='MCCH'

UPDATE [SSB].[dbo].Temp_MES2Preactor							/* NLET */
	SET	NLET	 = BOM.PartNo
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='SABNLY'
		AND Po.ProcessType='MCCH'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* ByPass */
	SET	ByPass	 = BOM.PartNo
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='SABBPY'
		AND Po.ProcessType='MCCH'
GO
