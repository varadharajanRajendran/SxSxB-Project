SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[LS_FTAssignDYNLocation]
	@ProdLine NVARCHAR(20)
AS

/*
Purpose   : Reset the exisitng Dynamic location and create the new dynamic location during BC download
Author    : Varadha R (Varadharajan.Rajendran@b-wi.com)
Revision  : Initial (Nov.11.2015)
*/

DECLARE	@tblMUFTCurrentSetting Table	(	RowId			int	IDENTITY	,
											PartNo			nvarchar(100)	,
											StorageLocation	int				)
DECLARE @tblMUFTLocConfig Table	(	RowId					INT	IDENTITY	,
									StorageLocation			INT				)
DECLARE @tblMUFTNewOrders Table	(	RowId					INT	IDENTITY	,
									PartNo					NVARCHAR(100)	,
									StorageLocation			INT				)
DECLARE @startRow			INT				,
		@EndRow				INT				,
		@TempLoc			nvarchar(100)	,
		@PartNo				nvarchar(100)	,
		@StorageLocation	varbinary(200)	,
		@DefVerPK			int				,
		@LocationAliasPK	int				,		
		@SelLoc				nvarchar(100)	

INSERT INTO @tblMUFTNewOrders (PartNo,StorageLocation)
	SELECT DISTINCT ml.def_id,CONVERT(int,MMD1.PValue)
	FROM [SitMesDB].[dbo].[POM_ORDER] Po
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.pom_order_status_pk=Po.pom_order_status_pk
		INNER JOIN [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD ON MMD.DefID=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD1 ON MMD1.DefID=ml.def_id
	WHERE Pos.id ='PreProduction'
		AND ms.name='CONSUMED'
		AND e.pom_entry_id like '%.MU%'
		AND ml.def_id not like 'MWUY-%'
		AND MMD.PropertyID=@ProdLine+'_FTIsStatic'
		AND MMD1.PropertyID=@ProdLine+'_FTPrimaryLocationAlias'
		AND (MMD.PValue IS NULL OR MMD.PValue='0')
INSERT INTO @tblMUFTCurrentSetting (PartNo,StorageLocation)
	SELECT DISTINCT ml.def_id,CONVERT(int,ISNULL(MMD1.PValue,0))
	FROM [SitMesDB].[dbo].[POM_ORDER] Po
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD ON MMD.DefID=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD1 ON MMD1.DefID=ml.def_id
	WHERE ms.name='CONSUMED'
		AND e.pom_entry_id like '%.MU%'
		AND ml.def_id not like 'MWUY-%'
		AND MMD.PropertyID=@ProdLine + '_FTIsStatic' 
		AND MMD1.PropertyID=@ProdLine + '_FTPrimaryLocationAlias'
		AND (MMD.PValue IS NULL OR MMD.PValue='0')
		AND MMD1.PValue<>0  
DELETE @tblMUFTCurrentSetting 
FROM @tblMUFTCurrentSetting CS
INNER JOIN @tblMUFTNewOrders NwO ON NwO.PartNo=Cs.PartNo
BEGIN	/* Clean Existing Location */
	SELECT @StartRow=1,
		   @EndRow  =COUNT(PartNo)
	FROM @tblMUFTCurrentSetting
	WHILE @StartRow<=@EndRow
	BEGIN
		SELECT	TOP 1 @PartNo			=PartNo,
				  @StorageLocation	=[Sitmesdb].dbo.MMfPropValToBin('','0','','')
		FROM @tblMUFTCurrentSetting
		SELECT @DefVerPK=MMDV.[DefVerPK]
		FROM [SitMesDB].[dbo].[MMDefinitions] MMD
			INNER JOIN [SitMesDB].[dbo].[MMDefVers] MMDV ON MMDV.DefPK=MMD.DefPK
		WHERE MMD.DefID=@PartNo
		SELECT @LocationAliasPK	= [PropertyPK]
		FROM [SitMesDB].[dbo].[MMProperties]
		WHERE PropertyID=@ProdLine + '_FTPrimaryLocationAlias'
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

		DELETE FROM @tblMUFTCurrentSetting
		WHERE PartNo=@PartNo
		SELECT @StartRow=@StartRow+1
	END
END
BEGIN   /* Standard Configuration*/
	INSERT INTO @tblMUFTLocConfig
	SELECT LocationAlias 
	FROM SSB.dbo.CML01_FTDynLocations
	DELETE @tblMUFTLocConfig
	FROM @tblMUFTLocConfig LC
	INNER JOIN @tblMUFTNewOrders NwO ON NwO.StorageLocation=LC.StorageLocation	
END
BEGIN /*Assign New Location*/
   SELECT @startRow=MIN(RowId),
		  @EndRow=Max(RowID) 
	FROM @tblMUFTNewOrders
	WHILE @startRow<=@EndRow
	BEGIN
		SELECT  @TempLoc=StorageLocation,
				@PartNo			=PartNo
		FROM @tblMUFTNewOrders
		WHERE RowId=@startRow
		IF @TempLoc='0' OR @TempLoc='NULL' OR @TempLoc IS NULL
		BEGIN
			SELECT TOP 1 @SelLoc=StorageLocation
			FROM @tblMUFTLocConfig
			SELECT @StorageLocation	=[Sitmesdb].dbo.MMfPropValToBin('',@SelLoc,'','')
			SELECT @DefVerPK=MMDV.[DefVerPK]
			FROM [SitMesDB].[dbo].[MMDefinitions] MMD
				INNER JOIN [SitMesDB].[dbo].[MMDefVers] MMDV ON MMDV.DefPK=MMD.DefPK
			WHERE MMD.DefID=@PartNo
			SELECT @LocationAliasPK	= [PropertyPK]
			FROM [SitMesDB].[dbo].[MMProperties]
			WHERE PropertyID=@ProdLine + '_FTPrimaryLocationAlias'	
			UPDATE [SitMesDB].[dbo].MMDefVerPrpVals 
				SET PropValue = @StorageLocation,
					PropValChar = [SitMesDB].dbo.MMfGetPropValChar( @StorageLocation),
					PropValDec  = [SitMesDB].dbo.MMfGetPropValDec( @StorageLocation),
					PropValDate = [SitMesDB].dbo.MMfGetPropValDate(@StorageLocation),
					LastUser = [SitMesDB].[dbo].MMfCtxUser(),
					LastUpdate = [SitMesDB].[dbo].MMfCtxDate(),
					RowUpdated = GetUTCDate(),
					LocalInfo = [SitMesDB].[dbo].MMfBuildLocalInfo(LocalInfo),
					ContextID = [SitMesDB].[dbo].MMfCtxContextID()
				WHERE   DefVerPK = @DefVerPK
					AND    PropertyPK = @LocationAliasPK	
					AND    RowDeleted = Convert(bit, 0)
			DELETE FROM @tblMUFTLocConfig
			WHERE StorageLocation=@SelLoc
		END
		SELECT @startRow=@startRow+1
	END
END

GO
