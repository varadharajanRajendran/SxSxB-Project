SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptGetPOSequence]
	@ShipmentDate	nvarchar(20),
	@SelOrders		nvarchar(50)	
AS
	
/*
DECLARE @ShipmentDate	nvarchar(20)	
SELECT 	@ShipmentDate	= '17-08-2015'	
*/
/*
DECLARE @ShipmentDate			nvarchar(50)	,
		@SelOrders				nvarchar(255)
SELECT 	@ShipmentDate	= '02-09-2015',
		@SelOrders		='New Orders'
*/
DECLARE	@tblOrder		AS Table	(	RowId			int	IDENTITY	,
										OrderID			nvarchar(100)	,
										SKU				nvarchar(50)	,
										TruckID			nvarchar(20)	,
										ShipmentDate	nvarchar(20)	,
										ShipmentTime	nvarchar(50)	,
										Wave			int				,
										UnitType		nvarchar(20)	,
										CoilDesc		nvarchar(200)	)
DECLARE	@tblEstTime		AS Table	(	RowId			int	IDENTITY	,
										OrderID			nvarchar(100)	,
										EstDateTime		nvarchar(20)	)
DECLARE @tblOrderSeq	AS Table	(	RowId			int	IDENTITY	,
										GroupID			int				,
										EstDateTime		nvarchar(20)	,
										Wave			int				,
										OrderID			nvarchar(100)	,
										SKU				nvarchar(50)	,
										[Description]	nvarchar(255)	,
										[Size]			nvarchar(20)	,
										[BedType]		nvarchar(5)		,
										[CoreType]		nvarchar(10)	,
										UnitType		nvarchar(20)	,
										Panel			nvarchar(20)	,	
										BorderDec		nvarchar(20)	,	
										MU				nvarchar(255)	,
										NoofSides		int				,
										TruckID			nvarchar(20)	,
										ShipmentDate	nvarchar(20)	,
										ShipmentTime	nvarchar(50)	,
										NoofLayers		int				,
										intMUT			nvarchar(5)		,
										intMT			nvarchar(5)		,
										CoilDesc		nvarchar(200)	)
DECLARE @tblOrdersbySKU	AS Table	(	RowId				int IDENTITY	,
										SKU				nvarchar(50)	,
										[Description]	nvarchar(255)	,
										[Size]			nvarchar(20)	,
										[BedType]		nvarchar(5)		,
										[CoreType]		nvarchar(10)	,
										UnitType		nvarchar(20)	,
										Panel			nvarchar(20)	,	
										BorderDec		nvarchar(20)	,	
										MU				nvarchar(255)	,
										NoofSides		int				,
										TruckID			nvarchar(20)	,
										ShipmentDate	nvarchar(20)	,
										ShipmentTime	nvarchar(50)	,
										Wave			int				,
										intQty			int				,
										GroupID			int				,
										CoilDesc		nvarchar(200)	)
DECLARE	@tblTruck AS Table	(	RowId				int	IDENTITY	,
								TruckID			nvarchar(100)		,
								ShipmentDate	nvarchar(20)		,
								ShipmentTime	nvarchar(20)		,
								Wave			int					)
DECLARE @SelOrderStatus			nvarchar(255)	,
		@PrevTruck				nvarchar(20)	,
		@PrevShipmentDate		nvarchar(20)	,
		@PrevShipmentTime		nvarchar(20)	,
		@PrevSKU				nvarchar(50)	,
		@PrevWave				nvarchar(20)	,
		@SelShipmentDate		nvarchar(20)	,
		@SelShipmentTime		nvarchar(20)	,
		@SelTruck				nvarchar(20)	,
		@SelSKU					nvarchar(50)	,
		@SelWave				int				,
		@SelQty					int				,
		@SQLStringCreateTable	nvarchar(MAX)	,
	    @SQLStringTruckList		nvarchar(MAX)	,
		@SQLStringInsertTime	nvarchar(MAX)	,
	    @SQLStringInsertDate	nvarchar(MAX)	,
		@SQLStringInsertWave	nvarchar(MAX)	,
		@SQLStringUpdateCount	nvarchar(MAX)	,	
		@TruckTime				nvarchar(MAX)	,	
		@TruckDate				nvarchar(MAX)	,	
		@TruckID				nvarchar(MAX)	,	
		@Wave					nvarchar(MAX)	,
		@GroupCount				int				,	
		@intStartRow			int				,
		@intEndRow				int				,
		@intRowCount			int			

SELECT @PrevTruck			=''	,
	   @PrevShipmentDate	=''	,
	   @PrevShipmentTime	=''	,
	   @PrevSKU				=''	,
	   @PrevWave			='' , 
	   @GroupCount			=0  ,
	   @SQLStringTruckList	='' ,
	   @TruckTime			='' ,
	   @TruckDate			=''	,
	   @Wave				=''	,
	   @TruckID				='' ,
	   @SelOrderStatus		=@SelOrders

BEGIN	/* Preliminary Data Preparation*/
	INSERT INTO @tblOrder (OrderID,SKU	,TruckID,ShipmentDate,ShipmentTime,Wave	,UnitType)
		SELECT	Po.Pom_order_id												  ,
				Pe.[matl_def_id]											  ,
				CONVERT(nvarchar(20),ocf3_val.pom_cf_value) as 'TruckID'	  ,
				CONVERT(nvarchar(20),ocf1_val.pom_cf_value) as 'ShipmentDate' ,
				CONVERT(nvarchar(20),ocf2_val.pom_cf_value) as 'ShipmentTime' ,	
				CONVERT(nvarchar(20),ocf4_val.pom_cf_value) as 'Wave'		  ,
				CONVERT(nvarchar(20),ocf5_val.pom_cf_value) as 'UnitType'	  
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
		WHERE Pos.id=@SelOrderStatus
			AND ocf1_val.pom_cf_value =@ShipmentDate
			/* AND CONVERT(nvarchar(20),ocf1_val.pom_cf_value) <=CONVERT(nvarchar(20),@EndDate) */
			AND ocf1_rt.pom_custom_fld_name='ShipmentDate' 
			AND ocf2_rt.pom_custom_fld_name='ShipmentTime'
			AND ocf3_rt.pom_custom_fld_name='TruckID'
			AND ocf4_rt.pom_custom_fld_name='WaveGroup'
			AND ocf5_rt.pom_custom_fld_name='MattressUnitType'
	UPDATE @tblOrder
		SET CoilDesc=MM.Descript 
		FROM @tblOrder Po
			INNER JOIN [SitMesDB].dbo.POM_Order AS o ON o.Pom_order_id=Po.OrderID
			INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_order_pk=o.pom_order_pk
			INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
			INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
		WHERE ms.name='CONSUMED'
			AND ml.class='RMMU'
	INSERT INTO @tblEstTime (OrderID,EstDateTime)	
		SELECT Po.Pom_order_id , MAX( DATEADD(minute,-Pe.[estimated_end_time_bias],Pe.[estimated_end_time]))
		FROM @tblOrder AS o
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
		WHERE (	Pe.Pom_entry_id like '%.BHC%' OR 
				Pe.Pom_entry_id like '%.PanelQuilt%' OR 
				Pe.Pom_entry_id like '%.THC%' )
		GROUP BY Po.Pom_order_id
	INSERT INTO @tblOrderSeq (OrderID,SKU,TruckID,ShipmentDate,ShipmentTime,Wave,UnitType,EstDateTime,CoilDesc)
		SELECT o.OrderID		,
			   o.SKU			,
			   o.TruckID		,
			   o.ShipmentDate	,
			   o.ShipmentTime	,
			   o.Wave			,
			   o.UnitType		,
			   Es.EstDateTime   ,
			   CoilDesc
		FROM @tblOrder AS o
			INNER JOIN @tblEstTime Es ON Es.OrderID=o.OrderID
		ORDER BY Es.EstDateTime ASC
	SELECT @intStartRow	=Min(RowID)	,
			@intEndRow	=Max(RowID)
	FROM   @tblOrderSeq
	WHILE @intStartRow<=@intEndRow
	BEGIN
		SELECT  @SelTruck		=TruckID		,
				@SelShipmentDate=ShipmentDate	,
				@SelShipmentTime=ShipmentTime	,
				@SelSKU			=SKU				
		FROM @tblOrderSeq
		WHERE RowID=@intStartRow
		/* SELECT @intStartRow as 'RowID',@SelSKU as 'SelSKU'	,@PrevSKU as 'PrevSKU',@SelTruck as 'SelTruck'	,@PrevTruck as 'PrevTruck',@GroupCount as 'GroupID' */
		IF  @SelTruck		=@PrevTruck			AND
			@SelShipmentDate=@PrevShipmentDate  AND
			@SelShipmentTime=@PrevShipmentTime  AND
			@SelSKU			=@PrevSKU		   
			BEGIN
				UPDATE @tblOrderSeq
					SET GroupID=@GroupCount
					WHERE RowID=@intStartRow
			END
			ELSE
			BEGIN
				SELECT  @PrevTruck			=@SelTruck			,
						@PrevShipmentDate	=@SelShipmentDate	,
						@PrevShipmentTime	=@SelShipmentTime	,
						@PrevSKU			=@SelSKU			,
						@GroupCount			=@GroupCount+1
				UPDATE @tblOrderSeq
					SET GroupID=@GroupCount
					WHERE RowID=@intStartRow
			END
		SELECT @intStartRow=@intStartRow +1
	END
END	
BEGIN   /*  Get SKU Details */		
	UPDATE @tblOrderSeq 
		SET [Description]	=	MMD.[Descript]									,
			[Size]			=   CASE CONVERT(nvarchar(255),MMBv1.PValue)
									WHEN '10' THEN 'TWIN'
									WHEN '20' THEN 'TWIN XL'
									WHEN '30' THEN 'FULL'
									WHEN '40' THEN 'FULL XL'
									WHEN '50' THEN 'QUEEN'
									WHEN '60' THEN 'KING'
									WHEN '70' THEN 'CAL KING'
									ELSE CONVERT(nvarchar(255),MMBv1.PValue)
								END												,
			[BedType]		=	CASE CONVERT(nvarchar(255),MMBv2.PValue)
									WHEN '0' THEN 'TT'
									WHEN '1' THEN 'PT'
									ELSE CONVERT(nvarchar(255),MMBv2.PValue)
								END												,
			[Panel]			=	CASE CONVERT(nvarchar(255),MMBv3.PValue)
									WHEN '1' THEN 'Quilt'
									WHEN '0' THEN 'non-Quilt'
								END												,
			[intMUT]		=	CASE o.UnitType
									WHEN 'PPKT' THEN 'IWC'
									ELSE o.UnitType
								END												,
			[intMT]			=	CASE CONVERT(nvarchar(255),MMBv6.PValue)
									WHEN '1' THEN 'FEC'
									WHEN '0' THEN ''
								END												,
			[BorderDec]		=	CONVERT(nvarchar(255),MMBv4.PValue)				,
			[NoofSides]		=	CONVERT(nvarchar(255),MMBv5.PValue)				,
			NoofLayers		=	CONVERT(nvarchar(255),MMBv7.PValue)					
			FROM @tblOrderSeq  o
				INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD ON MMD.[DefID]=o.SKU
				LEFT OUTER JOIN [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv1 ON MMBv1.DefID=o.SKU
				LEFT OUTER JOIN [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv2 ON MMBv2.DefID=o.SKU
				LEFT OUTER JOIN [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv3 ON MMBv3.DefID=o.SKU
				LEFT OUTER JOIN [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv4 ON MMBv4.DefID=o.SKU
				LEFT OUTER JOIN [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv5 ON MMBv5.DefID=o.SKU
				LEFT OUTER JOIN [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv6 ON MMBv6.DefID=o.SKU
				LEFT OUTER JOIN [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv7 ON MMBv7.DefID=o.SKU
			WHERE	MMBv1.PropertyID='UnitSize'
				AND MMBv2.PropertyID='BorderType'
				AND MMBv3.PropertyID='PanelType'
				AND MMBv4.PropertyID='BDType'
				AND MMBv5.PropertyID='MattressSides'
				AND MMBv6.PropertyID='MattressType'
				AND MMBv7.PropertyID='NOOFMULAYERS'
	UPDATE @tblOrderSeq /* Core Type */
		SET [CoreType]= CASE [intMT]
							WHEN '' THEN [intMUT] 
							ELSE [intMT] + ' (' + [intMUT] + ')'
						END						
	UPDATE @tblOrderSeq	
		SET MU=	CASE (o.NoofLayers)					
					WHEN '0' THEN 'Pass through'
					WHEN '1' THEN MD.[Descript]
					WHEN '2' THEN MD.[Descript] + '  /  ' + MD2.[Descript]
					WHEN '3' THEN MD.[Descript] + '  /  ' + MD2.[Descript] + '  /  ' + MD3.[Descript]
					WHEN '4' THEN MD.[Descript] + '  /  ' + MD2.[Descript] + '  /  ' + MD3.[Descript]  + '  /  ' + MD4.[Descript]
					WHEN '5' THEN MD.[Descript] + '  /  ' + MD2.[Descript] + '  /  ' + MD3.[Descript]  + '  /  ' + MD4.[Descript] + '  /  ' + MD5.[Descript]
					WHEN '6' THEN MD.[Descript] + '  /  ' + MD2.[Descript] + '  /  ' + MD3.[Descript]  + '  /  ' + MD4.[Descript] + '  /  ' + MD5.[Descript] + '  /  ' + MD6.[Descript]
					ELSE 'Pass Through'
				END
		FROM  @tblOrderSeq AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_entry_id = o.OrderID + '.MU1'
			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk AND ocf_rt.pom_custom_fld_name='PROD_L1PNo'
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=CONVERT(nvarchar(50),ocf_val.pom_cf_value)

			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf2_rt ON Pe.pom_entry_pk = ocf2_rt.pom_entry_pk AND ocf2_rt.pom_custom_fld_name='PROD_L2PNo'
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf2_val ON ocf2_rt.pom_custom_field_rt_pk = ocf2_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].[MMDefinitions] MD2 ON MD2.[DefID]=CONVERT(nvarchar(50),ocf2_val.pom_cf_value)

			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf3_rt ON Pe.pom_entry_pk = ocf3_rt.pom_entry_pk AND ocf3_rt.pom_custom_fld_name='PROD_L3PNo'
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf3_val ON ocf3_rt.pom_custom_field_rt_pk = ocf3_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].[MMDefinitions] MD3 ON MD3.[DefID]=CONVERT(nvarchar(50),ocf3_val.pom_cf_value)

			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf4_rt ON Pe.pom_entry_pk = ocf4_rt.pom_entry_pk AND ocf4_rt.pom_custom_fld_name='PROD_L4PNo'
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf4_val ON ocf4_rt.pom_custom_field_rt_pk = ocf4_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].[MMDefinitions] MD4 ON MD4.[DefID]=CONVERT(nvarchar(50),ocf4_val.pom_cf_value)

			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf5_rt ON Pe.pom_entry_pk = ocf5_rt.pom_entry_pk AND ocf5_rt.pom_custom_fld_name='PROD_L5PNo'
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf5_val ON ocf5_rt.pom_custom_field_rt_pk = ocf5_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].[MMDefinitions] MD5 ON MD5.[DefID]=CONVERT(nvarchar(50),ocf5_val.pom_cf_value)

			LEFT OUTER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf6_rt ON Pe.pom_entry_pk = ocf6_rt.pom_entry_pk AND ocf6_rt.pom_custom_fld_name='PROD_L6PNo'
			LEFT OUTER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf6_val ON ocf6_rt.pom_custom_field_rt_pk = ocf6_val.pom_custom_field_rt_pk
			LEFT OUTER JOIN [SitMesDB].[dbo].[MMDefinitions] MD6 ON MD6.[DefID]=CONVERT(nvarchar(50),ocf6_val.pom_cf_value)
			
END
BEGIN   /*  table Data Presentation  */
	INSERT INTO @tblOrdersbySKU (SKU,[Description],[Size],[BedType]	,[CoreType]	,UnitType,Panel	,BorderDec,MU,NoofSides,TruckID,ShipmentDate,ShipmentTime,Wave,intQty,GroupID,CoilDesc)
		SELECT	SKU,[Description],[Size],[BedType]	,[CoreType]	,UnitType,Panel	,BorderDec,	ISNULL(MU	,'Pass Through'),NoofSides,TruckID,ShipmentDate,ShipmentTime,Wave,COUNT(OrderID),GroupID,CoilDesc
		FROM @tblOrderSeq 
		GROUP BY GroupID,SKU,[Description],[Size],[BedType],[CoreType],UnitType,Panel,BorderDec,MU,NoofSides,TruckID,ShipmentDate,ShipmentTime,Wave	,CoilDesc
	INSERT INTO @tblTruck (TruckID,ShipmentDate,ShipmentTime,Wave)
		SELECT DISTINCT TruckID,ShipmentDate,ShipmentTime,Wave
		FROM  @tblOrdersbySKU
		ORDER BY Wave
    SELECT @intRowCount=COUNT(RowID) FROM @tblOrdersbySKU


	IF @intRowCount>0
	BEGIN
		IF OBJECT_ID('[SSB].[dbo].[POSchedule]') IS NOT NULL
			BEGIN
				DROP TABLE [SSB].[dbo].[POSchedule]
			END
		SELECT @SQLStringTruckList	='',
				@SelShipmentDate	='',
				@SelShipmentTime	='',
				@SelTruck			='',
				@SelWave			=''
		SELECT	@intStartRow	=MIN(RowID),
				@intEndRow		=MAX(RowID)
		FROM @tblTruck
		WHILE @intStartRow<=@intEndRow
		BEGIN
			SELECT	@SelTruck			=	TruckID  +  '_' + CONVERT(nvarchar(5),@intStartRow)  ,
					@SelShipmentTime	=	ShipmentTime	,
					@SelShipmentDate	=	ShipmentDate	,
					@SelWave			=	Wave			,
					@TruckTime			=	@TruckTime	 + ','  + CONVERT(nvarchar(20), char(39) + ShipmentTime + char(39)),
					@TruckDate			=	@TruckDate	 + ','  + CONVERT(nvarchar(20),+ char(39) + CONVERT(nvarchar(20), ShipmentDate) + char(39))	,
					@Wave				=	@Wave	 + ','  + CONVERT(nvarchar(20),+ char(39) + CONVERT(nvarchar(20), Wave) + char(39))				,
					@TruckID			=	@TruckID	 + ',['  + TruckID  +  '_' + CONVERT(nvarchar(5),@intStartRow)   + ']'						,
					@SQLStringTruckList	=	@SQLStringTruckList + '[' + TruckID  +  '_' + CONVERT(nvarchar(5),@intStartRow) + '] nvarchar(20) NULL,'
			FROM @tblTruck 
			WHERE RowID=@intStartRow
			SELECT @intStartRow=@intStartRow+1
		END
		SET @SQLStringCreateTable = 'CREATE TABLE [SSB].[dbo].[POSchedule]
								(	[RowID] [int] IDENTITY(1,1) NOT NULL,
									[SKU] [nvarchar](20) NULL,
									[Description] [nvarchar](255) NULL,
									[UnitType] [nvarchar](255) NULL,
									[Size] [nvarchar](20) NULL,
									[BedType] [nvarchar](5) NULL,
									[CoreType] [nvarchar](10) NULL,
									[Panel] [nvarchar](20) NULL,
									[BorderDec] [nvarchar](20) NULL,
									[MU] [nvarchar](255) NULL,
									[NoofSides] [int] NULL,
									[CoilDesc] nvarchar(200),
									[Qty] [int] NULL,' + 
									@SQLStringTruckList + '
									[Total] [int] NULL,
									)'
		EXEC (@SQLStringCreateTable)
		SELECT @TruckID=SUBSTRING(@TruckID,2,Len(@TruckID))
		SELECT @TruckDate=SUBSTRING(@TruckDate,2,Len(@TruckDate))
		SELECT @TruckTime=SUBSTRING(@TruckTime,2,Len(@TruckTime))
		SELECT @Wave=SUBSTRING(@Wave,2,Len(@Wave))
		SET @SQLStringInsertWave ='INSERT INTO [SSB].[dbo].[POSchedule] ([SKU],' + @TruckID + ') VALUES ( ' + char(39) + 'Wave' + char(39) + ',' + @Wave + ')'
		EXEC (@SQLStringInsertWave)
		SET @SQLStringInsertDate ='INSERT INTO [SSB].[dbo].[POSchedule] ([SKU],' + @TruckID + ') VALUES ( ' + char(39) + 'ShipmentDate' + char(39) + ',' + @TruckDate + ')'
		EXEC (@SQLStringInsertDate)
		SET  @SQLStringInsertTime ='INSERT INTO [SSB].[dbo].[POSchedule] ([SKU],' + @TruckID + ') VALUES ( ' + char(39) + 'ShipmentTime' + char(39) + ',' + @TruckTime + ')'
		EXEC (@SQLStringInsertTime)
		INSERT INTO [SSB].[dbo].[POSchedule] (	SKU,
												[Description]	,
												UnitType		,
												[Size]			,
												[BedType]		,
												[CoreType]		,
												Panel			,
												BorderDec		,
												MU				,
												NoofSides		,
												CoilDesc		)
									SELECT   SKU			,
											[Description]	,
											UnitType		,
											[Size]			,
											[BedType]		,
											[CoreType]		,
											Panel			,
											BorderDec		,
											MU				,
											NoofSides		,
											CoilDesc
									FROM @tblOrdersbySKU
									ORDER BY RowID
		SELECT @intStartRow=Min(RowId),
			   @intEndRow=Max(RowID)
		FROM @tblOrdersbySKU
		WHILE @intStartRow<=@intEndRow
		BEGIN
			SELECT  @SelSKU=SKU.SKU,
					@SelTruck=CONVERT(nvarchar(20), Truck.TruckID) + '_' + CONVERT(nvarchar(20), Truck.RowID),
					@SelQty=SKU.intQty
			FROM @tblOrdersbySKU AS SKU
				INNER JOIN  @tblTruck AS Truck ON Truck.TruckID=SKU.TruckID AND TRuck.ShipmentDate =SKU.ShipmentDate AND Truck.ShipmentTime=SKU.ShipmentTime
			WHERE SKU.RowID=@intStartRow

			SET @SQLStringInsertDate= 'UPDATE [SSB].[dbo].[POSchedule] SET ['+ @SelTruck + ']=' + CONVERT(nvarchar(20),@SelQty) + ' WHERE [SKU]=' + char(39) + CONVERT (nvarchar(20),@SelSKU) + char(39) + ' AND [RowID] = ' + CONVERT(nvarchar(20),@intStartRow + 3)
			EXEC (@SQLStringInsertDate) 
			
			SELECT @intStartRow=@intStartRow+1
		END
		
	END
END

SELECT * FROM [SSB].[dbo].[POSchedule] 
GO
