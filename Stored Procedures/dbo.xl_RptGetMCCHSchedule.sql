SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[xl_RptGetMCCHSchedule]
	@ShipmentDate			nvarchar(50)	,
	@ProdLine				nvarchar(20)    
 AS

 /*
DECLARE	@ShipmentDate			nvarchar(50)	,
		@ProdLine				nvarchar(20)    

SELECT 	@ShipmentDate	= '05-11-2015'	,
		@ProdLine='CML01'	
*/

DECLARE @tblMCCH as table (	rowid			int identity(1,1)	,
							OrderId			nvarchar(50)		,
							EntryID			nvarchar(50)		,
							SKU				nvarchar(255)		,
							SKUDesc			nvarchar(255)		,
							UnitSize		nvarchar(50)		,
							SA				nvarchar(255)		,
							TKPNo			nvarchar(255)		,
							TKDesc			nvarchar(255)		,
							BorderDec		nvarchar(50)		,
							RPNo			nvarchar(255)		,
							RDesc			nvarchar(255)		,
							HTKPNo			nvarchar(255)		,
							HTKDesc			nvarchar(255)		,
							HNPNo			nvarchar(255)		,
							HNDesc			nvarchar(255)		,
							LBPNo			nvarchar(255)		,
							LBDesc			nvarchar(255)		,
							BLPNo			nvarchar(255)		,
							BLDesc			nvarchar(255)		,
							BLength			nvarchar(50)		,
							BWidth			nvarchar(50)		,
							HNStyle			nvarchar(50)		,
							WC				nvarchar(50)		,
							EstEndTime		datetime			,
							Sequence		int					,
							PL				int					,
							ShipmentDate	nvarchar(50)		,
							BorderType		nvarchar(20)		)

DECLARE @tblParts as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							ItemClass	nvarchar(50)		,
							PartNo		nvarchar(255)		,
							Descripti	nvarchar(255)		)
DECLARE @tblProp as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							Prop		nvarchar(255)		,
							Pvalue		nvarchar(255)		)

INSERT INTO @tblMCCH (OrderId,EntryID,WC,EstEndTime,Sequence,ShipmentDate)
	SELECT Po.Pom_order_id,Pe.pom_Entry_id,REPLACE(E.equip_id, E4.[equip_id] + '.' + @ProdLine + '.BC01.',''),Pe.estimated_end_time,Pe.sequence,CONVERT(nvarchar(20),ocf_val.pom_cf_value)
	FROM [SitMesDB].dbo.POM_Entry AS pe 
		INNER JOIN	[SitMesDB].dbo.POM_Entry_status Pes On Pes.Pom_Entry_status_pk=Pe.Pom_Entry_status_pk
		INNER JOIN 	[SitMesDB].dbo.POM_Order Po on Po.Pom_order_pk=Pe.Pom_order_pk
		INNER JOIN 	[SitMesDB].dbo.POM_Order_status PoS on Pos.Pom_order_status_pk=Po.Pom_order_status_pk
		INNER Join [SitMesDB].[dbo].BPM_EQUIPMENT E on E.equip_pk=Pe.equip_pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E2 ON E.[equip_prnt_pk]=E2.Equip_pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E3 ON E2.[equip_prnt_pk]=E3.Equip_pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E4 ON E3.[equip_prnt_pk]=E4.Equip_pk
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY Pe1 ON Pe1.Pom_order_pk=Po.pom_order_pk
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe1.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk					  
	WHERE E3.[equip_id]=E4.[equip_id] + '.'  + @ProdLine 
		AND Pos.id IN ('PreProduction','Production','Rework')
		AND ocf_rt.pom_custom_fld_name='ShipmentDate'
		AND ocf_val.pom_cf_value=@ShipmentDate
	    AND Pe.Pom_entry_id like '%.MCCHL1' 
		AND Pes.id='Initial'
	ORDER BY Pe.Sequence ASC
UPDATE @tblMCCH
	SET UnitSize=CONVERT(nvarchar(50),CONVERT(decimal(5,0),ocf_val.pom_cf_value))
	FROM  @tblMCCH  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='PROD_UnitSize'	
UPDATE @tblMCCH
	SET BorderType=  CASE CONVERT(int,ocf_val.pom_cf_value)
		WHEN '1' THEN 'PT'
		WHEN '0' THEN 'TT'
	END 
	FROM   @tblMCCH  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='PROD_BorderType'
UPDATE @tblMCCH
	SET SKU	= Pe.matl_def_id ,
		SKUDesc=MM.Descript
	FROM [SitMesDB].dbo.POM_Entry Pe 
		INNER JOIN @tblMCCH o	ON o.OrderID=Pe.Pom_entry_id
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Pe.matl_def_id 
UPDATE @tblMCCH
	SET SA=ml.def_id
	FROM  @tblMCCH o 
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id =o.entryid
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE ms.name='PRODUCED'
UPDATE @tblMCCH
	SET TKPNo=ml.def_id,
		TKDesc=MM.Descript 
	FROM @tblMCCH o 
		INNER JOIN [SitMesDB].dbo.POM_Order AS Po ON Po.pom_Order_id=o.OrderID
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_Order_Pk=Po.Pom_order_pk
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
		AND Pom_entry_id=o.OrderID + '.BorderDecRoll1'
		AND ml.class='RMTK'
UPDATE @tblMCCH
	SET HTKPNo=ml.def_id,
		HTKDesc=MM.Descript 
	FROM @tblMCCH o 
		INNER JOIN [SitMesDB].dbo.POM_Order AS Po ON Po.pom_Order_id=o.OrderID
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_Order_Pk=Po.Pom_order_pk
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
		AND Pom_entry_id=o.OrderID + '.HandleRoll1'
		AND ml.class='RMTK'
INSERT INTO @tblParts (OrderId,Itemclass,PartNo,Descripti)
	SELECT o.OrderId,ml.class, ml.def_id,MM.Descript 
	FROM @tblMCCH o 
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
UPDATE @tblMCCH
	SET RPNo=ISNULL(PartNo,'')	,
		RDesc=ISNULL(Descripti,''),
		BorderDec=CASE(ItemClass)
					WHEN 'SABROY' THEN 'Ribbon'
					WHEN 'SABRCY' THEN 'RibbonCord'
					WHEN 'SABRSY' THEN 'Ribbon Dec. Stitch'
					WHEN 'SABNLY' THEN 'NLet'
					WHEN 'SABBPY' THEN 'By-Pass'
				  END
	FROM	@tblParts P
	INNER JOIN @tblMCCH O ON o.OrderID=P.OrderID
	WHERE ItemClass IN ('SABROY','SABRCY','SABRSY','SABNLY','SABBPY')	
UPDATE @tblMCCH
	SET HNPNo=ISNULL(PartNo,'')	,
		HNDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblMCCH O ON o.OrderID=P.OrderID
	WHERE ItemClass IN ('SAHNAY')	
UPDATE @tblMCCH
	SET LBPNo=ISNULL(PartNo,'')	,
		LBDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblMCCH O ON o.OrderID=P.OrderID
	WHERE ItemClass IN ('RMLB')	
UPDATE @tblMCCH
	SET BLPNo=ISNULL(PartNo,'')	,
		BLDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblMCCH O ON o.OrderID=P.OrderID
	WHERE ItemClass IN ('RMBL')	
INSERT INTO @tblProp(OrderId,Prop,Pvalue)
	SELECT  o.OrderID,CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name),CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblMCCH AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.pom_entry_id = o.EntryID
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
UPDATE @tblMCCH
	SET BLength=Convert(decimal(5,2),Pvalue)
	FROM @tblProp Prop
		INNER JOIN @tblMCCH o ON o.OrderId=Prop.OrderId
	WHERE Prop.Prop='PROD_BorderLength'		
UPDATE @tblMCCH
	SET BWidth=Convert(decimal(5,2),Pvalue)
	FROM @tblProp Prop
		INNER JOIN @tblMCCH o ON o.OrderId=Prop.OrderId
	WHERE Prop.Prop='PROD_BorderWidth'	
UPDATE @tblMCCH
	SET HNStyle=Pvalue
	FROM @tblProp Prop
		INNER JOIN @tblMCCH o ON o.OrderId=Prop.OrderId
	WHERE Prop.Prop='PROD_HandleStyle'

SELECT OrderID				as 'OrderNo'		,
	   SKUDesc				as 'SKUDesc'		,
	   RIGHT(SKU,2)			as 'UnitSize'		,
	   ISNULL(TKDesc,'NONE')	as 'TKDesc'			,
	   ISNULL(HTKDesc,'NONE')	as 'HNTKDesc'		,
	   ISNULL(HNDesc,'NONE')	as 'HNDesc'			,
	   ISNULL(LBDesc,'NONE')	as 'LBDesc'			,
	   ISNULL(BLDesc,'NONE')	as 'BLDesc'			,
	   ISNULL(BWidth,'NONE')	as 'BorderWidth'	,
	   ISNULL(HNStyle,'NONE')	as 'HandleStyle'	,
	   WC		as 'MachineID'	,
	   ISNULL(BORDERTYPE,'TT')	as 'BorderType'
FROM @tblMCCH 
WHERE ShipmentDate=@ShipmentDate
ORDER BY Sequence ASC

GO
