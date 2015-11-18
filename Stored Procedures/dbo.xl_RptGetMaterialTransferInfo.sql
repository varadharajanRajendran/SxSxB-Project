SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[xl_RptGetMaterialTransferInfo]	
	@ShipmentDate nvarchar(50),
	 @ProdLine	  nvarchar(20)
AS

/*	
DECLARE	@ShipmentDate nvarchar(50),
	 @ProdLine	  nvarchar(20)

SELECT @ShipmentDate ='06-11-2015',
	    @ProdLine  = 'HYL01'
*/

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

INSERT INTO @tblOrders(OrderID,GroupID)	
	SELECT  Po.Pom_order_id AS 'OrderID', 
		CONVERT(int,ocf4_val.pom_cf_value) AS 'WaveGroup'                                                                        
    FROM [SitMesDB].[dbo].POM_ORDER AS  Po
            INNER JOIN [SitMesDB].[dbo].POM_ENTRY Pe ON Pe.Pom_entry_id=Po.Pom_order_id
            INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
            LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf1_rt ON Pe.pom_entry_pk = ocf1_rt.pom_entry_pk
            LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf2_rt ON Pe.pom_entry_pk = ocf2_rt.pom_entry_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf3_rt ON Pe.pom_entry_pk = ocf3_rt.pom_entry_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf4_rt ON Pe.pom_entry_pk = ocf4_rt.pom_entry_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf5_rt ON Pe.pom_entry_pk = ocf5_rt.pom_entry_pk
            LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf1_val ON ocf1_rt.pom_custom_field_rt_pk = ocf1_val.pom_custom_field_rt_pk
            LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf2_val ON ocf2_rt.pom_custom_field_rt_pk = ocf2_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf3_val ON ocf3_rt.pom_custom_field_rt_pk = ocf3_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf4_val ON ocf4_rt.pom_custom_field_rt_pk = ocf4_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf5_val ON ocf5_rt.pom_custom_field_rt_pk = ocf5_val.pom_custom_field_rt_pk
    WHERE Pos.id IN ('PreProduction','Production','Rework')
            AND CONVERT(nvarchar(20),ocf1_val.pom_cf_value)= @ShipmentDate
            AND ocf1_rt.pom_custom_fld_name='ShipmentDate'
            AND ocf2_rt.pom_custom_fld_name='ShipmentTime'
			AND ocf3_rt.pom_custom_fld_name='PreactorSequence'
			AND ocf4_rt.pom_custom_fld_name='WaveGroup'
			AND ocf5_rt.pom_custom_fld_name='ActualLine'
			AND ocf5_val.pom_cf_value=@ProdLine
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
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ01' THEN 'Panel Quilter 1'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ02' THEN 'Panel Quilter 2'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ03' THEN 'Panel Quilter 3'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.POC01' THEN 'Flanger 1'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.POC02' THEN 'Flanger 2'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BHC01' THEN 'BHC01'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BHC02' THEN 'BHC02'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.THC01' THEN 'THC01'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.THC02' THEN 'THC02'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BYPASS' THEN 'Border Decoration Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.NLET' THEN 'Border Decoration Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.RC01' THEN 'Border Decoration Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.RIBBON01' THEN 'Border Decoration Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.NLET' THEN 'Border Decoration Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.RC01' THEN 'Border Decoration Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.GA01'	THEN	'Gussett Assembly Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.HN01' THEN 'Handle'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.MCCH01' THEN 'MCCH01'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.MCCH02' THEN 'MCCH02'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BQC01.BQ' THEN 'Border Quilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BQC01.SLIT' THEN 'Border Slit'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PCA01.PCA01' THEN 'Hog Ring Assembly Table'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PCA01.PCA02' THEN 'Hog Ring Assembly Table'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.FEC01.FEC01' THEN 'FEC'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CEA01.CEA01' THEN 'Celestra Assembly Table'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.MU01.MU01' THEN 'MU'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BA01' THEN 'Build Station 1'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PA01' THEN 'Build Station 2'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CLS01.CLS01' THEN 'Closing Station 1'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CLS01.CLS02' THEN 'Closing Station 2'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.INS01.INS01' THEN 'Inspection'
		ELSE Eq.[equip_id]
	END,
	CASE (Eq.[equip_id]	)
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ01' THEN 'Panel Quilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ02' THEN 'Panel Quilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ03' THEN 'Panel Quilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.POC01' THEN 'Panel Quilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.POC02' THEN 'Panel Quilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BHC01' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BHC02' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.THC01' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.THC02' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BYPASS' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.NLET' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.RC01' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.RIBBON01' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.NLET' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.RC01' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.GA01'	THEN	'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.HN01' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.MCCH01' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.MCCH02' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BQC01.BQ' THEN 'Border Quilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BQC01.SLIT' THEN 'Border Quilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PCA01.PCA01' THEN 'Hog Ring'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PCA01.PCA02' THEN 'Hog Ring'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.FEC01.FEC01' THEN 'FEC'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CEA01.CEA01' THEN 'Celestra Assembly'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.MU01.MU01' THEN 'MU'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BA01' THEN 'Border'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PA01' THEN 'PanelQuilter'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CLS01.CLS01' THEN 'Closing Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CLS01.CLS02' THEN 'Closing Station'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.INS01.INS01' THEN 'Inspection'
		ELSE Eq.[equip_id]
	END,
	CASE (Eq.[equip_id]	)
		WHEN  E4.[equip_id] + '.'  + @ProdLine  + '.BQC01.BQ' THEN '0'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BQC01.SLIT' THEN '0'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ01' THEN '1'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ02' THEN '2'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PQ03' THEN '3'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.POC01' THEN '4'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.POC02' THEN '5'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BYPASS' THEN '6'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.RIBBON01' THEN '7'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.RC01' THEN '8'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.NLET' THEN '9'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.HN01' THEN '10'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.MCCH01' THEN '11'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.MCCH02' THEN '12'		
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BHC01' THEN '13'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BHC02' THEN '14'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.GA01'	THEN '15'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.THC01' THEN '16'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.THC02' THEN '17'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PCA01.PCA01' THEN '18'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PCA01.PCA02' THEN '18'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.FEC01.FEC01' THEN '19'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CEA01.CEA01' THEN '20'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.MU01.MU01' THEN '21'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.BC01.BA01' THEN '22'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.PQ01.PA01' THEN '23'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CLS01.CLS01' THEN '24'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.CLS01.CLS02' THEN '25'
		WHEN E4.[equip_id] + '.'  + @ProdLine  + '.INS01.INS01' THEN '26'
		ELSE '999'
	END
	FROM @tblOrders o
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON Po.pom_order_id=o.OrderID
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN  [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq ON Eq.equip_pk=e.equip_pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E2 ON Eq.[equip_prnt_pk]=E2.Equip_pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E3 ON E2.[equip_prnt_pk]=E3.Equip_pk
		INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E4 ON E3.[equip_prnt_pk]=E4.Equip_pk
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
	WHERE PropertyID=@ProdLine + '_FTPrimaryLocationAlias'
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
UPDATE @tblIntOrders
	SET ProdCell='Destaker/HogRing',
		ProdUnit='Destaker/HogRing'
	FROM @tblIntOrders
	WHERE ProdCell='Hog Ring'
		AND ProdUnit='Hog Ring Assembly Table'
		AND [Description] LIKE '%FOAM%'

SELECT o.GroupID,
	   o.ProdCell						as 'Production Cell',
	   o.ProdUnit						as 'Location',
	   o.ItemClass						as 'Item Class',
	   o.PartNo							as 'Part No',
	   ISNULL(o.[Description]	,'')	as 'Description',
	   ISNULL(o.Qty	,'')				as 'Quantity',
	   ISNULL(o.UoM,'')					as 'UoM' ,
	   ISNULL(o.StorageLocation,'')		as 'Storage Location'
FROM @tblIntOrders o 
ORDER BY o.GroupID,o.Seq, o.ItemClass	 ASC
GO
