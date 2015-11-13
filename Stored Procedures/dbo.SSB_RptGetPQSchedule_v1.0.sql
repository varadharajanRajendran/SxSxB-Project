SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_RptGetPQSchedule_v1.0]		
	@MachineID				nvarchar(20)		
AS

/*
DECLARE @MachineID			nvarchar(20),
		@StartDate			date		,
		@EndDate			date

SELECT 	@StartDate	= '14-07-2015'	,
		@EndDate	= '14-07-2015'	,	
		@MachineID	= 'PQ02'
*/

DECLARE @StartDate			nvarchar(20)	,
		@EndDate			nvarchar(20)

SELECT 	@StartDate	= '17-08-2015'	,
		@EndDate	= '18-08-2015'		

DECLARE	@tblPanelData AS Table	(	RowId			int	IDENTITY		,
									OrderNo			nvarchar(50)		,
									EntryID			nvarchar(50)		,
									SKU				nvarchar(50)		,
									PanelLength		decimal(5,2)		,
									PanelWidth		decimal(5,2)		,
									SA				nvarchar(50)		,
									Backing			nvarchar(50)		,
									Tick			nvarchar(50)		,
									Layer1			nvarchar(50)		,			
									Layer2			nvarchar(50)		,			
									Layer3			nvarchar(50)		,			
									Layer4			nvarchar(50)		,			
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
									Seq				int					)

DECLARE	@tblProperty AS Table	(	RowId			int	IDENTITY		,
									EntryID			nvarchar(50)		,
									Property		nvarchar(50)		,
									Value			nvarchar(50)		)

INSERT INTO @tblPanelData (orderNo,EntryID,SKU)
	SELECT Po.Pom_order_id,Pe.Pom_entry_id,REPLACE(Po.ppr_name,'PPR_','')
	FROM  [SitMesDB].[dbo].POM_ENTRY Pe
		INNER JOIN [SitMesDB].[dbo].POM_ORDER Po ON Po.Pom_order_pk=Pe.Pom_order_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
	WHERE Pe.Pom_entry_id like '%PanelQuilt%'
		AND Pos.id='Scheduled'

UPDATE @tblPanelData 
	SET SA=ml.def_id
	FROM @tblPanelData AS o
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON  e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
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
	SET Backing=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_BackingID'
UPDATE @tblPanelData 
	SET Tick=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_TickingID'
UPDATE @tblPanelData 
	SET Layer1=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_Fill1ID'
UPDATE @tblPanelData 
	SET Layer2=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_Fill2ID'
UPDATE @tblPanelData 
	SET Layer3=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
	WHERE Prop.Property='PROD_Fill3ID'
UPDATE @tblPanelData 
	SET Layer4=Prop.Value 
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
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



SELECT	Seq				,
		'' as 'Qty'     ,
		OrderNo			,
		SKU				,
		Backing			,
		Tick			,
		Layer1			,			
		Layer2			,			
		Layer3			,			
		Layer4			,			
		NeedleBar		,	
		NeedleSetting	,	
		CAMDescription	,
		PanelLength		,
		PanelWidth		,
		Shape			,
		PatternLength	,
		PatternWidth	,
		PatternType		,
		'' as 'Storage Location'		
FROM  @tblPanelData
where MachineID	=@MachineID
	AND Shipmentdate =@StartDate
ORDER BY Seq	ASC





GO
