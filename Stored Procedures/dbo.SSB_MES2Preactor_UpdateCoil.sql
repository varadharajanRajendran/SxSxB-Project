SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateCoil]	
AS


DECLARE @tblOrder as Table		(	RowId		int IDENTITY	,
									OrderID		nvarchar(50)	)

DECLARE @tblEntryProperty as Table(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

DECLARE	@tblCU AS Table	(	RowId				int	IDENTITY	,
							iOrderID			nvarchar(50)	,
							iEntryID			nvarchar(50)	,
							iSAPart				nvarchar(50)	,
							iSAPartDesc			nvarchar(255)	,
							iBorderWire			nvarchar(50)	,
							iCoilsperRow		int				,
							iTotalNoofRows		int				)

INSERT INTO @tblOrder(OrderID)
	SELECT DISTINCT(OrderID)
	FROM [SSB].[dbo].Temp_MES2Preactor
	WHERE ProcessType='Coiler'

INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
	SELECT  pe.Pom_entry_id,
			CONVERT(nvarchar(255),DM.[APSProperty]),
			CONVERT(nvarchar(50),ocf_val.pom_cf_value)
		FROM  @tblOrder AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
	WHERE DM.[DataFlow]='MES2Preactor'
		AND DM.[Catagory]='Coiler'

UPDATE [SSB].[dbo].Temp_MES2Preactor							/* CoilWireGage	  */
	SET	CoilWireGage = CONVERT(float,CONVERT(decimal(6,3),Prop.PropValue))	
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE Prop.PropertyID='CoilWireGage'	
	AND Po.ProcessType='Coiler'	

UPDATE [SSB].[dbo].Temp_MES2Preactor							/* CoilSeries	  */
	SET	CoilSeries = Prop.PropValue
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE Prop.PropertyID='CoilSeries'	
	AND Po.ProcessType='Coiler'	

UPDATE [SSB].[dbo].Temp_MES2Preactor							/* CoilQuantity	  */
	SET CoilQuantity= ml.quantity
	FROM   [SitMesDB].dbo.POM_ORDER AS o  
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor Po ON Po.EntryID=e.pom_entry_id
	WHERE ms.name='PRODUCED'
		AND Po.ProcessType='Coiler'

INSERT INTO @tblCU (iOrderID,iEntryID,iSAPart,iSAPartDesc,iBorderWire,iCoilsperRow,iTotalNoofRows)	/* Logic May Change in Future	  */
	SELECT	OrderID			,
			EntryID			,
			SAPart			,
			SAPartDesc		,
			BorderWire		,
			CoilsperRow		,
			TotalNoofRows
	FROM [SSB].[dbo].Temp_MES2Preactor	Po
	WHERE ProcessType='CU'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* Logic May Change in Future	  */
	SET EntryID			=	iEntryID			,
		SAPart			=	iSAPart			,
		SAPartDesc		=	iSAPartDesc		,
		BorderWire		=	iBorderWire		,
		CoilsperRow		=	iCoilsperRow		,
		TotalNoofRows	=	iTotalNoofRows
	FROM @tblCU
	WHERE ProcessType='Coiler'
GO
