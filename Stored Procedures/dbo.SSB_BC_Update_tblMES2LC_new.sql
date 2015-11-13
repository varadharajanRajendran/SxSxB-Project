SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_BC_Update_tblMES2LC_new]
AS

/*
Purpose   : Generate PLC Data for open Orders
Author    : Varadha R (Varadharajan.Rajendran@b-wi.com)
Revision  : Initial (Aug.11.2015)
*/


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
		DROP TABLE [SSB].[dbo].[MES2LC]
		SET @SQLStringCreateTable = 'CREATE TABLE [SSB].[dbo].[MES2LC] ([RowID] [int] IDENTITY(1,1) NOT NULL,'
									 + SUBSTRING(@LongString,1,LEN(@LongString)-1) + 
									 ' ,L1PDesc nvarchar(200) NULL,
										L1Qty nvarchar(10) NULL	,
										L1QtyUoM  nvarchar(10)  NULL ,
										
										L2PDesc nvarchar(200) NULL,
										L2Qty nvarchar(10) NULL	,
										L2QtyUoM  nvarchar(10) NULL  ,
										
										L3PDesc nvarchar(200) NULL,
										L3Qty nvarchar(10) NULL	,
										L3QtyUoM  nvarchar(10)NULL ,
										
										L4PDesc nvarchar(200) NULL,
										L4Qty nvarchar(10) NULL	,
										L4QtyUoM  nvarchar(10) NULL ,
										
										L5PDesc nvarchar(200) NULL,
										L5Qty nvarchar(10) NULL	,
										L5QtyUoM  nvarchar(10) NULL ,
										
										L6PDesc nvarchar(200) NULL,
										L6Qty nvarchar(10) NULL	,
										L6QtyUoM  nvarchar(10) NULL ,

										SRPNo		nvarchar(50) NULL,
										SRPDesc	nvarchar(200) NULL,
										SRQty		nvarchar(10) NULL,
										SRQtyUoM	nvarchar(10) NULL,

										ERPNo		nvarchar(50) NULL,
										ERPDesc	nvarchar(200) NULL,
										ERQty		nvarchar(10) NULL,
										ERQtyUoM	nvarchar(10) NULL,

										BFPNo		nvarchar(50) NULL,
										BFPDesc	nvarchar(200) NULL,
										BFQty		nvarchar(10) NULL,
										BFQtyUoM	nvarchar(10) NULL,

										MUSA		nvarchar(50) NULL,
										FECSA		nvarchar(50) NULL,
										PAPL		nvarchar(50) NULL,
										BAPL		nvarchar(50) NULL,
										PQ			nvarchar(10) NULL,
										EstTime		datetime	 NULL,
										EstSeq		int			 NULL,
										FECType		nvarchar(50) NULL)'
		EXEC (@SQLStringCreateTable)
	END
	BEGIN /* Get Order List, SKU and Description   */
		INSERT INTO [SSB].[dbo].[MES2LC](JobID,SKUNo)
			SELECT  Po.[pom_order_id]	,
					REPLACE(Po.[ppr_name],'PPR_','')
			FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
				INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] PeS On PeS.pom_entry_status_pk=Pe.pom_entry_status_pk
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po	ON	Po.pom_order_pk=Pe.pom_order_pk
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.pom_order_status_pk=Po.pom_order_status_pk
			WHERE PoS.id in('PreProduction')
				AND PeS.id IN('Scheduled')			/* it should be 'Scheduled' only */
				AND (Pe.pom_entry_id  like'%.SBCoil1'
						OR  Pe.pom_entry_id  like'%.PurchaseCoilAssem1%')

		UPDATE [SSB].[dbo].[MES2LC]
		  SET Product= MMD.Descript
		  FROM [SSB].[dbo].[MES2LC] Po
		  	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] Pe ON Pe.Pom_entry_id=Po.JobID
				INNER JOIN [SitMesDB].[dbo].MMDefinitions MMD ON MMD.DefID=Pe.Matl_def_id
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
			SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC]
										SET [' + @Selfield + ']= CONVERT(nvarchar(MAX),ocf_val.pom_cf_value)
										FROM  [SSB].[dbo].[MES2LC] AS o 
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
			SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC]
										 SET [' + @Selfield + ']= CONVERT(nvarchar(MAX),BAPV.PValue)
										 FROM  [SitMesDB].dbo.MMvBomAltPrpVals AS BAPV WITH (NOLOCK) 
											INNER JOIN  [SitMesDB].dbo.MMBomAlts AS BA WITH (NOLOCK) ON BA.BomAltPK = BAPV.BomAltPK 
											INNER JOIN  [SitMesDB].dbo.MMBoms AS B WITH (NOLOCK) ON B.BomPK = BA.BomPK 
											INNER JOIN  [SitMesDB].dbo.MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = B.DefPK 
											INNER JOIN  [SitMesDB].dbo.MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BAPV.PropertyPK 
											INNER JOIN  [SSB].[dbo].[MES2LC] Po ON Po.SKUNo=D.[DefID]
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
			EXEC [SSB].[dbo].[SSB_M2L_EntryGetProperties] @SelField=@Selfield,@Entry='MU1'
			SELECT @startRow=@startRow+1
		END
	    BEGIN  /* Part Description and Pick Location */	
			SELECT @startRow=1
			WHILE @startRow<=6
			BEGIN
				SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC] 
												SET   [L'+ CONVERT(nvarchar(2),@startRow) +'Pdesc]		=MD.[Descript]	,
													  [L'+ CONVERT(nvarchar(2),@startRow) +'Qty]		=ml.quantity	,
													  [L'+ CONVERT(nvarchar(2),@startRow) +'QtyUoM]	=uoms1.UomID	
													FROM   [SSB].[dbo].[MES2LC] AS o 
														INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Prop on Prop.Pom_order_id=o.JobID
														INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Prop.Pom_order_pk = e.pom_order_pk 
														INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
														INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
														INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id 
														LEFT OUTER JOIN [SitMesDB].[dbo].[MESUoMs] AS uoms1 ON ml.uom = uoms1.UomPK
													WHERE  ms.name='+ char(39) +'CONSUMED' + char(39) +'
														AND e.pom_entry_id like ' + char(39) +'%.MU%' + char(39) +'
														AND ml.def_id=o.L'+ CONVERT(nvarchar(2),@startRow) +'PNo'						
				
				EXEC (@SQLStringCreateTable)
				

				SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC] 
												SET L' + CONVERT(nvarchar(2),@startRow) + 'Loc=Convert(int,DVPV.PValue)
												FROM  [SSB].[dbo].[MES2LC] AS LCD 
													INNER JOIN [SitMesDB].[dbo].MMDefinitions AS D ON D.DefID = LCD.L' + CONVERT(nvarchar(2),@startRow) +'PNO
													INNER JOIN [SitMesDB].[dbo].MMDefVers AS DV ON D.DefPK = DV.DefPK 
													INNER JOIN [SitMesDB].[dbo].MMvDefVerPrpVals AS DVPV ON DV.DefVerPK = DVPV.DefVerPK 
													INNER JOIN [SitMesDB].[dbo].MMwProperties AS P ON P.PropertyPK = DVPV.PropertyPK
												WHERE P.PropertyID=' + char(39) +'LocationAlias' + char(39) 
				EXEC (@SQLStringCreateTable)
				
				SELECT @startRow=@startRow+1
			END
		END
		EXEC [SSB].[dbo].[SSB_M2L_EntryupdateSA] @Entry='MU1'
	END
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
			EXEC [SSB].[dbo].[SSB_M2L_EntryGetProperties] @SelField=@Selfield,@Entry='FEC1'
			SELECT @startRow=@startRow+1
		END	
		BEGIN /* Get Consumed Parts Property and Location*/
			UPDATE [SSB].[dbo].MES2LC
				SET [SRPNo]=ml.def_id ,
					[SRPDesc]=MD.[Descript] ,
					[SRQty]=ml.quantity , 
					[SRQtyUoM]=uoms1.UomID 
				FROM  [SSB].[dbo].MES2LC AS o 
						INNER JOIN  [SitMesDB].[dbo].[POM_Order] Po ON Po.Pom_order_id=o.JobID
						INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON e.pom_order_pk =Po.pom_order_pk 
						INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
						INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
						INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
						LEFT OUTER JOIN [SitMesDB].[dbo].[MESUoMs] AS uoms1 ON ml.uom = uoms1.UomPK 
				WHERE  ms.name='CONSUMED' /* PRODUCED */
					AND e.pom_entry_id like '%.FEC%'
					AND ( MD.[Descript]	 like '%SIDE%'
							OR MD.[Descript] like '%LENGTH%' )
			UPDATE [SSB].[dbo].MES2LC
				SET  [ERPNo]=ml.def_id ,
					[ERPDesc]=MD.[Descript] ,
					[ERQty]=ml.quantity , 
					[ERQtyUoM]=uoms1.UomID 
				FROM   [SSB].[dbo].MES2LC AS o 
					INNER JOIN  [SitMesDB].[dbo].[POM_Order] Po ON Po.Pom_order_id=o.JobID
					INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON e.pom_order_pk =Po.pom_order_pk 
					INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
					INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
					INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
					LEFT OUTER JOIN [SitMesDB].[dbo].[MESUoMs] AS uoms1 ON ml.uom = uoms1.UomPK 
				WHERE  ms.name='CONSUMED' /* PRODUCED */
					AND e.pom_entry_id like '%.FEC%'
					AND ( MD.[Descript]	 like '%END%'
							OR MD.[Descript] like '%WIDTH%' )
			UPDATE [SSB].[dbo].MES2LC
				SET  [BFPNo]=ml.def_id ,
						[BFPDesc]=MD.[Descript] ,
						[BFQty]=ml.quantity , 
						[BFQtyUoM]=uoms1.UomID 
				FROM   [SSB].[dbo].MES2LC AS o 
						INNER JOIN  [SitMesDB].[dbo].[POM_Order] Po ON Po.Pom_order_id=o.JobID
						INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON e.pom_order_pk =Po.pom_order_pk 
						INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
						INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
						INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
						LEFT OUTER JOIN [SitMesDB].[dbo].[MESUoMs] AS uoms1 ON ml.uom = uoms1.UomPK 
				WHERE  ms.name='CONSUMED' /* PRODUCED */
					AND e.pom_entry_id like '%.FEC%'
					AND ml.class IN ('RMFT','SABSMY','RMIN')
			UPDATE [SSB].[dbo].MES2LC
			SET  [BFLoc]=Convert(int,DVPV.PValue)
			FROM [SSB].[dbo].MES2LC AS LCD
				INNER JOIN [SitMesDB].[dbo].MMDefinitions AS D ON D.DefID =LCD.BFPNo
				INNER JOIN [SitMesDB].[dbo].MMDefVers AS DV ON D.DefPK = DV.DefPK 
				INNER JOIN [SitMesDB].[dbo].MMvDefVerPrpVals AS DVPV ON DV.DefVerPK = DVPV.DefVerPK 
				INNER JOIN [SitMesDB].[dbo].MMwProperties AS P ON P.PropertyPK = DVPV.PropertyPK
			WHERE P.PropertyID='BFLocationAlias'
		END
		EXEC [SSB].[dbo].[SSB_M2L_EntryupdateSA] @Entry='FEC1'	
		UPDATE [SSB].[dbo].[MES2LC]
			SET FECType='AUTO'
			WHERE [BFThick] is not NULL
				AND [SRThick]is not NULL
				AND [ERThick] is not NULL
				AND [RailHeight] is not NULL
		UPDATE [SSB].[dbo].[MES2LC]
			SET	FECType='MANUAL',
				[BFThick]='0',
				[BFLoc]='0',
				[SRThick]='0',
				[ERThick]='0',
				[RailHeight]='0'
		   WHERE ([SKUNo] like '500705353%' OR [SKUNo] like '500706552%')
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
			EXEC [SSB].[dbo].[SSB_M2L_EntryGetProperties] @SelField=@Selfield,@Entry='CUI1'
			SELECT @startRow=@startRow+1
		END	
	END
	BEGIN
		
		UPDATE [SSB].[dbo].MES2LC
			SET  BAPL=REPLACE(e.LocPath,'WPB.CML01.BC01.SL-BHC.','') 					
			FROM [SitMesDB].[dbo].[MMvLots] l
				INNER JOIN [SitMesDB].[dbo].[MMwLotCommitTo] c on c.LotPK = l.LotPK
				INNER JOIN [SitMesDB].[dbo].[MMvLocations] e on e.LocPK = l.LocPK
				INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] et on et.pom_order_id = c.CommitTo
				INNER JOIN [SSB].[dbo].MES2LC AS o  ON o.JobID=c.CommitTo 
			WHERE et.pom_entry_type_id = 'BHC'
				   AND e.LocPath like 'WPB.CML01.BC01.SL-BHC.BHC%' 
		UPDATE [SSB].[dbo].MES2LC
			SET  PAPL=REPLACE(e.LocPath,'WPB.CML01.PQ01.SL-PQ.','') 						
					FROM [SitMesDB].[dbo].[MMvLots] l
						INNER JOIN [SitMesDB].[dbo].[MMwLotCommitTo] c on c.LotPK = l.LotPK
						INNER JOIN [SitMesDB].[dbo].[MMvLocations] e on e.LocPK = l.LocPK
						INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] et on et.pom_order_id = c.CommitTo
						INNER JOIN [SSB].[dbo].MES2LC AS o  ON o.JobID=c.CommitTo
					WHERE e.LocPath like 'WPB.CML01.PQ01.SL-PQ.%' 
						AND et.pom_entry_type_id = 'OVERCAST'
		UPDATE [SSB].[dbo].MES2LC
			SET  PQ=CONVERT(nvarchar(10),REPLACE(eq.equip_id,'WPB.CML01.PQ01.',''))
			FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
			INNER JOIN [SSB].[dbo].MES2LC LC ON LC.JobID+'.PanelQuilt1'=Pe.Pom_entry_id
			INNER JOIN [SitMesDB].[dbo].[BPM_EQUIPMENT] eq ON eq.[equip_pk]=Pe.[equip_pk]
		
		INSERT INTO @tblEstTime (OrderID,EstDateTime)	
			SELECT Po.Pom_order_id , MAX( DATEADD(minute,-Pe.[estimated_end_time_bias],Pe.[estimated_end_time]))
			FROM [SSB].[dbo].MES2LC AS o
				INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.JobID
				INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
			WHERE (	Pe.Pom_entry_id like '%.BHC%' OR 
					Pe.Pom_entry_id like '%.PanelQuilt%' OR 
					Pe.Pom_entry_id like '%.THC%' )
			GROUP BY Po.Pom_order_id	
		
		
		UPDATE [SSB].[dbo].MES2LC
			SET EstTime	=Est.EstDateTime
			FROM [SSB].[dbo].MES2LC AS LC
				INNER JOIN @tblEstTime AS Est ON Est.OrderID=LC.JobID
		
		UPDATE [SSB].[dbo].MES2LC
			SET EstSeq	= CONVERT(int,ocf_val.pom_cf_value)  
			FROM  [SitMesDB].[dbo].POM_ENTRY AS Pe 
				INNER JOIN [SSB].[dbo].MES2LC AS LC ON LC.JobID=Pe.Pom_entry_id
				INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			WHERE ocf_rt.pom_custom_fld_name='PreactorSequence'
		
		/*
		UPDATE [SSB].[dbo].MES2LC
			SET EstTime	=Est.estimated_end_time
			FROM [SSB].[dbo].MES2LC AS LC
				INNER JOIN [SitmesDB].[dbo].Pom_order AS Est ON Est.Pom_order_id=LC.JobID
		*/
	
		
	END


END TRY
BEGIN CATCH
	SELECT @@Error as 'ErrorCode'
	SELECT ERROR_MESSAGE() AS 'ErrorMessage'
END CATCH
GO
