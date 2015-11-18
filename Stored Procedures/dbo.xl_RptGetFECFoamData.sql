SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[xl_RptGetFECFoamData]	
	@ShipmentDate	nvarchar(20)	,
	@ProdLine		nvarchar(20)	
AS

/*
SELECT @ShipmentDate	='04-11-2015',
		@ProdLine		='PCL01'	 
*/
DECLARE	@tblOrder AS Table	(	RowId				int	IDENTITY	,
								OrderNo				nvarchar(100)	)
DECLARE	@tblFECData Table	(	RowId			int	IDENTITY	,
								PartNo			nvarchar(100)	,
								FoamType		int				,
								[Length]		float			,
								[Width]			float			,
								Thickness		float			,
								StorageLocation	int				,
								SYFIPNo			nvarchar(50)	,
								SYFIDesc		nvarchar(200)	,
								BSPPNo			nvarchar(50)	,
								BSPDesc			nvarchar(200)	)

DECLARE @startRow	int				,
		@EndRow		int				,
		@SelOrder	nvarchar(20)	,
		@count		int		

INSERT INTO @tblOrder (orderNo)
			SELECT  Po.Pom_order_id
			FROM [SitMesDB].[dbo].POM_ORDER AS  Po 
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
				INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
				INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
				INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt2 ON Pe.pom_entry_pk = ocf_rt2.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val2 ON ocf_rt2.pom_custom_field_rt_pk = ocf_val2.pom_custom_field_rt_pk
			WHERE Pos.id IN ('PreProduction','Production','Scheduled','To Be Scheduled','Rework','Download')
				AND ocf_rt.pom_custom_fld_name='ShipmentDate'
				AND ocf_val.pom_cf_value= @ShipmentDate
				AND ocf_rt2.pom_custom_fld_name='ActualLine'
				AND ocf_val2.pom_cf_value= @ProdLine

INSERT INTO @tblFECData (PartNo)
	SELECT DISTINCT(ml.def_id)	
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] AS Po ON Po.Pom_order_id=o.orderNo
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[MMClasses] MMC ON MMC.ClassPK=mD.ClassPK
	WHERE ms.name='CONSUMED' /* PRODUCED */
		AND MMC.ClassID IN ('RMFT', 'SABSMY','RMIN')
		AND e.pom_entry_id like '%.FEC%'
UPDATE @tblFECData
	SET SYFIPNo	=MMD.DefID,
		SYFIDesc=MMD.Descript
  FROM [SitMesDB].[dbo].[MMBomItemAlts] MMBIA
	INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MMBA ON MMBA.BomAltPK=MMBIA.BomAltPK
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD ON MMD.DefPK=MMBIA.DefPK
	INNER JOIN @tblFECData o ON o.PartNo=MMBA.BomAltName
WHERE MMD.Descript like '%SYFI%'
UPDATE @tblFECData
	SET BSPPNo	=MMD.DefID,
		BSPDesc=MMD.Descript
  FROM [SitMesDB].[dbo].[MMBomItemAlts] MMBIA
	INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MMBA ON MMBA.BomAltPK=MMBIA.BomAltPK
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD ON MMD.DefPK=MMBIA.DefPK
	INNER JOIN @tblFECData o ON o.PartNo=MMBA.BomAltName
WHERE MMD.Descript like '%BSP%'
UPDATE @tblFECData
	SET StorageLocation=CONVERT(int,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblFECData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='BFLocationAlias'
SELECT	PartNo			,
		StorageLocation ,
		ISNULL(SYFIPNo,'')	as 'SYFI PartNo',
		ISNULL(SYFIDesc,'') as 'SYFI Description',
		ISNULL(BSPPNo,'')	as 'BSP PartNo',
		ISNULL(BSPDesc,'')	as 'BSP Description'
FROM @tblFECData
GO
