SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateHandle]	
AS

DECLARE @tblOrder as Table		(	RowId			int IDENTITY	,
									OrderID		nvarchar(50)	)
DECLARE @tblEntryProperty as Table(	RowId			int IDENTITY	,
									OrderID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

INSERT INTO @tblOrder(OrderID)
	SELECT DISTINCT(OrderID)
	FROM [SSB].[dbo].Temp_MES2Preactor	
	WHERE BorderHandle<>'NULL'
INSERT INTO @tblEntryProperty( OrderID	,PropertyID	,PropValue)
	SELECT  o.OrderID	,
			CONVERT(nvarchar(255),DM.[APSProperty]),
			CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblOrder o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
	WHERE Pe.[pom_entry_id]=o.OrderID + '.Handle1'
		AND DM.[DataFlow]='MES2Preactor'
		AND DM.[Catagory]='Handle'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderHandleStyle   */
	SET	BorderHandleStyle = Prop.PropValue	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
	WHERE Prop.PropertyID='BorderHandleStyle'	
	AND Po.ProcessType='MCCH'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderHandleWidth	  */
	SET	BorderHandleWidth = CONVERT(float,Prop.PropValue)	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
	WHERE Prop.PropertyID='BorderHandleWidth'	
	AND Po.ProcessType='MCCH'
		
		
INSERT INTO @tblEntryProperty( OrderID	,PropertyID	,PropValue)
	SELECT  o.OrderID	,
			CONVERT(nvarchar(255),DM.[APSProperty]),
			CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblOrder o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
	WHERE Pe.[pom_entry_id]=o.OrderID + '.HandleRoll1'
		AND DM.[DataFlow]='MES2Preactor'
		AND DM.[Catagory]='HandleRoll'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderHandleGroup	  */
	SET	BorderHandleGroup = Prop.PropValue	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
	WHERE Prop.PropertyID='BorderHandleGroup'	
	AND Po.ProcessType='MCCH'
GO
