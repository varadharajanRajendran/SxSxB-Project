SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_RptGetMCCHSchedule_v1]
		@MachineID nvarchar(50)		
 AS

/*
DECLARE @MachineID nvarchar(50)
SELECT @MachineID='MCCH01'
*/

DECLARE @tblMCCH as table (	rowid			int identity(1,1)	,
							OrderId			nvarchar(50)		,
							EntryID			nvarchar(50)		,
							SKU				nvarchar(255)		,
							SKUDesc			nvarchar(255)		,
							SA				nvarchar(255)		,
							BorderDec		nvarchar(50)		,
							RPNo			nvarchar(255)		,
							RDesc			nvarchar(255)		,
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
							EstStartTime	nvarchar(50)		,
							Sequence		int					,
							PL				int					)

DECLARE @tblParts as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							ItemClass	nvarchar(50)		,
							PartNo		nvarchar(255)		,
							Descripti	nvarchar(255)		)
DECLARE @tblProp as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
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
		AND Pos.id='Scheduled'
		AND E.equip_id='WPB.CML01.BC01.' + @MachineID
	ORDER BY Pe.sequence ASC		
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

SELECT Sequence												,
	   OrderID				as 'OrderID'					,
	   SKUDesc				as 'SKU Description'			,
	   BorderDec			as 'Border Decoration'			,
	   ISNULL(RDesc,'')		as 'Border Decoration Part No'	,
	   ISNULL(HNDesc,'')	as 'Handle Part No'				,
	   ISNULL(LBDesc,'')	as 'Label Description'			,
	   ISNULL(BLDesc,'')	as 'Label Description'			,
	   ISNULL(BLength,'')	as 'Border Length'				,
	   ISNULL(BWidth,'')	as 'Border Width'				,
	   ISNULL(HNStyle,'')	as 'Handle Style'				
FROM @tblMCCH 

GO
