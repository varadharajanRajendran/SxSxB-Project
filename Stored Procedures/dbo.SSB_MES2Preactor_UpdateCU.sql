SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateCU]	
AS


DECLARE @tblOrder as Table		(	RowId		int IDENTITY	,
									OrderID		nvarchar(50)	)

DECLARE @tblEntryProperty as Table(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

INSERT INTO @tblOrder(OrderID)
	SELECT DISTINCT(OrderID)
	FROM [SSB].[dbo].Temp_MES2Preactor
	WHERE ProcessType='CU'	
INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
	SELECT  o.OrderID,
			CONVERT(nvarchar(255),DM.[APSProperty]),
			CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblOrder AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
	WHERE Pe.[pom_entry_id]=o.OrderID + '.CU1'
		AND DM.[DataFlow]='MES2Preactor'
		AND DM.[catagory]='CU'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* CoilsperRow	  */
	SET	CoilsperRow = CONVERT(int,CONVERT(NUMERIC,Prop.PropValue))	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.EntryID
	WHERE Prop.PropertyID='CoilsperRow'	
	AND Po.ProcessType='CU'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* TotalNoofRows	  */
	SET	TotalNoofRows = CONVERT(int,CONVERT(NUMERIC,Prop.PropValue))
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.EntryID
	WHERE Prop.PropertyID='TotalNoofRows'	
	AND Po.ProcessType='CU'	
GO
