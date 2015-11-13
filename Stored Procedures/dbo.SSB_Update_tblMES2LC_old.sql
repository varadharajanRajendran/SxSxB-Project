SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[SSB_Update_tblMES2LC_old]
	@ProdLineName  nvarchar(20)
AS

/* SELECT @ProdLineName='CML01' */
DECLARE @DistinctFields as Table (RowId			int IDENTITY  ,
								  FieldName		nvarchar(50)  ,
								  Attribute		nvarchar(20)  )
DECLARE	@tblEstTime		AS Table	(	RowId			int	IDENTITY	,
										OrderID			nvarchar(100)	,
										EstDateTime		datetime		)
DECLARE @startRow				int				,
		@EndRow					int				,
		@Selfield				nvarchar(200)	,
		@ResultField			nvarchar(200)	,
		@LongString				varchar(6000)	,
		@SQLStringCreateTable	varchar(8000)	

BEGIN TRY	
	BEGIN /* Create Table */	
		INSERT INTO @DistinctFields (FieldName,Attribute)
			SELECT [LCFnName]
				  ,[MESDataType]
			  FROM [SSB].[dbo].[MES2LCDataMap]
			  WHERE [LinkTable]=1
			  ORDER BY PLCSequence ASC
		SELECT @startRow= MIN(RowID) ,
				@EndRow	= MAX(RowID) 
		FROM @DistinctFields
		SELECT @LongString=''
		WHILE @startRow<=@EndRow
		BEGIN
			SELECT @LongString= @LongString+ '['+ FieldName + ']  ' + Attribute + ' NULL,  '
			FROM @DistinctFields
			WHERE RowID= @startRow
			SELECT  @startRow= @startRow+1
		END
		EXEC ('DROP TABLE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']') 
		SET @SQLStringCreateTable = 'CREATE TABLE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] ([RowID] [int] IDENTITY(1,1) NOT NULL,'
									 + SUBSTRING(@LongString,1,LEN(@LongString)-1) + 
									 ' ,BFPno		nvarchar(50) NULL,
										EstSeq		int			 NULL,
									    FECType		nvarchar(50) NULL)'
		EXEC (@SQLStringCreateTable)
	END
	BEGIN /* Get Order List, SKU and Description   */	
		SET @SQLStringCreateTable = 'INSERT INTO [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '](JobID,SKUNo)
			SELECT  Po.[pom_order_id]	,
					REPLACE(Po.[ppr_name],''PPR_'','''')
			FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
				INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] PeS On PeS.pom_entry_status_pk=Pe.pom_entry_status_pk
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po	ON	Po.pom_order_pk=Pe.pom_order_pk
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.pom_order_status_pk=Po.pom_order_status_pk
				INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E ON E.Equip_pk=Pe.Equip_Pk
				INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E2 ON E.[equip_prnt_pk]=E2.Equip_pk
				INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E3 ON E2.[equip_prnt_pk]=E3.Equip_pk
				INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E4 ON E3.[equip_prnt_pk]=E4.Equip_pk
			WHERE E3.[equip_id]=E4.[equip_id] + ''.'' + ''' + @ProdLineName  + '''
				AND PoS.id in(''PreProduction'')
				AND PeS.id IN(''Scheduled'')			
				AND (Pe.pom_entry_id  like ''%.SBCoil1''
						OR  Pe.pom_entry_id  like ''%.PurchaseCoilAssem1%'')'
		EXEC (@SQLStringCreateTable)
		SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] 
										SET Product= MMD.Descript
										FROM [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] Po
		  								INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] Pe ON Pe.Pom_entry_id=Po.JobID
										INNER JOIN [SitMesDB].[dbo].MMDefinitions MMD ON MMD.DefID=Pe.Matl_def_id'
		EXEC (@SQLStringCreateTable)

	END  
	BEGIN /* Get Order Properties   */
		DELETE FROM @DistinctFields
		INSERT INTO @DistinctFields (FieldName)
			SELECT [LCFnName]
			  FROM [SSB].[dbo].[MES2LCDataMap]
			  WHERE [LinkTable]=1
				AND Catagory IN('Order')
			  ORDER BY PLCSequence ASC
		SELECT @startRow= MIN(RowID) ,
				@EndRow	= MAX(RowID) 
		FROM @DistinctFields
		SELECT @Selfield=''
		WHILE @startRow<=@EndRow
		BEGIN
			SELECT @Selfield=FieldName
			FROM @DistinctFields
			WHERE RowID=@StartRow
			SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
										 SET [' + @Selfield + ']= CONVERT(nvarchar(MAX),ocf_val.pom_cf_value)
										 FROM  [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] AS o 
											INNER JOIN [SitMesDB].[dbo].POM_Order AS Po ON Po.Pom_order_id = o.JobID
											INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
											INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
											INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
											INNER JOIN [SSB].[dbo].[MES2LCDataMap] M2L ON M2L.[MESFnName]=ocf_rt.pom_custom_fld_name
										 WHERE Pe.Pom_entry_id=o.JobID
											AND M2L.[LCFnName]='  + char(39) +  @Selfield  + char(39)  
			EXEC (@SQLStringCreateTable)
			SELECT @startRow=@startRow+1
		END
	END
	BEGIN /* Get SKU Properties   */
		DELETE FROM @DistinctFields
		INSERT INTO @DistinctFields (FieldName)
			SELECT [LCFnName]
			  FROM [SSB].[dbo].[MES2LCDataMap]
			  WHERE [LinkTable]=1
				AND Catagory IN('SKU')
			  ORDER BY PLCSequence ASC
		SELECT @startRow= MIN(RowID) ,
				@EndRow	= MAX(RowID) 
		FROM @DistinctFields
		SELECT @Selfield=''
		WHILE @startRow<=@EndRow
		BEGIN
			SELECT @Selfield=FieldName
			FROM @DistinctFields
			WHERE RowID=@StartRow
			SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
										 SET [' + @Selfield + ']= CONVERT(nvarchar(MAX),BAPV.PValue)
										 FROM  [SitMesDB].dbo.MMvBomAltPrpVals AS BAPV WITH (NOLOCK) 
											INNER JOIN  [SitMesDB].dbo.MMBomAlts AS BA WITH (NOLOCK) ON BA.BomAltPK = BAPV.BomAltPK 
											INNER JOIN  [SitMesDB].dbo.MMBoms AS B WITH (NOLOCK) ON B.BomPK = BA.BomPK 
											INNER JOIN  [SitMesDB].dbo.MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = B.DefPK 
											INNER JOIN  [SitMesDB].dbo.MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BAPV.PropertyPK 
											INNER JOIN  [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] Po ON Po.SKUNo=D.[DefID]
											INNER JOIN  [SSB].[dbo].[MES2LCDataMap]  M2LM ON M2LM.[MESFnName]= P.PropertyID
										 WHERE [LCFnName]='  + char(39) +  @Selfield  + char(39)
			EXEC (@SQLStringCreateTable)
			SELECT @startRow=@startRow+1
		END
	END
	BEGIN /* Get MU Properties and Locations */
		DELETE FROM @DistinctFields
		INSERT INTO @DistinctFields (FieldName)
			SELECT [LCFnName]
			  FROM [SSB].[dbo].[MES2LCDataMap]
			  WHERE [LinkTable]=1
				AND Catagory IN('MU')
			  ORDER BY PLCSequence ASC	
		SELECT @startRow= MIN(RowID) ,
				@EndRow	= MAX(RowID) 
		FROM @DistinctFields
		SELECT @Selfield=''
		WHILE @startRow<=@EndRow
		BEGIN  /* Get MU Properties */ 
			SELECT @Selfield=FieldName
			FROM @DistinctFields
			WHERE RowID=@StartRow
			EXEC [SSB].[dbo].[SSB_M2L_EntryGetProperties] @ProdLine=@ProdLineName,@Entry='MU1' ,@SelField=@Selfield, @TransactionType='BC'
			SELECT @startRow=@startRow+1
		END
	    BEGIN  /* Part Description and Pick Location */	
			SELECT @startRow=1
			WHILE @startRow<=6
			BEGIN
				SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
												SET L' + CONVERT(nvarchar(2),@startRow) + 'Loc=Convert(int,DVPV.PValue)
												FROM  [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] AS LCD 
													INNER JOIN [SitMesDB].[dbo].MMDefinitions AS D ON D.DefID = LCD.L' + CONVERT(nvarchar(2),@startRow) +'PNO
													INNER JOIN [SitMesDB].[dbo].MMDefVers AS DV ON D.DefPK = DV.DefPK 
													INNER JOIN [SitMesDB].[dbo].MMvDefVerPrpVals AS DVPV ON DV.DefVerPK = DVPV.DefVerPK 
													INNER JOIN [SitMesDB].[dbo].MMwProperties AS P ON P.PropertyPK = DVPV.PropertyPK
												WHERE P.PropertyID=' + char(39) + @ProdLineName + '_FTPrimaryLocationAlias' + char(39) 
				EXEC (@SQLStringCreateTable)
				SELECT @startRow=@startRow+1
			END
		END
		/* EXEC [SSB].[dbo].[SSB_M2L_EntryupdateSA] @Entry='MU1' */
	END
	IF @ProdLineName<> 'HYL01'
		BEGIN
			BEGIN /* Get FEC Properties and Locations */
			DELETE FROM @DistinctFields
			INSERT INTO @DistinctFields (FieldName)
				SELECT [LCFnName]
				FROM [SSB].[dbo].[MES2LCDataMap]
				WHERE [LinkTable]=1
					AND Catagory IN('FEC')
				ORDER BY PLCSequence ASC
			SELECT @startRow= MIN(RowID) ,
					@EndRow	= MAX(RowID) 
			FROM @DistinctFields
			SELECT @Selfield=''
			WHILE @startRow<=@EndRow
				BEGIN  /* Get Properties */ 
					SELECT @Selfield=FieldName
					FROM @DistinctFields
					WHERE RowID=@StartRow
					EXEC [SSB].[dbo].[SSB_M2L_EntryGetProperties] @ProdLine=@ProdLineName,@Entry='FEC1' ,@SelField=@Selfield, @TransactionType='BC'
					SELECT @startRow=@startRow+1
				END	
				BEGIN /* Get BF_PartNo and Location*/
			EXEC (' UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
											SET  [BFPNo]=ml.def_id 
											FROM   [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] AS o 
												INNER JOIN  [SitMesDB].[dbo].[POM_Order] Po ON Po.Pom_order_id=o.JobID
												INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON e.pom_order_pk =Po.pom_order_pk 
												INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
												INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
												WHERE  ms.name=''CONSUMED''
												AND e.pom_entry_id like ''%.FEC%'' 
											    AND ml.class IN (''RMFT'',''SABSMY'',''RMIN'')')
			EXEC (' UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
											SET  [BFLoc]=Convert(int,DVPV.PValue)
											FROM [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] AS LCD
												INNER JOIN [SitMesDB].[dbo].MMDefinitions AS D ON D.DefID =LCD.BFPNo
												INNER JOIN [SitMesDB].[dbo].MMDefVers AS DV ON D.DefPK = DV.DefPK 
												INNER JOIN [SitMesDB].[dbo].MMvDefVerPrpVals AS DVPV ON DV.DefVerPK = DVPV.DefVerPK 
												INNER JOIN [SitMesDB].[dbo].MMwProperties AS P ON P.PropertyPK = DVPV.PropertyPK
											WHERE P.PropertyID=''BFLocationAlias''')
		END	
					EXEC (' UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
								SET FECType=''AUTO''
								WHERE [BFThick] is not NULL
									AND [SRThick]is not NULL
									AND [ERThick] is not NULL
									AND [RailHeight] is not NULL')
					EXEC (' UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
								SET	FECType=''MANUAL'',
									[BFThick]=''0'',
									[BFLoc]=''0'',
									[SRThick]=''0'',
									[ERThick]=''0'',
									[RailHeight]=''0''
							WHERE ([SKUNo] like ''500705353%'' OR [SKUNo] like ''500706552%'')')
			END
		END
	BEGIN /* Get CUI Properties and Locations */
		DELETE FROM @DistinctFields
		INSERT INTO @DistinctFields (FieldName)
			SELECT [LCFnName]
			  FROM [SSB].[dbo].[MES2LCDataMap]
			  WHERE [LinkTable]=1
				AND Catagory IN('CUI')
			  ORDER BY PLCSequence ASC
		SELECT @startRow= MIN(RowID) ,
				@EndRow	= MAX(RowID) 
		FROM @DistinctFields
		SELECT @Selfield=''
		WHILE @startRow<=@EndRow
		BEGIN  /* Get Properties */ 
			SELECT @Selfield=FieldName
			FROM @DistinctFields
			WHERE RowID=@StartRow
			EXEC [SSB].[dbo].[SSB_M2L_EntryGetProperties] @ProdLine=@ProdLineName,@Entry='CUI1' ,@SelField=@Selfield, @TransactionType='BC'
			SELECT @startRow=@startRow+1
		END	
	END	
	BEGIN	
		EXEC (' UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
					SET EstSeq	= CONVERT(int,ocf_val.pom_cf_value)  
					FROM  [SitMesDB].[dbo].POM_ENTRY AS Pe 
						INNER JOIN [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] AS LC ON LC.JobID=Pe.Pom_entry_id
						INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
						INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
					WHERE ocf_rt.pom_custom_fld_name=''PreactorSequence''')
	END
	IF @ProdLineName='HYL01'
	BEGIN
		SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + ']
										 SET [CoilStyle ]= CASE CONVERT(nvarchar(MAX),ocf_val.pom_cf_value)
																	WHEN ''FC'' THEN ''1''
																	WHEN ''FCC'' THEN ''1''
																	WHEN ''FCZ'' THEN ''1''
																	ELSE  ''0''
																  END
										 FROM  [SSB].[dbo].[MES2LC_BC_'+ @ProdLineName + '] AS o 
											INNER JOIN [SitMesDB].[dbo].POM_Order AS Po ON Po.Pom_order_id = o.JobID
											INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
											INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
											INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
										WHERE Pe.Pom_entry_id=o.JobID
											AND ocf_rt.pom_custom_fld_name=''MattressUnitType'''
		EXEC (@SQLStringCreateTable) 
	END
/*
SELECT	o.JobID,
		ocf_rt.pom_custom_fld_name, 
		CASE CONVERT(nvarchar(MAX),ocf_val.pom_cf_value)
			WHEN 'FC' THEN '1'
			WHEN 'FCC' THEN '1'
			WHEN 'FCZ' THEN '1'
			ELSE  '0'
		END
FROM  [SSB].[dbo].[MES2LC_BC_HYL01] AS o 
	INNER JOIN [SitMesDB].[dbo].POM_Order AS Po ON Po.Pom_order_id = o.JobID
	INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
	INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
	INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
WHERE Pe.Pom_entry_id=o.JobID
	AND ocf_rt.pom_custom_fld_name='MattressUnitType'
*/
END TRY
BEGIN CATCH
	SELECT @@Error as 'ErrorCode'
	SELECT ERROR_MESSAGE() AS 'ErrorMessage'
END CATCH
GO
