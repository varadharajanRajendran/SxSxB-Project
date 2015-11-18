SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[xl_RptGetOCSchedule]
	@ShipmentDate			nvarchar(50)	,
	@ProdLine				nvarchar(20)    	
AS

/*
DECLARE	@ShipmentDate			nvarchar(50)	,
		@ProdLine				nvarchar(20)    

SELECT 	@ShipmentDate	= '05-11-2015'	,
		@ProdLine='CML01'	
*/
DECLARE	@tblPanelData AS Table	(	RowId			int	IDENTITY		,
									OrderNo			nvarchar(50)		,
									EntryID			nvarchar(50)		,
									SKU				nvarchar(50)		,
									SKUDesc			nvarchar(255)		,
									PanelLength		nvarchar(50)		,
									PanelWidth		nvarchar(50)		,
									SA				nvarchar(50)		,
									MachineID		nvarchar(50)		,
									MachineType		nvarchar(50)		,
									Seq				int					,
									BorderType		nvarchar(20)		,
									UnitType		nvarchar(20)        ,
									MatSides		nvarchar(20)		)
DECLARE	@tblProperty AS Table	(	RowId			int	IDENTITY		,
									EntryID			nvarchar(50)		,
									Property		nvarchar(50)		,
									Value			nvarchar(50)		)
DECLARE	@tblOCData AS Table		(	RowId			int	IDENTITY		,
									OrderNo			nvarchar(50)		,
									EntryID			nvarchar(50)		)


INSERT INTO @tblPanelData (orderNo,EntryID,SKU,SKUDesc,seq,MachineID,MachineType)
	SELECT Po.Pom_order_id,Pe.Pom_entry_id,REPLACE(Po.ppr_name,'PPR_',''),MD.Descript,Pe.Sequence,REPLACE(E.equip_id, E4.[equip_id] + '.' + @ProdLine + '.PQ01.',''),CASE(REPLACE(E.equip_id,E4.[equip_id] + '.' + @ProdLine + '.PQ01.',''))
						WHEN 'PQ01' THEN 'PAR'
						WHEN 'PQ02'	THEN 'V16'
						WHEN 'PQ03' THEN 'V16'
					 END
	FROM  [SitMesDB].[dbo].POM_ENTRY Pe
		INNER JOIN [SitMesDB].[dbo].POM_ORDER Po ON Po.Pom_order_pk=Pe.Pom_order_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=REPLACE(Po.ppr_name,'PPR_','')
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E ON E.Equip_pk=Pe.Equip_Pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E2 ON E.[equip_prnt_pk]=E2.Equip_pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E3 ON E2.[equip_prnt_pk]=E3.Equip_pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E4 ON E3.[equip_prnt_pk]=E4.Equip_pk
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY Pe1 ON Pe1.Pom_order_pk=Po.pom_order_pk
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe1.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk					  
	WHERE E3.[equip_id]=E4.[equip_id] + '.'  + @ProdLine 
		AND Pos.id IN ('PreProduction','Production','Rework')
		AND Pe.Pom_entry_id like '%PanelQuilt%'
		AND ocf_rt.pom_custom_fld_name='ShipmentDate'
		AND ocf_val.pom_cf_value=@ShipmentDate
	ORDER BY Pe.Sequence ASC
UPDATE @tblPanelData
SET UnitType=CONVERT(nvarchar(50),ocf_val.pom_cf_value)
FROM  @tblPanelData  AS o 
	INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderNo
	INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
	INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
	INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
WHERE ocf_rt.pom_custom_fld_name='MattressUnitType'
UPDATE @tblPanelData
SET MatSides=CONVERT(nvarchar(50),BAPV.PValue)
FROM  [SitMesDB].dbo.MMvBomAltPrpVals AS BAPV WITH (NOLOCK) 
	  INNER JOIN  [SitMesDB].dbo.MMBomAlts AS BA WITH (NOLOCK) ON BA.BomAltPK = BAPV.BomAltPK 
	  INNER JOIN  [SitMesDB].dbo.MMBoms AS B WITH (NOLOCK) ON B.BomPK = BA.BomPK 
	  INNER JOIN  [SitMesDB].dbo.MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = B.DefPK 
	  INNER JOIN  [SitMesDB].dbo.MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BAPV.PropertyPK 
	  INNER JOIN  @tblPanelData Po ON Po.SKU=D.[DefID]
WHERE P.PropertyID='MattressSides'	  
UPDATE @tblPanelData 
	SET SA=ml.def_id
	FROM @tblPanelData AS o
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON  e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
	WHERE ms.name='PRODUCED'
INSERT INTO @tblProperty(EntryID,Property,Value)
	SELECT o.EntryID, CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name),CONVERT(nvarchar(255),ocf_val.pom_cf_value)
	FROM  @tblPanelData AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_entry_id =o.EntryID
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name IN ('PROD_PanelLength','PROD_PanelWidth')
UPDATE @tblPanelData 
	SET PanelLength=CONVERT(decimal(5,2),Prop.Value) 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_PanelLength'
UPDATE @tblPanelData 
	SET PanelWidth=CONVERT(decimal(5,2),Prop.Value) 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_PanelWidth'
UPDATE @tblPanelData
	SET BorderType=  CASE CONVERT(int,ocf_val.pom_cf_value)
		WHEN '1' THEN 'PT'
		WHEN '0' THEN 'TT'
		ELSE 'TT'
	END 
	FROM  @tblPanelData  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderNo
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='PROD_BorderType'
INSERT INTO @tblOCData (orderNo,EntryID) 
	SELECT Po.Pom_order_id,Pe.Pom_entry_id
	FROM @tblPanelData P
		INNER JOIN [SitMesDB].[dbo].POM_ORDER Po ON p.OrderNo=Po.pom_order_id
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY Pe ON Po.Pom_order_pk=Pe.Pom_order_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=REPLACE(Po.ppr_name,'PPR_','')
	WHERE Pe.Pom_entry_id like '%OverCast%'
		AND Pos.id IN ('Production','PreProduction')
	ORDER BY Pe.estimated_end_time ASC

DELETE FROM @tblProperty
INSERT INTO @tblProperty(EntryID,Property,Value)
	SELECT orderNo, CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name),CONVERT(nvarchar(255),ocf_val.pom_cf_value)
	FROM  @tblOCData AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_entry_id =o.EntryID
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name IN ('PROD_MLength','PROD_MWidth')
UPDATE @tblPanelData 
	SET PanelLength=CONVERT(decimal(5,2),Prop.Value) 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.OrderNo=Prop.EntryID
	WHERE Prop.Property='PROD_MLength'
UPDATE @tblPanelData 
	SET PanelWidth=CONVERT(decimal(5,2),Prop.Value) 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.OrderNo=Prop.EntryID
	WHERE Prop.Property='PROD_MWidth'

SELECT	MachineID											,
		OrderNo												,
		SKU													,
		ISNULL(SKUDesc,'')			as 'SKUDesc'			,
		ISNULL(PanelLength,'')		as 'PanelLength'		,
		ISNULL(PanelWidth,'')		as 'PanelWidth'			,
		ISNULL(BorderType,'TT')		as 'BorderType'			,
		ISNULL(UnitType,'')			as 'UnitType'			,
		ISNULL(MatSides,'')         as 'MatSides'
FROM  @tblPanelData
ORDER BY Seq	 ASC





GO
