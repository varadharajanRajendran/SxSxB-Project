SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[xl_RptGetPQSchedule]	
		@MachineID				nvarchar(20)    ,
	    @ShipmentDate			nvarchar(50)	,
		@ProdLine				nvarchar(20)    
AS 

/*
SELECT 	@ShipmentDate	= '05-11-2015'	,
		@MachineID='PQ01',	
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
									L5PNo			nvarchar(50)		,
									L5Desc			nvarchar(255)		,
									L6PNo			nvarchar(50)		,
									L6Desc			nvarchar(255)		,			
									NeedleBar		nvarchar(50)		,	
									NeedleSetting	nvarchar(50)		,	
									CAMDescription	nvarchar(50)		,
									Shape			nvarchar(50)		,
									PatternLength	decimal(5,2)		,
									PatternWidth	decimal(5,2)		,
									PatternType		nvarchar(50)		,
									MachineID		nvarchar(50)		,
									MachineType		nvarchar(50)		,
									Seq				int					,
									BorderType		nvarchar(20)		)
DECLARE	@tblProperty AS Table	(	RowId			int	IDENTITY		,
									EntryID			nvarchar(50)		,
									Property		nvarchar(50)		,
									Value			nvarchar(50)		)

INSERT INTO @tblPanelData (orderNo,EntryID,SKU,SKUDesc,seq,MachineID,MachineType)
	SELECT Po.Pom_order_id,Pe.Pom_entry_id,REPLACE(Po.ppr_name,'PPR_',''),MD.Descript,Pe.Sequence,REPLACE(E.equip_id, E4.[equip_id] + '.' + @ProdLine + '.' + E2.[equip_id] + '.',''),CASE(REPLACE(E.equip_id,E4.[equip_id] + '.' + @ProdLine + '.'+ E4.[equip_id] + '.',''))
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
		AND E.equip_id= E4.[equip_id] + '.' + @ProdLine + '.PQ01.' + @MachineID	
	ORDER BY Pe.Sequence ASC
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
	WHERE ocf_rt.pom_custom_fld_name IN ('PROD_PanelLength','PROD_PanelWidth','PROD_TickingID','PROD_BackingID','PROD_Fill1ID','PROD_Fill2ID','PROD_Fill3ID','PROD_Fill4ID','PROD_Fill5ID','PROD_Fill6ID','PROD_NeedleBar','PROD_NeedleSetting','PROD_CAMDescription','PROD_PatLength','PROD_PatWidth','PROD_Shape','PROD_PatType')
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
	SET L5PNo=Prop.Value ,
		L5Desc=MM.Descript
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Prop.Value 
	WHERE Prop.Property='PROD_Fill5ID'
UPDATE @tblPanelData 
	SET L6PNo=Prop.Value ,
		L6Desc=MM.Descript
	FROM @tblProperty Prop
		INNER JOIN @tblPanelData Po ON PO.EntryID=Prop.EntryID
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Prop.Value 
	WHERE Prop.Property='PROD_Fill6ID'
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


SELECT	'' as 'Qty'											,
		OrderNo												,
		SKU													,
		ISNULL(SKUDesc,'')			as 'SKUDesc'			,
		ISNULL(BKDesc,'')			as 'BKDesc'				,
		ISNULL(TKPNo,'')			as 'TKPartNo'			,	
		ISNULL(TKDesc,'')			as 'TKDesc'				,
		ISNULL(L1Desc,'')			as 'L1Desc'				,			
		ISNULL(L2Desc,'')			as 'L2Desc'				,			
		ISNULL(L3Desc,'')			as 'L3Desc'				,			
		ISNULL(L4Desc,'')			as 'L4Desc'				,
		ISNULL(L5Desc,'')			as 'L5Desc'				,			
		ISNULL(L6Desc,'')			as 'L6Desc'				,				
		ISNULL(NeedleSetting,'')	as 'NeedleSetting'		,	
		ISNULL(CAMDescription,'')	as 'CAMDescription'		,
		ISNULL(PanelLength,'')		as 'PanelLength'		,
		ISNULL(PanelWidth,'')		as 'PanelWidth'			,
		ISNULL(Shape,'')			as 'Shape'				,
		ISNULL(BorderType,'')		as 'BorderType'			
FROM  @tblPanelData





GO
