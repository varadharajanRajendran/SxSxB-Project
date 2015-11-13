SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[SSB_RptGetFECFoamData]		
AS
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

INSERT INTO @tblFECData (PartNo)
	SELECT DISTINCT(ml.def_id)	
	FROM [SitMesDB].[dbo].[POM_ORDER] Po
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[MMClasses] MMC ON MMC.ClassPK=mD.ClassPK
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.pom_order_status_pk=Po.pom_order_status_pk
	WHERE PoS.id ='PreProduction'
		AND  ms.name='CONSUMED' /* PRODUCED */
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
	SET FoamType=CONVERT(int,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblFECData MUD ON MUD.PartNo= MMD.DefID
	WHERE PropertyID='FoamType'
UPDATE @tblFECData
	SET [Length]=CONVERT(float,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblFECData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='FOAMTOPPERLENGTH'
UPDATE @tblFECData
	SET [Width]=CONVERT(float,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblFECData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='FOAMTOPPERWIDTH'
UPDATE @tblFECData
	SET Thickness=CONVERT(float,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblFECData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='FOAMTOPPERHEIGHT'
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
