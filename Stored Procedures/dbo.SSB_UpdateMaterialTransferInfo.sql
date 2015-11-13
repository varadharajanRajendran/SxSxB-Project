SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[SSB_UpdateMaterialTransferInfo]	
	@ShipmentDate nvarchar(50)	
AS


DECLARE @tblOrders as Table ( rowid			int identity(1,1)	,
							   OrderId			nvarchar(50)		,
							   SKU				nvarchar(50)		,
							   SKUDesc			nvarchar(200)		,
							   UnitSize			int					,
							   GroupID			int					)

DECLARE @Entry as table	(	RowID			int identity(1,1),
							OrderID			nvarchar(50)	 ,
							EntryID			nvarchar(50)	 ,
							PartNo			nvarchar(50)	 ,
							Descrip			nvarchar(200)	 ,
							ItemClass		nvarchar(50)	 ,
							EqID			nvarchar(50)	 ,
							Cell			nvarchar(50)	 ,		
							Seq				int				 )	
DECLARE @Parts	as table (	RowID			int identity(1,1),
							OrderID			nvarchar(50)	 ,
							EntryID			nvarchar(50)	 ,
							PartNo			nvarchar(50)	 ,
							Descrip			nvarchar(200)	 ,
							ItemClass		nvarchar(50)	 ,
							Qty				decimal(8,3)	 ,
							UoM				nvarchar(20)	 )
DECLARE @tblIntOrders as Table (	RowID			int identity(1,1),
									GroupID			int				 ,
									Seq				int				 ,
									ProdCell		nvarchar(50)	 ,
									ProdUnit		nvarchar(50)	 ,
									ItemClass		nvarchar(50)	 ,
									PartNo			nvarchar(50)	 ,
									[Description]   nvarchar(255)	 ,
									Qty				nvarchar(10)	 ,
									UoM				nvarchar(20)	 ,
									StorageLocation	nvarchar(20)	 ,
									IsStatic		nvarchar(20)	 ,
									UnitSize		int				 )

DECLARE @tblTempParts as Table (	RowID			int identity(1,1),
									GroupID			int				 ,
									ProdCell		nvarchar(50)	 ,
									ProdUnit		nvarchar(50)	 ,
									PartNo			nvarchar(50)	 ,
									Qty				nvarchar(10)	 )

DECLARE @tblGroup	as table (	RowID			int identity(1,1),
								GroupID			nvarchar(50)	 )
DECLARE @StartGroup	int,
		@EndGroup	int,
		@SelGroup	int	,
		@SelQty		decimal(8,3),																		
		@SelPart	nvarchar(200)

INSERT INTO @tblOrders(OrderID)					
	SELECT  Po.Pom_order_id                                                                                 
    FROM [SitMesDB].[dbo].POM_ORDER AS  Po
            INNER JOIN [SitMesDB].[dbo].POM_ENTRY Pe ON Pe.Pom_entry_id=Po.Pom_order_id
            INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
            LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf1_rt ON Pe.pom_entry_pk = ocf1_rt.pom_entry_pk
            LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf2_rt ON Pe.pom_entry_pk = ocf2_rt.pom_entry_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf3_rt ON Pe.pom_entry_pk = ocf3_rt.pom_entry_pk
            LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf1_val ON ocf1_rt.pom_custom_field_rt_pk = ocf1_val.pom_custom_field_rt_pk
            LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf2_val ON ocf2_rt.pom_custom_field_rt_pk = ocf2_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf3_val ON ocf3_rt.pom_custom_field_rt_pk = ocf3_val.pom_custom_field_rt_pk
    WHERE Pos.id= 'PreProduction'
            AND CONVERT(nvarchar(20),ocf1_val.pom_cf_value) = @ShipmentDate
            AND ocf1_rt.pom_custom_fld_name='ShipmentDate'
            AND ocf2_rt.pom_custom_fld_name='ShipmentTime'
			AND ocf3_rt.pom_custom_fld_name='PreactorSequence'
    ORDER BY CONVERT(int,ocf3_val.pom_cf_value)  ASC

UPDATE @tblOrders
	SET GroupID =CASE
		WHEN RowID%60 >0 THEN (RowID/60)+1
		ELSE RowID/60
		END
	FROM @tblOrders
UPDATE @tblOrders
	SET SKU=Pe.[matl_def_id]			,
		SKUDesc=MM.[Descript]			,
		UnitSize=RIGHT (Pe.[matl_def_id],2)	 
	FROM @tblOrders AS  Po 
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY Pe ON Pe.Pom_entry_id=Po.OrderID
		INNER JOIN [SitMesDB].[dbo].MMDefinitions MM ON MM.DefID=Pe.matl_def_id

INSERT INTO @Entry( OrderID	,EntryID,PartNo,Descrip,ItemClass,EqID,Cell,seq	)
	SELECT o.OrderID,
	e.Pom_entry_id,
	ml.def_id,
	md.Descript,
	MMC.ClassID,
	CASE (Eq.[equip_id]	)
		WHEN 'WPB.CML01.PQ01.PQ01' THEN 'Panel Quilter 1'
		WHEN 'WPB.CML01.PQ01.PQ02' THEN 'Panel Quilter 2'
		WHEN 'WPB.CML01.PQ01.PQ03' THEN 'Panel Quilter 3'

		WHEN 'WPB.CML01.PQ01.POC01' THEN 'Flanger 1'
		WHEN 'WPB.CML01.PQ01.POC02' THEN 'Flanger 2'

		WHEN 'WPB.CML01.BC01.BHC01' THEN 'BHC01'
		WHEN 'WPB.CML01.BC01.BHC02' THEN 'BHC02'
		WHEN 'WPB.CML01.BC01.THC01' THEN 'THC01'
		WHEN 'WPB.CML01.BC01.THC02' THEN 'THC02'
		WHEN 'WPB.CML01.BC01.BYPASS' THEN 'Border Decoration Station'
		WHEN 'WPB.CML01.BC01.NLET' THEN 'Border Decoration Station'
		WHEN 'WPB.CML01.BC01.RC01' THEN 'Border Decoration Station'
		WHEN 'WPB.CML01.BC01.RIBBON01' THEN 'Border Decoration Station'
		WHEN 'WPB.CML01.BC01.NLET' THEN 'Border Decoration Station'
		WHEN 'WPB.CML01.BC01.RC01' THEN 'Border Decoration Station'
		WHEN 'WPB.CML01.BC01.GA01'	THEN	'Gussett Assembly Station'
		WHEN 'WPB.CML01.BC01.HN01' THEN 'Handle'
		WHEN 'WPB.CML01.BC01.MCCH01' THEN 'MCCH01'
		WHEN 'WPB.CML01.BC01.MCCH02' THEN 'MCCH02'
		WHEN 'WPB.CML01.BQC01.BQ' THEN 'Border Quilter'
		WHEN 'WPB.CML01.BQC01.SLIT' THEN 'Border Slit'
		
		WHEN 'WPB.CML01.CCU.PCA01' THEN 'Hog Ring Assembly Table'

		WHEN 'WPB.CML01.FEC01.FEC01' THEN 'FEC'

		WHEN 'WPB.CML01.CEA01.CEA01' THEN 'Celestra Assembly Table'

		WHEN 'WPB.CML01.MU01.MU01' THEN 'MU'

		WHEN 'WPB.CML01.BC01.BA01' THEN 'Build Station 1'

		WHEN 'WPB.CML01.PQ01.PA01' THEN 'Build Station 2'

		WHEN 'WPB.CML01.CLS01.CLS01' THEN 'Closing Station 1'
		WHEN 'WPB.CML01.CLS01.CLS02' THEN 'Closing Station 2'

		WHEN 'WPB.CML01.INS01.INS01' THEN 'Inspection'
	END,
	CASE (Eq.[equip_id]	)
		WHEN 'WPB.CML01.PQ01.PQ01' THEN 'Panel Quilter'
		WHEN 'WPB.CML01.PQ01.PQ02' THEN 'Panel Quilter'
		WHEN 'WPB.CML01.PQ01.PQ03' THEN 'Panel Quilter'

		WHEN 'WPB.CML01.PQ01.POC01' THEN 'Panel Quilter'
		WHEN 'WPB.CML01.PQ01.POC02' THEN 'Panel Quilter'

		WHEN 'WPB.CML01.BC01.BHC01' THEN 'Border'
		WHEN 'WPB.CML01.BC01.BHC02' THEN 'Border'
		WHEN 'WPB.CML01.BC01.THC01' THEN 'Border'
		WHEN 'WPB.CML01.BC01.THC02' THEN 'Border'
		WHEN 'WPB.CML01.BC01.BYPASS' THEN 'Border'
		WHEN 'WPB.CML01.BC01.NLET' THEN 'Border'
		WHEN 'WPB.CML01.BC01.RC01' THEN 'Border'
		WHEN 'WPB.CML01.BC01.RIBBON01' THEN 'Border'
		WHEN 'WPB.CML01.BC01.NLET' THEN 'Border'
		WHEN 'WPB.CML01.BC01.RC01' THEN 'Border'
		WHEN 'WPB.CML01.BC01.GA01'	THEN	'Border'
		WHEN 'WPB.CML01.BC01.HN01' THEN 'Border'
		WHEN 'WPB.CML01.BC01.MCCH01' THEN 'Border'
		WHEN 'WPB.CML01.BC01.MCCH02' THEN 'Border'
		WHEN 'WPB.CML01.BQC01.BQ' THEN 'Border Quilter'
		WHEN 'WPB.CML01.BQC01.SLIT' THEN 'Border Quilter'
		
		WHEN 'WPB.CML01.CCU.PCA01' THEN 'Hog Ring'

		WHEN 'WPB.CML01.FEC01.FEC01' THEN 'FEC'

		WHEN 'WPB.CML01.CEA01.CEA01' THEN 'Celestra Assembly'

		WHEN 'WPB.CML01.MU01.MU01' THEN 'MU'

		WHEN 'WPB.CML01.BC01.BA01' THEN 'Border'

		WHEN 'WPB.CML01.PQ01.PA01' THEN 'PanelQuilter'

		WHEN 'WPB.CML01.CLS01.CLS01' THEN 'Closing Station'
		WHEN 'WPB.CML01.CLS01.CLS02' THEN 'Closing Station'

		WHEN 'WPB.CML01.INS01.INS01' THEN 'Inspection'
	END,
	CASE (Eq.[equip_id]	)
		WHEN 'WPB.CML01.BQC01.BQ' THEN '0'
		WHEN 'WPB.CML01.BQC01.SLIT' THEN '0'
		
		WHEN 'WPB.CML01.PQ01.PQ01' THEN '1'
		WHEN 'WPB.CML01.PQ01.PQ02' THEN '2'
		WHEN 'WPB.CML01.PQ01.PQ03' THEN '3'

		WHEN 'WPB.CML01.PQ01.POC01' THEN '4'
		WHEN 'WPB.CML01.PQ01.POC02' THEN '5'

		WHEN 'WPB.CML01.BC01.BYPASS' THEN '6'
		WHEN 'WPB.CML01.BC01.RIBBON01' THEN '7'
		WHEN 'WPB.CML01.BC01.RC01' THEN '8'
		WHEN 'WPB.CML01.BC01.NLET' THEN '9'
		WHEN 'WPB.CML01.BC01.HN01' THEN '10'
		
		WHEN 'WPB.CML01.BC01.MCCH01' THEN '11'
		WHEN 'WPB.CML01.BC01.MCCH02' THEN '12'
				
		WHEN 'WPB.CML01.BC01.BHC01' THEN '13'
		WHEN 'WPB.CML01.BC01.BHC02' THEN '14'

		WHEN 'WPB.CML01.BC01.GA01'	THEN '15'
		WHEN 'WPB.CML01.BC01.THC01' THEN '16'
		WHEN 'WPB.CML01.BC01.THC02' THEN '17'

		WHEN 'WPB.CML01.CCU.PCA01' THEN '18'

		WHEN 'WPB.CML01.FEC01.FEC01' THEN '19'

		WHEN 'WPB.CML01.CEA01.CEA01' THEN '20'

		WHEN 'WPB.CML01.MU01.MU01' THEN '21'

		WHEN 'WPB.CML01.BC01.BA01' THEN '22'

		WHEN 'WPB.CML01.PQ01.PA01' THEN '23'

		WHEN 'WPB.CML01.CLS01.CLS01' THEN '24'
		WHEN 'WPB.CML01.CLS01.CLS02' THEN '25'

		WHEN 'WPB.CML01.INS01.INS01' THEN '26'
	END
	FROM @tblOrders o
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON Po.pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN  [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq ON Eq.equip_pk=e.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[MMClasses] MMC ON MMC.ClassPK=mD.ClassPK
	WHERE ms.name='Produced'
INSERT INTO @Parts( OrderID	,EntryID,PartNo,Descrip,ItemClass,Qty,UOM)
	SELECT o.OrderID,e.Pom_entry_id,ml.def_id,md.Descript,MMC.ClassID,ml.quantity,UoM.UoMID
	FROM @tblOrders o
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON Po.pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[MMClasses] MMC ON MMC.ClassPK=mD.ClassPK
		INNER JOIN [SitMesDB].[dbo].[MESUoMs] Uom ON UoM.UomPK=ml.Uom
	WHERE ms.name='CONSUMED'
		AND MMC.ClassID <>'SABBPY'
		AND MMC.ClassID <>'SABCAY'
		AND MMC.ClassID <>'SABNLY'
		AND MMC.ClassID <>'SABQAY'
		AND MMC.ClassID <>'SABRCY'
		AND MMC.ClassID <>'SABROY'
		AND MMC.ClassID <>'SAFBAY'
		AND MMC.ClassID <>'SAGSAY'
		AND MMC.ClassID <>'SAGSBY'
		AND MMC.ClassID <>'SAHNAY'
		AND MMC.ClassID <>'SAHNQY'
		AND MMC.ClassID <>'SAMFUY'
		AND MMC.ClassID <>'SAMWUY'
		AND MMC.ClassID <>'SAQPAY'
		AND MMC.ClassID <>'SAQPOY'
		AND MMC.ClassID <>'SASQBY'
		AND MMC.ClassID <>'SATCAY'

INSERT INTO @tblGroup(GroupID)
	SELECT DISTINCT(GroupID)
	FROM @tblOrders
SELECT @StartGroup=Min(RowID),
	   @EndGroup  =Max(RowID)
FROM @tblGroup
WHILE @StartGroup<=@EndGroup
	BEGIN
		SELECT @SelGRoup=GroupID
		FROM @tblGroup
		WHERE RowID=@StartGroup

		INSERT INTO @tblIntOrders(GroupID,Seq,ProdCell,ProdUnit,ItemClass,PartNo,[Description],UoM)
			SELECT @SelGRoup,e.Seq,e.Cell,e.EqID,P.ItemClass,P.PartNo,P.Descrip,P.UoM
			FROM @Parts P
				INNER JOIN @Entry e ON e.EntryID=P.EntryID
				INNER JOIN  @tblOrders o ON o.OrderID=e.OrderID 
			WHERE o.GroupID=@SelGroup
			GROUP BY e.Seq,e.Cell,e.EqID,P.PartNo,P.Descrip,P.ItemClass,P.UoM
		SELECT @StartGroup=@StartGroup+1
	END



	
SELECT @StartGroup=Min(RowID),
	   @EndGroup  =Max(RowID)
FROM @tblIntOrders
WHILE @StartGroup<=@EndGroup
	BEGIN
		Select @selGroup=GroupID,
			   @SelPart=PartNo
		FROM @tblIntOrders
		WHERE RowID=@StartGroup

		DELETE FROM @tblTempParts
		INSERT INTO @tblTempParts(GroupID,ProdCell,ProdUnit,PartNo,Qty)
			SELECT @SelGroup,e.cell,e.EqID,p.PartNo,SUM(P.Qty) FROM @Parts P
			INNER JOIN @Entry e ON e.EntryID=P.EntryID
			INNER JOIN  @tblOrders o ON o.OrderID=e.OrderID  
			WHERE o.GroupID=@SelGroup
			AND p.PartNo=@SelPart
			GROUP BY e.cell,e.EqID,p.PartNo,P.Descrip,P.Qty
		UPDATE @tblIntOrders
			SET Qty=P.Qty
			FROM @tblTempParts P
				INNER JOIN @tblIntOrders inO ON ino.PartNo=P.PartNo
			WHERE ino.ProdUnit=p.ProdUnit
				AND ino.ProdCell=p.ProdCell
				AND ino.GRoupID=@SelGroup

		SELECT @StartGroup=@StartGroup+1
	END

UPDATE @tblIntOrders
	SET IsStatic=Convert(bit,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblIntOrders MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='IsStatic' 
UPDATE @tblIntOrders
	SET StorageLocation=CONVERT(nvarchar(20),[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblIntOrders MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='LocationAlias'
UPDATE @tblIntOrders
  SET ProdCell='Hog Ring',
	  ProdUnit='Hog Ring Assembly Station',
	  seq=18	
  WHERE ProdCell='Celestra Assembly'
	AND ProdUnit	='Celestra Assembly Table'
	AND ItemClass='RMIN'

UPDATE @tblIntOrders
	SET ItemClass='RMFT',
		[Description]='BSP*BASE SUPPORT PAD/H1*FOAM TPR 1"'
	FROM @tblIntOrders
	WHERE ProdCell='FEC'
		AND ProdUnit='FEC'
		AND [Description]='BSP*BASE SUPPORT PAD'

UPDATE @tblIntOrders
   SET UnitSize=RIGHT(PartNo,2)
   WHERE LEN(PartNo)=9

INSERT INTO LSMaterialRequest (GroupID,ProdCell,ProdUnit,ItemClass,PartNo,[Description],Qty,UoM,StorageLocation)
SELECT o.GroupID,
	   o.ProdCell						as 'Production Cell',
	   o.ProdUnit						as 'Location',
	   o.ItemClass						as 'Item Class',
	   o.PartNo							as 'Part No',
	   ISNULL(o.[Description]	,'')	as 'Description',
	   ISNULL(o.Qty	,0)				as 'Quantity',
	   ISNULL(o.UoM,'')					as 'UoM' ,
	   ISNULL(o.StorageLocation,'')		as 'Storage Location'
FROM @tblIntOrders o 
WHERE o.Seq>0 
ORDER BY o.GroupID,o.Seq, o.ItemClass	 ASC
GO
