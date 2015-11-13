SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_Get_PQLabelInfo]
	@EntryID  nvarchar(255)		
AS

/*  DECLARE @EntryID  nvarchar(255) */

DECLARE @OrderID		nvarchar(50)	,
	    @PartNo			nvarchar(50)	,
	    @Desc			nvarchar(255)	,
		@Length			decimal(5,2)	,
		@width			decimal(5,2)	,
		@SizeUoM		nvarchar(5)		,
		@TapeDesc		nvarchar(255)	,
		@DeckDesc		nvarchar(255)	,
		@FlangeDesc		nvarchar(255)	,
		@BorderType		nvarchar(50)	,
		@MattressSides  int				,
		@Quilter		nvarchar(5)		,
		@TruckID		nvarchar(5)		,
		@StopID			nvarchar(5)		,
		@LotID			nvarchar(255)	,
		@Date			nvarchar(20)	,
		@Time			nvarchar(50)	

SELECT	@OrderID=Po.Pom_order_id,
		@Quilter=REPLACE(Eq.equip_id,'WPB.CML01.PQ01.PQ','') 
FROM SitMesDB.dbo.Pom_entry Pe
	INNER JOIN SitMesDB.Dbo.POM_ORDER Po ON Po.Pom_order_pk=Pe.pom_order_pk
	INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT Eq ON eq.equip_pk= Pe.equip_pk
WHERE Pom_entry_id= @EntryID /* '131166545.PanelQuilt1' */
SELECT	@PartNo	=pe.matl_def_id ,
		@Desc=MMD.Descript
FROM SitMesDB.dbo.Pom_entry Pe
	INNER JOIN SitMesDB.Dbo.POM_ORDER Po ON Po.Pom_order_id=Pe.pom_entry_id
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD ON MMD.DefID=Pe.matl_def_id
WHERE Pom_order_id=@OrderID

/* Order Properties */
SELECT @TruckID=CONVERT(nvarchar(MAX),ocf_val.pom_cf_value),
	   @StopID=CONVERT(nvarchar(MAX),ocf_val1.pom_cf_value)
FROM [SitMesDB].[dbo].POM_Order AS Po 
	INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
	INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk AND ocf_rt.pom_custom_fld_name='TruckID'
	INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt1 ON Pe.pom_entry_pk = ocf_rt1.pom_entry_pk AND ocf_rt1.pom_custom_fld_name='StopLocationID'
	INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val1 ON ocf_rt1.pom_custom_field_rt_pk = ocf_val1.pom_custom_field_rt_pk
WHERE Pe.Pom_entry_id=@OrderID

/* FG SKU properties */
SELECT @MattressSides=CONVERT(nvarchar(MAX),BAPV.PValue)
FROM  [SitMesDB].dbo.MMvBomAltPrpVals AS BAPV WITH (NOLOCK) 
	INNER JOIN  [SitMesDB].dbo.MMBomAlts AS BA WITH (NOLOCK) ON BA.BomAltPK = BAPV.BomAltPK 
	INNER JOIN  [SitMesDB].dbo.MMBoms AS B WITH (NOLOCK) ON B.BomPK = BA.BomPK 
	INNER JOIN  [SitMesDB].dbo.MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = B.DefPK 
	INNER JOIN  [SitMesDB].dbo.MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BAPV.PropertyPK 
WHERE D.[DefID]=@PartNo
	AND P.PropertyID='MattressSides'
SELECT @BorderType= CASE (CONVERT(nvarchar(MAX),BAPV.PValue))
						WHEN '1' THEN 'Pillow Top'
						WHEN '0' THEN 'Tight Top'
					END
FROM  [SitMesDB].dbo.MMvBomAltPrpVals AS BAPV WITH (NOLOCK) 
	INNER JOIN  [SitMesDB].dbo.MMBomAlts AS BA WITH (NOLOCK) ON BA.BomAltPK = BAPV.BomAltPK 
	INNER JOIN  [SitMesDB].dbo.MMBoms AS B WITH (NOLOCK) ON B.BomPK = BA.BomPK 
	INNER JOIN  [SitMesDB].dbo.MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = B.DefPK 
	INNER JOIN  [SitMesDB].dbo.MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BAPV.PropertyPK 
WHERE D.[DefID]=@PartNo
	AND P.PropertyID='MattressType'

/* Panel Quilt */
SELECT @LotID=c.LotID 
FROM [SitMesDB].[dbo].[MMvLots] l
	INNER JOIN [SitMesDB].[dbo].[MMwLotCommitTo] c on c.LotPK = l.LotPK
	INNER JOIN [SitMesDB].[dbo].[MMvLocations] e on e.LocPK = l.LocPK
	INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] et on et.pom_order_id = c.CommitTo
WHERE et.pom_entry_type_id = 'PANEL_QUILT'
	AND c.CommitTo=@OrderID

/* OverCast Properties  & BOM */
SELECT @Length=CONVERT(nvarchar(MAX),ocf_val.pom_cf_value),
		@width=CONVERT(nvarchar(MAX),ocf_val1.pom_cf_value)
FROM [SitMesDB].[dbo].POM_Order AS Po 
	INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
	INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk AND ocf_rt.pom_custom_fld_name='PROD_MLength'
	INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt1 ON Pe.pom_entry_pk = ocf_rt1.pom_entry_pk AND ocf_rt1.pom_custom_fld_name='PROD_MWidth'
	INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val1 ON ocf_rt1.pom_custom_field_rt_pk = ocf_val1.pom_custom_field_rt_pk
WHERE Pe.Pom_entry_id like @OrderID + '.OverCast%'
SELECT @FlangeDesc	=MD.[Descript] /* ,ml.def_id,ml.quantity ,uoms1.UomID */ 
FROM [SitMesDB].[dbo].[POM_Order] Po
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON e.pom_order_pk =Po.pom_order_pk 
	INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
	INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
	LEFT OUTER JOIN [SitMesDB].[dbo].[MESUoMs] AS uoms1 ON ml.uom = uoms1.UomPK 
WHERE  ms.name='CONSUMED' 
	AND e.pom_entry_id like @OrderID + '.OverCast%'
					AND ml.class IN ('RMFL')

/* BHC BOM */
SELECT @TapeDesc=MD.[Descript] /* ,ml.def_id,ml.quantity ,uoms1.UomID */ 
FROM [SitMesDB].[dbo].[POM_Order] Po
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON e.pom_order_pk =Po.pom_order_pk 
	INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
	INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
	LEFT OUTER JOIN [SitMesDB].[dbo].[MESUoMs] AS uoms1 ON ml.uom = uoms1.UomPK 
WHERE  ms.name='CONSUMED' 
	AND e.pom_entry_id like @OrderID + '.BHC%'
					AND ml.class IN ('RMTP')
SELECT @DeckDesc=MD.[Descript] /* ,ml.def_id,ml.quantity ,uoms1.UomID */ 
FROM [SitMesDB].[dbo].[POM_Order] Po
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON e.pom_order_pk =Po.pom_order_pk 
	INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
	INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
	LEFT OUTER JOIN [SitMesDB].[dbo].[MESUoMs] AS uoms1 ON ml.uom = uoms1.UomPK 
WHERE  ms.name='CONSUMED' 
	AND e.pom_entry_id like @OrderID + '.BHC%'
					AND ml.class IN ('RMDK')


SELECT	@OrderID + '#' + @PartNo + '#' + @Desc + '#' + ISNULL(CONVERT(nvarchar(20),@length),'') + ' X ' + ISNULL(CONVERT(nvarchar(20), @Width),'') + '  IN #' + ISNULL(@TapeDesc,'') + '#' + ISNULL(@DeckDesc,'') + '#' + ISNULL(@FlangeDesc,'') + '#' + ISNULL(@BorderType,'') + '#' +  ISNULL(CONVERT(nvarchar(5),@MattressSides),'') + '#' + ISNULL( @Quilter,'') + '#'+ ISNULL(@TruckID,'') + ' - ' + ISNULL(@StopID,'') + '#' + ISNULL(@LotID,'') + '#' + ISNULL(CONVERT(nvarchar(50), GETDATE ( )),'')
GO
