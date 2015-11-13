SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateGussettRoll]	
AS

DECLARE @tblEntryBOM as Table	(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									ItemClass		nvarchar(255)	,
									PartNo			nvarchar(50)	,
									[UID]			nvarchar(50)	)
DECLARE @tblGussettBOM as Table	(	RowId			int IDENTITY	,
									OrderID			nvarchar(50)	,
									EntryID			nvarchar(50)	,
									ItemClass		nvarchar(20)	,
									PartNo			nvarchar(50)	,
									RollID			nvarchar(50)	)
DECLARE @tblEntryProperty as Table(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

INSERT INTO @tblEntryBOM(EntryID,PartNo,[UID])
	SELECT EntryID,GussettSAPart,OrderID
	FROM [SSB].[dbo].Temp_MES2Preactor
	WHERE 	GussettSAPart<>''
INSERT INTO @tblGussettBOM (OrderID,EntryID	,ItemClass,PartNo,RollID)
	SELECT Po.[UID],REPLACE(e.pom_entry_id,'Roll',''),ml.class, ml.def_id,e.pom_entry_id
	FROM   @tblEntryBOM AS Po
		INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON o.Pom_order_id=Po.[UID]
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE ms.name='CONSUMED'
		AND e.pom_entry_id like '%.GussettRoll%'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderTick */
	SET	GussettTick	 = BOM.PartNo		
	FROM @tblGussettBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=BOM.EntryID
	WHERE BOM.ItemClass='RMTK'
		AND Po.ProcessType='Gussett'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderBacking */
	SET	GussettBK	 = BOM.PartNo		
	FROM @tblGussettBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=BOM.EntryID
	WHERE BOM.ItemClass='RMBK'
		AND Po.ProcessType='Gussett'			
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* Border Roll Fiber */
	SET	GussettRF	 = BOM.PartNo		
	FROM @tblGussettBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=BOM.EntryID
	WHERE BOM.ItemClass='RMRF'
		AND Po.ProcessType='Gussett'			
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* Border Roll Poly */
	SET	GussettRP	 = BOM.PartNo		
	FROM @tblGussettBOM  AS BOM
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=BOM.EntryID
	WHERE BOM.ItemClass='RMRP'
		AND Po.ProcessType= 'Gussett'
UPDATE [SSB].[dbo].Temp_MES2Preactor
	SET GussettSAPart=[SAPart]
	FROM [SSB].[dbo].Temp_MES2Preactor
	WHERE ProcessType='Gussett'

INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
SELECT  o.EntryID,CONVERT(nvarchar(255),DM.[APSProperty]),CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblGussettBOM AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_entry_id = o.RollID 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
	WHERE DM.[DataFlow]='MES2Preactor'
		AND DM.[Catagory]='GussettRoll'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* GussettHeight */
	SET	GussettHeight = CONVERT(float,Prop.PropValue)	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE Prop.PropertyID='GussettHeight'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* GussettGroup */
	SET	GussettGroup = Prop.PropValue
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE Prop.PropertyID='GussettGroup'	
GO
