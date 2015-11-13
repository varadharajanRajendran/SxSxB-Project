SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_FEAssignLocation]
	@ProdLine NVARCHAR(20)
AS

/*
DECLARE @ProdLine NVARCHAR(10)
SELECT @ProdLine='CML01'
*/
DECLARE	@tblOrder AS Table	(	RowId				int	IDENTITY	,
								OrderNo				nvarchar(100)	)
DECLARE @tblTempFECData Table	(	RowId			int	IDENTITY	,
								PartNo			nvarchar(100)	,
								StorageLocation	int				,
								ItemClass		nvarchar(50)	,
								UnitSize		INT				)
DECLARE @tblFECData Table	(	RowId			int	IDENTITY	,
								PartNo			nvarchar(100)	,
								StorageLocation	int				,
								ItemClass		nvarchar(50)	,
								UnitSize		INT				)


DECLARE @startRow			INT				,
		@EndRow				INT				,
		@SelOrder			NVARCHAR(20)	,
		@count				INT				,
		@PartNo				NVARCHAR(20)	,
		@StorageLocation	varbinary(200)	,
		@itemClass			NVARCHAR(20)	,
		@unitSize			NVARCHAR(20)	,
		@DefVerPK			int				,
		@LocationAliasPK	int				,		
		@SelLoc				nvarchar(100)		
INSERT INTO @tblOrder (orderNo)
	SELECT  Po.Pom_order_id
	FROM [SitMesDB].[dbo].POM_ORDER AS  Po 
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		/*
		INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt2 ON Pe.pom_entry_pk = ocf_rt2.pom_entry_pk 
		INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val2 ON ocf_rt2.pom_custom_field_rt_pk = ocf_val2.pom_custom_field_rt_pk
		*/
	WHERE Pos.id IN ('PreProduction')
		/*
		AND ocf_rt2.pom_custom_fld_name='ActualLine'
		AND ocf_val2.pom_cf_value= @ProdLine
		*/
INSERT INTO @tblTempFECData (PartNo,ItemClass,UnitSize)
	SELECT DISTINCT ml.def_id,MMC.ClassID,RIGHT(ml.def_ID,2)
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] AS Po ON Po.Pom_order_id=o.orderNo
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[MMClasses] MMC ON MMC.ClassPK=mD.ClassPK
	WHERE ms.name='CONSUMED'
		AND MMC.ClassID IN ('RMFT', 'SABSMY','RMIN')
		AND e.pom_entry_id like '%.FEC%'
UPDATE @tblTempFECData
	SET StorageLocation=CONVERT(int,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblFECData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID=@ProdLine+'_FEPrimaryLocationAlias'
		AND [PValue] IS NULL OR [PValue]='0'
INSERT INTO @tblFECData(PartNo , StorageLocation ,ItemClass , UnitSize )
	SELECT PartNo	,StorageLocation,ItemClass,UnitSize FROM @tblTempFECData
	WHERE (StorageLocation IS NULL OR StorageLocation=0)
SELECT @startRow=Min(RowID),
	   @EndRow=MAX(RowID)
FROM @tblFECData
WHILE @startRow<=@EndRow
BEGIN
	SELECT	@PartNo=PartNo,
			@itemClass	=ItemClass,
			@unitSize	=unitSize	
	FROM @tblFECData
	WHERE RowId=@startRow
	IF @itemClass='SABSMY'
		BEGIN
			SELECT @SelLoc=CASE @unitSize
											WHEN '10' THEN '5'
											WHEN '20' THEN '8'
											WHEN '30' THEN '3'
											WHEN '40' THEN '8'
											WHEN '50' THEN '1'
											WHEN '60' THEN '7'
											WHEN '70' THEN '8'
									END
		END
	ELSE 
		BEGIN
			SELECT @SelLoc=CASE @unitSize
											WHEN '10' THEN '8'
											WHEN '20' THEN '8'
											WHEN '30' THEN '5'
											WHEN '40' THEN '8' 
											WHEN '50' THEN '2'
											WHEN '60' THEN '6'
											WHEN '70' THEN '8'
									END
		END
	SELECT @StorageLocation	=[Sitmesdb].dbo.MMfPropValToBin('',@SelLoc,'','')
	SELECT @DefVerPK=MMDV.[DefVerPK]
		FROM [SitMesDB].[dbo].[MMDefinitions] MMD
			INNER JOIN [SitMesDB].[dbo].[MMDefVers] MMDV ON MMDV.DefPK=MMD.DefPK
		WHERE MMD.DefID=@PartNo
		SELECT @LocationAliasPK	= [PropertyPK]
		FROM [SitMesDB].[dbo].[MMProperties]
		WHERE PropertyID=@ProdLine +'_FEPrimaryLocationAlias'
	UPDATE [SitMesDB].[dbo].MMDefVerPrpVals 
			SET PropValue = @StorageLocation,
			PropValChar = [SitMesDB].[dbo].MMfGetPropValChar(@StorageLocation),
			PropValDec  = [SitMesDB].[dbo].MMfGetPropValDec(@StorageLocation),
			PropValDate = [SitMesDB].[dbo].MMfGetPropValDate(@StorageLocation),
			LastUser = [SitMesDB].[dbo].MMfCtxUser(),
			LastUpdate = [SitMesDB].[dbo].MMfCtxDate(),
			RowUpdated = GetUTCDate(),
			LocalInfo = [SitMesDB].[dbo].MMfBuildLocalInfo(LocalInfo),
			ContextID = [SitMesDB].[dbo].MMfCtxContextID()
			WHERE   DefVerPK = @DefVerPK
				AND    PropertyPK = @LocationAliasPK
				AND    RowDeleted = Convert(bit, 0)
	SELECT @startRow=@startRow+1
END
GO
