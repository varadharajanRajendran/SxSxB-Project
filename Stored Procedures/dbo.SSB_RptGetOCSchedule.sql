SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptGetOCSchedule]
	@ShipmentDate nvarchar(50)			
AS

/*
DECLARE @ShipmentDate nvarchar(50)	
SELECT 	@ShipmentDate	= '08-10-2015'	
*/


DECLARE	@tblPanelData AS Table	(	RowId			int	IDENTITY		,
									OrderNo			nvarchar(50)		,
									EntryID			nvarchar(50)		,
									SKU				nvarchar(50)		,
									SKUDesc			nvarchar(255)		,
									PanelLength		nvarchar(50)		,
									PanelWidth		nvarchar(50)		,
									SA				nvarchar(50)		,
									BKPNo			nvarchar(50)		,
									BKDesc			nvarchar(255)		,
									TKPNo			nvarchar(50)		,
									TKDesc			nvarchar(255)		,
									L1PNo			nvarchar(50)		,
									L1Desc			nvarchar(255)		,
									L2PNo			nvarchar(50)		,
									L2Desc			nvarchar(255)		,			
									L3PNo			nvarchar(50)		,
									L3Desc			nvarchar(255)		,
									L4PNo			nvarchar(50)		,
									L4Desc			nvarchar(255)		,				
									NeedleBar		nvarchar(50)		,	
									NeedleSetting	nvarchar(50)		,	
									CAMDescription	nvarchar(50)		,
									Shape			nvarchar(50)		,
									PatternLength	decimal(5,2)		,
									PatternWidth	decimal(5,2)		,
									PatternType		nvarchar(50)		,
									
									TruckID			nvarchar(50)		,
									StopID			nvarchar(50)		,
									Shipmentdate	nvarchar(20)		,
									ShipmentTime	nvarchar(50)		,
									MachineID		nvarchar(50)		,
									MachineType		nvarchar(50)		,
									Seq				int					,
									EstEndTime		datetime			,
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

INSERT INTO @tblPanelData (orderNo,EntryID,SKU,SKUDesc,EstEndTime)
	SELECT Po.Pom_order_id,Pe.Pom_entry_id,REPLACE(Po.ppr_name,'PPR_',''),MD.Descript,Pe.estimated_end_time
	FROM  [SitMesDB].[dbo].POM_ENTRY Pe
		INNER JOIN [SitMesDB].[dbo].POM_ORDER Po ON Po.Pom_order_pk=Pe.Pom_order_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=REPLACE(Po.ppr_name,'PPR_','')
	WHERE Pe.Pom_entry_id like '%PanelQuilt%'
		AND Pos.id='PreProduction'
	ORDER BY Pe.estimated_end_time ASC
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
	WHERE ocf_rt.pom_custom_fld_name IN ('PROD_PanelLength','PROD_PanelWidth','PROD_TickingID','PROD_BackingID','PROD_Fill1ID','PROD_Fill2ID','PROD_Fill3ID','PROD_Fill4ID','PROD_NeedleBar','PROD_NeedleSetting','PROD_CAMDescription','PROD_PatLength','PROD_PatWidth','PROD_Shape','PROD_PatType')
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
	SET BKPNo=Prop.Value ,
		BKDesc=MM.Descript
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Prop.Value 
	WHERE Prop.Property='PROD_BackingID'
UPDATE @tblPanelData 
	SET TKPNo=Prop.Value ,
		TKDesc=MM.Descript
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Prop.Value 
	WHERE Prop.Property='PROD_TickingID'
UPDATE @tblPanelData 
	SET L1PNo=Prop.Value ,
		L1Desc=MM.Descript
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Prop.Value 
	WHERE Prop.Property='PROD_Fill1ID'
UPDATE @tblPanelData 
	SET L2PNo=Prop.Value ,
		L2Desc=MM.Descript
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Prop.Value 
	WHERE Prop.Property='PROD_Fill2ID'
UPDATE @tblPanelData 
	SET L3PNo=Prop.Value ,
		L3Desc=MM.Descript
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Prop.Value 
	WHERE Prop.Property='PROD_Fill3ID'
UPDATE @tblPanelData 
	SET L4PNo=Prop.Value ,
		L4Desc=MM.Descript
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Prop.Value 
	WHERE Prop.Property='PROD_Fill4ID'
UPDATE @tblPanelData 
	SET NeedleBar=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_NeedleBar'
UPDATE @tblPanelData 
	SET NeedleSetting=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_NeedleSetting'
UPDATE @tblPanelData 
	SET CAMDescription=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_CAMDescription'
UPDATE @tblPanelData 
	SET PatternLength=CONVERT(decimal(5,2),Prop.Value) 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_PatLength'
UPDATE @tblPanelData 
	SET PatternWidth=CONVERT(decimal(5,2),Prop.Value)  
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_PatWidth'
UPDATE @tblPanelData 
	SET Shape=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_Shape'
UPDATE @tblPanelData 
	SET PatternType=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_PatType'

UPDATE @tblPanelData
	SET TruckID=CONVERT(nvarchar(20),ocf_val.pom_cf_value)
	FROM  @tblPanelData  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderNo
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='TruckID'
UPDATE @tblPanelData
	SET StopID=CONVERT(nvarchar(20),ocf_val.pom_cf_value)
	FROM  @tblPanelData  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderNo
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='StopLocationID'
UPDATE @tblPanelData
	SET ShipmentDate=CONVERT(nvarchar(20),ocf_val.pom_cf_value)
	FROM  @tblPanelData  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderNo
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='ShipmentDate'
UPDATE @tblPanelData
	SET ShipmentTime=CONVERT(nvarchar(20),ocf_val.pom_cf_value)
	FROM  @tblPanelData  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderNo
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='ShipmentTime'

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
UPDATE @tblPanelData
	SET seq=Sequence,
		MachineID=REPLACE(Be.equip_id,'WPB.CML01.PQ01.','')			,
		MachineType= CASE(REPLACE(Be.equip_id,'WPB.CML01.PQ01.',''))
						WHEN 'PQ01' THEN 'PAR'
						WHEN 'PQ02'	THEN 'V16'
						WHEN 'PQ03' THEN 'V16'
					 END
	FROM @tblPanelData o
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY Pe ON Pe.Pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].dbo.BPM_EQUIPMENT Be ON Be.equip_pk = Pe.equip_pk
INSERT INTO @tblOCData (orderNo,EntryID) 
	SELECT Po.Pom_order_id,Pe.Pom_entry_id
	FROM @tblPanelData P
		INNER JOIN [SitMesDB].[dbo].POM_ORDER Po ON p.OrderNo=Po.pom_order_id
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY Pe ON Po.Pom_order_pk=Pe.Pom_order_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=REPLACE(Po.ppr_name,'PPR_','')
	WHERE Pe.Pom_entry_id like '%OverCast%'
		AND Pos.id='Production'
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
where Shipmentdate =@ShipmentDate
ORDER BY EstEndTime	 ASC





GO
