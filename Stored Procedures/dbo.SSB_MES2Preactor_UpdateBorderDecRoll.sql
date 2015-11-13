SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateBorderDecRoll]	
AS


DECLARE @tblOrders as Table		(	RowId			int IDENTITY	,
									OrderID		nvarchar(50)	)

DECLARE @tblEntryBOM as Table	(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									ItemClass		nvarchar(255)	,
									PartNo			nvarchar(50)	,
									[UID]			nvarchar(50)	)

DECLARE @tblEntryProperty as Table(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

INSERT INTO @tblOrders(OrderID)
	SELECT DISTINCT(OrderID)
	FROM [SSB].[dbo].Temp_MES2Preactor	
INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo)
	SELECT Po.OrderID,ml.class, ml.def_id
	FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
		INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
		INNER JOIN @tblOrders Po ON Po.OrderID=o.pom_order_id
	WHERE ms.name='CONSUMED'
		AND e.pom_entry_id=Po.OrderID + '.BorderDecRoll1'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderTick */
	SET	BorderTick	 = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='RMTK'
		AND Po.ProcessType='MCCH'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderBacking */
	SET	BorderBK	 = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='RMBK'
		AND Po.ProcessType='MCCH'			
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* Border Roll Fiber */
	SET	BorderRF	 = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='RMRF'
		AND Po.ProcessType='MCCH'			
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* Border Roll Poly */
	SET	BorderRP	 = BOM.PartNo		
	FROM @tblEntryBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=BOM.EntryID
	WHERE BOM.ItemClass='RMRP'
		AND Po.ProcessType='MCCH'	
						
INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
	SELECT  o.OrderID	,
			CONVERT(nvarchar(255),DM.[APSProperty]),
			CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblOrders o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
	WHERE Pe.[pom_entry_id]=o.OrderID + '.BorderDecRoll1'
		AND DM.[DataFlow]='MES2Preactor'
		AND DM.[Catagory]='BorderRoll'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderNeedleBar	  */
	SET	BorderNeedleBar = Prop.PropValue	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.EntryID
	WHERE Prop.PropertyID='BorderNeedleBar'	
	AND Po.ProcessType='MCCH'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* Borderpattern	  */
	SET	Borderpattern = Prop.PropValue	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.EntryID
	WHERE Prop.PropertyID='Borderpattern'	
	AND Po.ProcessType='MCCH'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderBDRGroup	  */
	SET	BorderBDRGroup = Prop.PropValue	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.EntryID
	WHERE Prop.PropertyID='BorderBDRGroup'	
	AND Po.ProcessType='MCCH'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderNletHeight  */
	SET	BorderNletHeight = CONVERT(float,Prop.PropValue)	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.EntryID
	WHERE Prop.PropertyID='BorderNletHeight'	
	AND Po.ProcessType='MCCH'		
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderWidth  */
	SET	BorderWidth = CONVERT(float,Prop.PropValue)	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.EntryID
	WHERE Prop.PropertyID='BorderWidth'	
	AND Po.ProcessType='MCCH'	
GO
