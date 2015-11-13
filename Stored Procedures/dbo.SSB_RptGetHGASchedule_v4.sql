SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptGetHGASchedule_v4]		
 AS

DECLARE @tblOrder as table (	rowid			int identity(1,1)	,
								OrderId			nvarchar(50)		,
								EstDateTime		datetime			,
								SKU				nvarchar(255)		,
								SKUDesc			nvarchar(255)		,
								FEC				nvarchar(255)		,
								CoilPNo			nvarchar(255)		,
								CoilDesc		nvarchar(255)		,
								BSPPNo			nvarchar(255)		,
								BSPDesc			nvarchar(255)		,
								SYOPNo			nvarchar(255)		,
								SYODesc			nvarchar(255)		,
								SRPNo			nvarchar(255)		,
								SRDesc			nvarchar(255)		,
								ERPNo			nvarchar(255)		,
								ERDesc			nvarchar(255)		,
								BFPNo			nvarchar(255)		,
								BFDesc			nvarchar(255)		,
								
								BSSYPNo			nvarchar(255)		,
								BSSYDesc		nvarchar(255)		,
						
								BSBSPPNo		nvarchar(255)		,
								BSBSPDesc		nvarchar(255)		,

								BSFTPNo			nvarchar(255)		,
								BSFTDesc		nvarchar(255)		,

								FTPNo			nvarchar(255)		,
								FTDesc			nvarchar(255)		,
								seqID			int					)	
DECLARE @tblFEC as table (	rowid			int identity(1,1)	,
							OrderId			nvarchar(50)		,
							EntryID			nvarchar(50)		,
							SA				nvarchar(50)		)	
DECLARE @tblHGA as table (	rowid			int identity(1,1)	,
							OrderId			nvarchar(50)		,
							EntryID			nvarchar(50)		,
							SA				nvarchar(50)		)	
DECLARE @tblCUI as table (	rowid			int identity(1,1)	,
							OrderId			nvarchar(50)		,
							EntryID			nvarchar(50)		,
							SA				nvarchar(50)		)	
DECLARE @tblParts as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							ItemClass	nvarchar(50)		,
							PartNo		nvarchar(255)		,
							Descripti	nvarchar(255)		,
							SeqID		int					,
							tblUpdated	bit					)
DECLARE @tblProp as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							Prop		nvarchar(255)		,
							Pvalue		nvarchar(255)		)
DECLARE @tblEstTime as Table (  RowID			int identity(1,1) ,
								OrderID			nvarchar(50)	  ,
								EstDateTime		datetime	  )

INSERT INTO @tblEstTime (OrderID,EstDateTime)	
	SELECT Po.Pom_order_id , MAX( DATEADD(minute,-Pe.[estimated_end_time_bias],Pe.[estimated_end_time]))
	FROM [SitMesDB].[dbo].POM_ORDER AS  Po  
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
	WHERE (	Pe.Pom_entry_id like '%.BHC%' OR 
			Pe.Pom_entry_id like '%.PanelQuilt%' OR 
			Pe.Pom_entry_id like '%.THC%' )
		AND Pos.id='PreProduction'		
	GROUP BY Po.Pom_order_id
INSERT INTO @tblOrder(OrderId	,EstDateTime,SKU,SKUDesc)
	SELECT OrderID, Est.EstDateTime	, Pe.matl_def_id,  MM.Descript    
	FROM @tblEstTime Est
		INNER JOIN [SitMesDB].dbo.POM_Order Po ON Po.pom_order_id=Est.OrderID
		INNER JOIN	[SitMesDB].dbo.POM_Entry Pe  On Pe.Pom_entry_id=Po.Pom_Order_id
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Pe.matl_def_id 
	ORDER BY Est.EstDateTime,OrderID ASC	

INSERT INTO @tblFEC(OrderId	,EntryID,SA	)	
	SELECT o.OrderID		,
		   Pe.Pom_entry_id	,
		   ml.def_id
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].Pom_Order Po ON Po.Pom_order_id=o.OrderId
		INNER JOIN [SitMesDB].[dbo].Pom_entry Pe ON Pe.pom_order_pk=Po.pom_order_pk
		INNER JOIN [SitMesDB].[dbo].Pom_entry_Status Pes ON PeS.pom_entry_status_pk=Pe.pom_entry_status_pk
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON Pe.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE Pes.id='Initial'
		AND Pe.Pom_entry_id like '%.FEC1'
		AND ms.name='PRODUCED'
INSERT INTO @tblHGA(OrderId	,EntryID,SA	)	
	SELECT o.OrderID		,
		   Pe.Pom_entry_id	,
		   ml.def_id
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].Pom_Order Po ON Po.Pom_order_id=o.OrderId
		INNER JOIN [SitMesDB].[dbo].Pom_entry Pe ON Pe.pom_order_pk=Po.pom_order_pk
		INNER JOIN [SitMesDB].[dbo].Pom_entry_Status Pes ON PeS.pom_entry_status_pk=Pe.pom_entry_status_pk
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON Pe.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE Pes.id='Scheduled'
		AND Pe.Pom_entry_id like '%.PurchaseCoilAssem1'
		AND ms.name='PRODUCED'
INSERT INTO @tblCUI(OrderId	,EntryID,SA	)	
	SELECT o.OrderID		,
		   Pe.Pom_entry_id	,
		   ml.def_id
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].Pom_Order Po ON Po.Pom_order_id=o.OrderId
		INNER JOIN [SitMesDB].[dbo].Pom_entry Pe ON Pe.pom_order_pk=Po.pom_order_pk
		INNER JOIN [SitMesDB].[dbo].Pom_entry_Status Pes ON PeS.pom_entry_status_pk=Pe.pom_entry_status_pk
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON Pe.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE Pes.id='Initial'
		AND Pe.Pom_entry_id like '%.CUI1'
		AND ms.name='PRODUCED'
INSERT INTO @tblParts (OrderId,Itemclass,PartNo,Descripti,seqID,tblUpdated)
	SELECT o.OrderId,ml.class, ml.def_id,MM.Descript ,ml.seq,0
	FROM @tblHGA o 
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'

UPDATE @tblOrder
	SET SYOPNo =P.PartNo,
		SYODesc=P.Descripti,
		seqID=P.seqID
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE P.Descripti like 'SYO%'
UPDATE @tblParts
	SET tblUpdated=1
	FROM @tblOrder Po
		INNER JOIN @tblParts P ON P.SeqID=Po.SeqID
UPDATE @tblOrder
	SET BSPPNo =PartNo,
		BSPDesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE P.Descripti like 'BSP%'
UPDATE @tblOrder
	SET BSPPNo =PartNo,
		BSPDesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE P.Descripti like 'SYO%'
		AND tblUpdated=0
UPDATE @tblOrder
	SET CoilPNo =PartNo,
		CoilDesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE P.ItemClass ='RMMU'

DELETE FROM @tblParts
INSERT INTO @tblParts (OrderId,Itemclass,PartNo,Descripti)
	SELECT o.OrderId,ml.class, ml.def_id,MM.Descript 
	FROM @tblFEC o 
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
		AND ml.class <>'RMAC'
UPDATE @tblOrder
	SET SRPNo =PartNo,
		SRDesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE ( P.Descripti like '%SIDE%' OR P.Descripti like '%LENGTH%')
UPDATE @tblOrder
	SET ERPNo =PartNo,
		ERDesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE ( P.Descripti like '%END%' OR P.Descripti like '%WIDTH%')
UPDATE @tblOrder
	SET BFPNo =PartNo,
		BFDesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE P.ItemClass ='RMIN' or P.ItemClass ='RMFT' or P.ItemClass ='SABSMY'
UPDATE @tblOrder
	SET FEC ='AUTO'
	FROM @tblOrder o
	WHERE SRDesc is not NULL and ERDesc is not NULL
UPDATE @tblOrder
	SET FEC ='MANUAL'
	FROM @tblOrder o
	WHERE (SKU like '500705353%' OR  SKU like'500706552%'  OR  SKU like'500640342%')

UPDATE @tblOrder
  SET  BSSYPNo=MMD.DefID,
	   BSSYDesc=MMD.Descript
  FROM [SitMesDB].[dbo].[MMBomItemAlts] MMBIA
	INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MMBA ON MMBA.BomAltPK=MMBIA.BomAltPK
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD ON MMD.DefPK=MMBIA.DefPK
	INNER JOIN @tblOrder o ON o.BFPNo=MMBA.BomAltName
WHERE MMD.Descript like '%SYFI%'
UPDATE @tblOrder
  SET  BSBSPPNo=MMD.DefID,
	   BSBSPDesc=MMD.Descript
  FROM [SitMesDB].[dbo].[MMBomItemAlts] MMBIA
	INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MMBA ON MMBA.BomAltPK=MMBIA.BomAltPK
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD ON MMD.DefPK=MMBIA.DefPK
	INNER JOIN @tblOrder o ON o.BFPNo=MMBA.BomAltName
WHERE MMD.Descript like '%BSP%'
UPDATE @tblOrder
  SET  BSFTPNo=MMD.DefID,
	   BSFTDesc=MMD.Descript
  FROM [SitMesDB].[dbo].[MMBomItemAlts] MMBIA
	INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MMBA ON MMBA.BomAltPK=MMBIA.BomAltPK
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD ON MMD.DefPK=MMBIA.DefPK
	INNER JOIN [SitMesDB].[dbo].[MMClasses] MC ON MC.ClassPK=MMD.ClassPK
	INNER JOIN @tblOrder o ON o.BFPNo=MMBA.BomAltName
WHERE Mc.ClassID='RMFT'

DELETE FROM @tblParts
INSERT INTO @tblParts (OrderId,Itemclass,PartNo,Descripti)
	SELECT o.OrderId,ml.class, ml.def_id,MM.Descript 
	FROM @tblCUI o 
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
		AND ml.class<>'SAMFUY'
		AND ml.class<>'SAMWUY'
UPDATE @tblOrder
	SET FTPNo =PartNo,
		FTDesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE P.ItemClass ='RMIN'

SELECT '' as 'Group',
		o.RowId,
	   o.OrderID,
	   '' as 'Qty',
	   o.SKU,
	   MD.Descript			as 'Description',
	   ISNULL(o.FEC,'')		as 'FEC',
	   ISNULL(o.CoilDesc,'')	as 'Coil',
	   ISNULL(o.SYODesc,'')	as 'Oversize Pad',
	   ISNULL(o.BSPDesc,'')	as 'BSP',
	   ISNULL(o.SRDesc,'')	as 'Side Rail',
	   ISNULL(o.ERDesc,'')	as 'End Rail',
	   ISNULL(o.BFDesc,'')	as 'Base Foam',
	   ISNULL(o.BSFTDesc,'')	as 'BS FT',
	   ISNULL(o.BSSYDesc,'')	as 'BS SYFI',
	   ISNULL(o.BSBSPDesc,'') as 'BS BSP',
	   ISNULL(o.FTDesc,'')	as 'FT'
FROM @tblOrder o
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON [DefID]=o.SKU
	
GO
