SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_RptGetBorderDecSchedule]
	@ShipmentDate nvarchar(50)	
 AS
/*
DECLARE @ShipmentDate nvarchar(50)
SELECT @ShipmentDate='17-08-2015'
*/

DECLARE @tblMCCH as table (	rowid				int identity(1,1)	,
							OrderId				nvarchar(50)		,
							EntryID				nvarchar(50)		,
							WC					nvarchar(50)		,
							EstStartTime		nvarchar(50)		,
							Sequence			int					)
DECLARE @tblBD as table (	rowid				int identity(1,1)	,
							OrderId				nvarchar(50)		,
							EntryID				nvarchar(50)		,
							SKU					nvarchar(255)		,
							SKUDesc				nvarchar(255)		,
							UnitSize			nvarchar(50)		,
							SA					nvarchar(255)		,
							TKPNo				nvarchar(255)		,
							TKDesc				nvarchar(255)		,
							BorderRollPNo		nvarchar(255)		,
							BorderRollDesc		nvarchar(255)		,
							RibbonPNo			nvarchar(255)		,
							RibbonDesc			nvarchar(255)		,
							CordPNo				nvarchar(255)		,
							CordDesc			nvarchar(255)		,
							TapePNo				nvarchar(255)		,
							TapeDesc			nvarchar(255)		,
							HTKPNo				nvarchar(255)		,
							HTKDesc				nvarchar(255)		,
							HandleRollPNo		nvarchar(255)		,
							HandleRollDesc		nvarchar(255)		,
							NletHeight			nvarchar(50)		,
							BorderWidth			nvarchar(50)		,
							HandleStyle			nvarchar(50)		,
							HandleWidth			nvarchar(50)		,
							WC					nvarchar(50)		,
							EstStartTime		nvarchar(50)		,
							Sequence			int					,
							ExWC				nvarchar(50)		,
							ShipmentDate		nvarchar(50)		)

DECLARE @tblParts as table(	rowid		int identity(1,1)	,
							EntryId		nvarchar(50)		,
							ItemClass	nvarchar(50)		,
							PartNo		nvarchar(255)		,
							Descripti	nvarchar(255)		)
DECLARE @tblProp as table(	rowid		int identity(1,1)	,
							EntryId		nvarchar(50)		,
							Prop		nvarchar(255)		,
							Pvalue		nvarchar(255)		)

INSERT INTO @tblMCCH (OrderId,EntryID,WC,EstStartTime,Sequence)
	SELECT Po.Pom_order_id,Pe.pom_Entry_id,REPLACE(E.equip_id,'WPB.CML01.BC01.',''),Pe.estimated_start_time,Pe.sequence
	FROM [SitMesDB].dbo.POM_Entry AS pe 
		INNER JOIN	[SitMesDB].dbo.POM_Entry_status Pes On Pes.Pom_Entry_status_pk=Pe.Pom_Entry_status_pk
		INNER JOIN 	[SitMesDB].dbo.POM_Order Po on Po.Pom_order_pk=Pe.Pom_order_pk
		INNER JOIN 	[SitMesDB].dbo.POM_Order_status PoS on Pos.Pom_order_status_pk=Po.Pom_order_status_pk
		INNER Join [SitMesDB].[dbo].BPM_EQUIPMENT E on E.equip_pk=Pe.equip_pk
	WHERE Pe.Pom_entry_id like '%.MCCHL1' 
		AND Pes.id='Initial'
		AND Pos.id='PreProduction'
	ORDER BY Pe.sequence ASC	
INSERT INTO @tblBD (OrderId,EntryID,WC,EstStartTime,Sequence,ExWC)
	SELECT Po.Pom_order_id,Pe.pom_Entry_id,REPLACE(E.equip_id,'WPB.CML01.BC01.',''),Pe.estimated_start_time,Pe.sequence,o.WC
	FROM @tblMCCH o
		INNER JOIN [SitMesDB].dbo.POM_ORDER Po ON Po.pom_order_id=o.OrderId
		INNER JOIN [SitMesDB].dbo.POM_Entry AS pe ON Pe.pom_order_pk=Po.pom_order_pk
		INNER JOIN	[SitMesDB].dbo.POM_Entry_status Pes On Pes.Pom_Entry_status_pk=Pe.Pom_Entry_status_pk
		INNER Join [SitMesDB].[dbo].BPM_EQUIPMENT E on E.equip_pk=Pe.equip_pk
	WHERE ( Pe.Pom_entry_id like '%.Ribbon1' OR 
			Pe.Pom_entry_id like '%.Handle1' )
		AND Pes.id='Initial'
	ORDER BY o.sequence ASC	
UPDATE @tblBD
	SET SKU	= Pe.matl_def_id ,
		SKUDesc=MM.Descript
	FROM [SitMesDB].dbo.POM_Entry Pe 
		INNER JOIN @tblBD o	ON o.OrderID=Pe.Pom_entry_id
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Pe.matl_def_id 
UPDATE @tblBD
	SET ShipmentDate=CONVERT(nvarchar(20),ocf_val.pom_cf_value)
	FROM  @tblBD  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='ShipmentDate'
UPDATE @tblBD
	SET UnitSize=CONVERT(nvarchar(50),CONVERT(decimal(5,0),ocf_val.pom_cf_value))
	FROM  @tblBD  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='PROD_UnitSize'
UPDATE @tblBD
	SET SA=ml.def_id
	FROM  @tblBD o 
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id =o.entryid
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE ms.name='PRODUCED'
UPDATE @tblBD
	SET TKPNo=ml.def_id,
		TKDesc=MM.Descript 
	FROM @tblBD o 
		INNER JOIN [SitMesDB].dbo.POM_Order AS Po ON Po.pom_Order_id=o.OrderID
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_Order_Pk=Po.Pom_order_pk
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
		AND Pom_entry_id=o.OrderID + '.BorderDecRoll1'
		AND ml.class IN ('RMTK','RMZC')
UPDATE @tblBD
	SET HTKPNo=ml.def_id,
		HTKDesc=MM.Descript 
	FROM @tblBD o 
		INNER JOIN [SitMesDB].dbo.POM_Order AS Po ON Po.pom_Order_id=o.OrderID
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_Order_Pk=Po.Pom_order_pk
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
		AND Pom_entry_id=o.OrderID + '.HandleRoll1'
		AND ml.class = 'RMTK'

INSERT INTO @tblParts (EntryId,Itemclass,PartNo,Descripti)
	SELECT o.EntryId,ml.class, ml.def_id,MM.Descript 
	FROM @tblBD o 
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
UPDATE @tblBD
	SET BorderRollPNo=ISNULL(PartNo,'')	,
		BorderRollDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBD O ON o.EntryID=P.EntryId
	WHERE ItemClass ='SABQAY'
UPDATE @tblBD
	SET HandleRollPNo=ISNULL(PartNo,'')	,
		HandleRollDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBD O ON o.EntryID=P.EntryId
	WHERE ItemClass ='SAHNQY'
UPDATE @tblBD
	SET RibbonPNo=ISNULL(PartNo,'')	,
		RibbonDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBD O ON o.EntryID=P.EntryId
	WHERE ItemClass ='RMRB'
UPDATE @tblBD
	SET CordPNo=ISNULL(PartNo,'')	,
		CordDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBD O ON o.EntryID=P.EntryId
	WHERE ItemClass ='RMCB'
UPDATE @tblBD
	SET TapePNo=ISNULL(PartNo,'')	,
		TapeDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBD O ON o.EntryID=P.EntryId
	WHERE ItemClass IN ('RMTP')	

INSERT INTO @tblProp(EntryId,Prop,Pvalue)
	SELECT  o.EntryID,CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name),CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblBD AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.pom_entry_id = o.EntryID
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
UPDATE @tblBD
	SET BorderWidth=Convert(decimal(6,2),Pvalue)
	FROM @tblProp Prop
		INNER JOIN @tblBD o ON o.EntryID=Prop.EntryId
	WHERE Prop.Prop='PROD_BorderWidth'		
UPDATE @tblBD
	SET NletHeight=Convert(decimal(6,2),Pvalue)
	FROM @tblProp Prop
		INNER JOIN @tblBD o ON o.EntryID=Prop.EntryId
	WHERE Prop.Prop='PROD_NletBrdrHt'		
UPDATE @tblBD
	SET HandleWidth=Convert(decimal(6,2),Pvalue)
	FROM @tblProp Prop
		INNER JOIN @tblBD o ON o.EntryID=Prop.EntryId
	WHERE Prop.Prop='PROD_HandleWidth'		
UPDATE @tblBD
	SET HandleStyle=Pvalue
	FROM @tblProp Prop
		INNER JOIN @tblBD o ON o.EntryID=Prop.EntryId
	WHERE Prop.Prop='PROD_HandleStyle'	

SELECT Case(WC)
			WHEN 'BYPASS' THEN  'By-Pass'
			WHEN 'NLET'   THEN	'NLet'
			WHEN 'RC01'   THEN	'Ribbon Cord'
	   		WHEN 'HN01'	  THEN	'Handle'
			WHEN 'RS01'	  THEN  'Ribbon Stitch'
			ELSE WC
	   END							as 'WorkCenter',
	   SKUDesc						as 'SKUDesc'		,
	   RIGHT(SKU,2)					as 'UnitSize'   ,
	   TKDesc						as 'TKDesc'		,
	   ISNULL(RibbonDesc,'')		as 'RibbonDesc'	,
	   ISNULL(CordDesc,'')			as 'CordDesc'	,
	   ISNULL(TapeDesc,'')			as 'TapeDesc'	,
	   ISNULL(BorderWidth,'')		as 'BorderWidth',

	   ISNULL(HTKDesc,'')			as 'HTKDesc'	,
	   ISNULL(HandleRollDesc,'')	as 'HandleDesc'	,
	   ISNULL(HandleWidth,'')		as 'HandleWidth',
	   ISNULL(HandleStyle,'')		as 'HandleStyle',			
	   OrderID						as 'OrderNo'	,
	   ExWC							as 'AssignedMCCH'		
FROM @tblBD 
WHERE ShipmentDate=@ShipmentDate
ORDER BY Sequence,WC ASC

GO
