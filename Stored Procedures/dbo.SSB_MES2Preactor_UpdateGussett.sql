SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateGussett]	
AS


DECLARE @tblEntryBOM as Table	(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									ItemClass		nvarchar(255)	,
									PartNo			nvarchar(50)	,
									[UID]			nvarchar(50)	)
DECLARE @tblEntryProperty as Table(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

INSERT INTO @tblEntryBOM(EntryID,PartNo,[UID])
	SELECT EntryID,GussettSAPart,OrderID
	FROM [SSB].[dbo].Temp_MES2Preactor
	WHERE 	GussettSAPart<>''


INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
	SELECT  o.EntryID,CONVERT(nvarchar(255),DM.[APSProperty]),CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblEntryBOM AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.UID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
	WHERE Pe.[pom_entry_id] like o.[UID] + '.GussettRoll%'
		AND DM.[DataFlow]='MES2Preactor'
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
