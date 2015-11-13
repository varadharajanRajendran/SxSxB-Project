SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_RptGetHGASchedule_v1]		
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
								BFDesc			nvarchar(255)		)	
DECLARE @tblFEC as table (	rowid			int identity(1,1)	,
							OrderId			nvarchar(50)		,
							EntryID			nvarchar(50)		,
							SA				nvarchar(50)		)	
DECLARE @tblHGA as table (	rowid			int identity(1,1)	,
							OrderId			nvarchar(50)		,
							EntryID			nvarchar(50)		,
							SA				nvarchar(50)		)	
DECLARE @tblParts as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							ItemClass	nvarchar(50)		,
							PartNo		nvarchar(255)		,
							Descripti	nvarchar(255)		)
DECLARE @tblProp as table(	rowid		int identity(1,1)	,
							OrderId		nvarchar(50)		,
							Prop		nvarchar(255)		,
							Pvalue		nvarchar(255)		)

INSERT INTO @tblOrder(OrderId	,EstDateTime,SKU,SKUDesc)		
	SELECT Po.Pom_order_id			,
		   Po.estimated_end_time	, 
		   Pe.matl_def_id			,
		   MM.Descript    
	FROM [SitMesDB].dbo.POM_Order Po 
		INNER JOIN 	[SitMesDB].dbo.POM_Order_status PoS on Pos.Pom_order_status_pk=Po.Pom_order_status_pk
		INNER JOIN	[SitMesDB].dbo.POM_Entry Pe  On Pe.Pom_entry_id=Po.Pom_Order_id
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Pe.matl_def_id 
	WHERE Pos.id='Production'
	ORDER BY Po.estimated_end_time ASC	
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
	WHERE (SKU like '500705353%' OR  SKU like'500706552%')
		AND Pes.id='Initial'
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

INSERT INTO @tblParts (OrderId,Itemclass,PartNo,Descripti)
	SELECT o.OrderId,ml.class, ml.def_id,MM.Descript 
	FROM @tblHGA o 
		INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_entry_id=o.EntryID
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
UPDATE @tblOrder
	SET BSPPNo =PartNo,
		BSPDesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE P.Descripti like 'BSP%'
UPDATE @tblOrder
	SET SYOPNo =PartNo,
		SYODesc=Descripti
	FROM @tblParts P
		INNER JOIN @tblOrder o ON o.OrderID=P.OrderID
	WHERE P.Descripti like 'SYO%'
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
	WHERE P.ItemClass ='RMIN'
UPDATE @tblOrder
	SET FEC ='MANUAL'
	FROM @tblOrder o
		INNER JOIN @tblFEC FEC ON FEC.OrderID=o.OrderID


SELECT RowId,
	   OrderID,
	   SKU,
	   ISNULL(FEC,'') as 'FEC',
	   ISNULL(CoilDesc,'') as 'Coil',
	   ISNULL(BSPDesc,'')  as 'BSP',
	   ISNULL(SYODesc,'')  as 'Oversize Pad',
	   ISNULL(SRDesc,'')   as 'Side Rail',
	   ISNULL(ERDesc,'')   as 'End Rail',
	   ISNULL(BFDesc,'')   as 'Base Foam'
FROM @tblOrder
GO
