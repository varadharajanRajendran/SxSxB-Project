SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_RptGetBHCSchedule_v2]
		@ShipmentDate nvarchar(50)		
 AS

 /*
DECLARE @ShipmentDate nvarchar(50)
SELECT @ShipmentDate='17-08-2015'
*/

DECLARE @tblBHC as table (	rowid			int identity(1,1)	,
							OrderId			nvarchar(50)		,
							EntryID			nvarchar(50)		,
							SKU				nvarchar(255)		,
							SKUDesc			nvarchar(255)		,
							UnitSize		nvarchar(50)		,
							SA				nvarchar(255)		,
							MCCHPNo			nvarchar(255)		,
							MCCHDesc		nvarchar(255)	,
							DKPNo			nvarchar(255)		,
							DKDesc			nvarchar(255)		,
							FLPNo			nvarchar(255)		,
							FLDesc			nvarchar(255)		,
							TPPNo			nvarchar(255)		,
							TPDesc			nvarchar(255)		,
							BWidth			nvarchar(50)		,
							WC				nvarchar(50)		,
							EstEndTime		datetime			,
							Sequence		int					,
							PL				int					,
							ShipmentDate	nvarchar(20)		)
DECLARE @tblParts as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							ItemClass	nvarchar(50)		,
							PartNo		nvarchar(255)		,
							Descripti	nvarchar(255)		)
DECLARE @tblProp as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							Prop		nvarchar(255)		,
							Pvalue		nvarchar(255)		)

INSERT INTO @tblBHC (OrderId,EntryID,WC,EstEndTime,Sequence)
	SELECT Po.Pom_order_id,Pe.pom_Entry_id,REPLACE(E.equip_id,'WPB.CML01.BC01.',''),Pe.estimated_end_time,Pe.sequence
	FROM [SitMesDB].dbo.POM_Entry AS pe 
		INNER JOIN	[SitMesDB].dbo.POM_Entry_status Pes On Pes.Pom_Entry_status_pk=Pe.Pom_Entry_status_pk
		INNER JOIN 	[SitMesDB].dbo.POM_Order Po on Po.Pom_order_pk=Pe.Pom_order_pk
		INNER JOIN 	[SitMesDB].dbo.POM_Order_status PoS on Pos.Pom_order_status_pk=Po.Pom_order_status_pk
		INNER Join [SitMesDB].[dbo].BPM_EQUIPMENT E on E.equip_pk=Pe.equip_pk
	WHERE Pe.Pom_entry_id like '%.BHC1'
		AND Pos.id='Production'
		/* AND E.equip_id='WPB.CML01.BC01.' + @MachineID */
	ORDER BY Pe.estimated_end_time ASC	

UPDATE @tblBHC
	SET ShipmentDate=CONVERT(nvarchar(20),ocf_val.pom_cf_value)
	FROM  @tblBHC  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='ShipmentDate'
UPDATE @tblBHC
	SET UnitSize=CONVERT(nvarchar(50),CONVERT(decimal(5,0),ocf_val.pom_cf_value))
	FROM  @tblBHC  AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE ocf_rt.pom_custom_fld_name='PROD_UnitSize'			
UPDATE @tblBHC
	SET SKU	= Pe.matl_def_id ,
		SKUDesc=MM.Descript
	FROM [SitMesDB].dbo.POM_Entry Pe 
		INNER JOIN @tblBHC o	ON o.OrderID=Pe.Pom_entry_id
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Pe.matl_def_id 
UPDATE @tblBHC
	SET SA=ml.def_id
	FROM  @tblBHC o 
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id =o.entryid
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE ms.name='PRODUCED'

INSERT INTO @tblParts (OrderId,Itemclass,PartNo,Descripti)
	SELECT o.OrderId,ml.class, ml.def_id,MM.Descript 
	FROM @tblBHC o 
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
UPDATE @tblBHC
	SET MCCHPNo=ISNULL(PartNo,'')	,
		MCCHDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBHC O ON o.OrderID=P.OrderID
	WHERE ItemClass ='SAFBAY'	
UPDATE @tblBHC
	SET DKPNo=ISNULL(PartNo,'')	,
		DKDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBHC O ON o.OrderID=P.OrderID
	WHERE ItemClass ='RMDK'	
UPDATE @tblBHC
	SET FLPNo=ISNULL(PartNo,'')	,
		FLDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBHC O ON o.OrderID=P.OrderID
	WHERE ItemClass IN ('RMFL')	
UPDATE @tblBHC
	SET TPPNo=ISNULL(PartNo,'')	,
		TPDesc=ISNULL(Descripti,'')
	FROM	@tblParts P
	INNER JOIN @tblBHC O ON o.OrderID=P.OrderID
	WHERE ItemClass IN ('RMTP')	

INSERT INTO @tblProp(OrderId,Prop,Pvalue)
	SELECT  o.OrderID,CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name),CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblBHC AS o 
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.pom_entry_id = o.EntryID
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk		
UPDATE @tblBHC
	SET BWidth=Convert(decimal(5,2),Pvalue)
	FROM @tblProp Prop
		INNER JOIN @tblBHC o ON o.OrderId=Prop.OrderId
	WHERE Prop.Prop='PROD_BorderWidth'	

SELECT OrderID				as 'OrderNo'			,
	   SKUDesc				as 'SKUDesc'			,
	   RIGHT(SKU,2)			as 'UnitSize'			,
	   /* ISNULL(UnitSize,'')	as 'UnitSize'			, */
	   ISNULL(TPDesc,'')	as 'TapeDesc'			,
	   ISNULL(BWidth,'')	as 'BorderWidth'		,
	   WC	
FROM @tblBHC 
WHERE ShipmentDate=@ShipmentDate
ORDER BY EstEndTime ASC

GO
