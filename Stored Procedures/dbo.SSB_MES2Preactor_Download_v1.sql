SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_MES2Preactor_Download_v1]
AS

DECLARE	@tblOrders AS Table	(	RowId				int	IDENTITY	,
								PID					int				,
								OrderID				nvarchar(50)	,
								ProcessType			nvarchar(50)	,
								PlantNo				nvarchar(50)	,
								EntryID				nvarchar(50)	,
								CustomerNo			nvarchar(255)	,
								CustomerName		nvarchar(255)	,
								CustomerOrderNo		nvarchar(50)	,
								CustomerOrderLineNo	nvarchar(50)	,
								TruckID				nvarchar(50)	,
								StopID				nvarchar(50)	,
								DueDate				date			,
								DueTime				time(7)			,
								FGPart				nvarchar(50)	,
								FGPartDesc			nvarchar(255)	,
								[Quantity]			int				,
								SAPart				nvarchar(50)	,
								SAPartDesc			nvarchar(255)	,
								BedSize				nvarchar(50)	,
								[Width]				real			,
								[Length]			real			,
								ItemClass			nvarchar(50)	,
								ProductType			nvarchar(50)	,
								CoreType			nvarchar(50)	,	
								BorderType			nvarchar(50)	,
								PanelType			nvarchar(50)	,
								PanelType2			nvarchar(50)	,
								QuiltNeedleSetting	nvarchar(50)	,
								QuiltPatternCAM		nvarchar(50)	,
								QuiltTick			nvarchar(50)	,
								QuiltBacking		nvarchar(50)	,
								QuiltLayer1			nvarchar(50)	,
								QuiltLayer2			nvarchar(50)	,
								QuiltLayer3			nvarchar(50)	,
								QuiltLayer4			nvarchar(50)	,
								QuiltLayer5			nvarchar(50)	,
								QuiltLayer6			nvarchar(50)	,
								BorderTick			nvarchar(50)	,
								BorderRP			nvarchar(50)	,
								BorderRF			nvarchar(50)	,
								BorderBK			nvarchar(50)	,
								BorderWidth			float			,
								BorderNeedleBar		nvarchar(50)	,
								Borderpattern		nvarchar(50)	,
								BorderNletHeight	float			,
								BorderBDRGroup		nvarchar(50)	,
								ThreadLineColor		nvarchar(50)	,
								BorderLabel			nvarchar(50)	,
								BDType				nvarchar(50)	,
								BDSAPart			nvarchar(50)	,
								BorderStitch		nvarchar(50)	,
								BorderRibbon		nvarchar(50)	,
								BorderRibbonCord	nvarchar(50)	,
								NLET				nvarchar(50)	,
								ByPass				nvarchar(50)	,
								BorderHandle		nvarchar(50)	,
								BorderHandleStyle	nvarchar(50)	,
								BorderHandleWidth	float			,
								BorderHandleGroup	nvarchar(50)	,
								GussettSAPart		nvarchar(50)	,
								GussettGroup		nvarchar(50)	,
								GussettHeight		float			,	
								BorderWire			nvarchar(50)	,
								CoilSeries			nvarchar(50)	,
								CoilType			nvarchar(50)	,
								CoilQuantity		int				,
								CoilWireGage		float			,
								CoilsperRow			int				,
								TotalNoofRows		int				,
								FEC					bit				,
								NumberOfMULayers	int				,
								ActualLine			nvarchar(50)	,
								WaveGroup			nvarchar(50)	,
								BorderCord			nvarchar(50)	,
								UnitType			nchar(10)		,
								MattressSides		int				)

DECLARE	@tblCU AS Table	(	RowId				int	IDENTITY	,
							iOrderID			nvarchar(50)	,
							iEntryID			nvarchar(50)	,
							iSAPart				nvarchar(50)	,
							iSAPartDesc			nvarchar(255)	,
							iBorderWire			nvarchar(50)	,
							iCoilsperRow		int				,
							iTotalNoofRows		int				)

DECLARE @tblPOProperty as Table(	RowId			int IDENTITY	,
									OrderID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

DECLARE @tblSKUProperty as Table(	RowId			int IDENTITY	,
									SKU				nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

DECLARE @tblEntryProperty as Table(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

DECLARE @tblEntryBOM as Table	(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									ItemClass		nvarchar(255)	,
									PartNo			nvarchar(50)	,
									[UID]			nvarchar(50)	)

DECLARE @tblSABOM as Table	(	RowId			int IDENTITY	,
								SAPartNo		nvarchar(50))

DECLARE	@tblMCCHData AS Table	(	RowId				int	IDENTITY	,
								PID					int				,
								OrderID				nvarchar(50)	,
								ProcessType			nvarchar(50)	,
								PlantNo				nvarchar(50)	,
								EntryID				nvarchar(50)	,
								FGPart				nvarchar(50)	,
								FGPartDesc			nvarchar(255)	,
								Qty					int				,
								SAPart				nvarchar(50)	,
								SAPartDesc			nvarchar(255)	,
								BedSize				nvarchar(50)	,
								ItemClass			nvarchar(50)	,
								BorderTick			nvarchar(50)	,
								BorderRP			nvarchar(50)	,
								BorderRF			nvarchar(50)	,
								BorderBK			nvarchar(50)	,
								BorderWidth			float			,
								BorderNeedleBar		nvarchar(50)	,
								Borderpattern		nvarchar(50)	,
								BorderNletHeight	float			,
								BorderBDRGroup		nvarchar(50)	,
								ThreadLineColor		nvarchar(50)	,
								BorderLabel			nvarchar(50)	,
								BDType				nvarchar(50)	,
								BDSAPart			nvarchar(50)	,
								BorderStitch		nvarchar(50)	,
								BorderRibbon		nvarchar(50)	,
								BorderRibbonCord	nvarchar(50)	,
								NLET				nvarchar(50)	,
								ByPass				nvarchar(50)	,
								BorderHandle		nvarchar(50)	,
								BorderHandleStyle	nvarchar(50)	,
								BorderHandleWidth	float			,
								BorderHandleGroup	nvarchar(50)	)

DECLARE @StartRow	int				,
		@EndRow		int				,
		@ItemCount	int				,
		@EntryID	nvarchar(50)	,
		@LastEntry	nvarchar(50)	,
		@PoStatusID int

BEGIN	/* Get Order and Entries */
	INSERT INTO @tblOrders (PID,OrderID,ProcessType,PlantNo,EntryID,CustomerNo,FGPart,[Quantity])
		SELECT  CASE Pe.[pom_entry_id]
					WHEN Po.[pom_order_id] THEN '1'
					WHEN (Po.[pom_order_id] + '.PanelQuilt1') THEN '2'
					WHEN (Po.[pom_order_id] + '.PanelQuilt2') THEN '2'
					WHEN (Po.[pom_order_id] + '.MCCHL1') THEN '3'
					WHEN (Po.[pom_order_id] + '.THC1') THEN '4'
					WHEN (Po.[pom_order_id] + '.THC2') THEN '4'
					WHEN (Po.[pom_order_id] + '.BHC1') THEN '5'
					WHEN (Po.[pom_order_id] + '.BHC2') THEN '5'
					WHEN (Po.[pom_order_id] + '.CU1') THEN '6'
					WHEN (Po.[pom_order_id] + '.SBCoil1') THEN '7'
					WHEN (Po.[pom_order_id] + '.SBCoil2') THEN '7'
					WHEN (Po.[pom_order_id] + '.SBCoil3') THEN '7'
					WHEN (Po.[pom_order_id] + '.SBCoil4') THEN '7'
				END
			  ,Po.[pom_order_id]
			  ,CASE Pe.[pom_entry_id]
					WHEN Po.[pom_order_id] THEN 'Line'
					WHEN (Po.[pom_order_id] + '.PanelQuilt1') THEN 'Quilter'
					WHEN (Po.[pom_order_id] + '.PanelQuilt2') THEN 'Quilter'
					WHEN (Po.[pom_order_id] + '.MCCHL1') THEN 'MCCH'
					WHEN (Po.[pom_order_id] + '.THC1') THEN 'THC'
					WHEN (Po.[pom_order_id] + '.THC2') THEN 'THC'
					WHEN (Po.[pom_order_id] + '.BHC1') THEN 'BHC'
					WHEN (Po.[pom_order_id] + '.BHC2') THEN 'BHC'
					WHEN (Po.[pom_order_id] + '.CU1') THEN 'CU'
					WHEN (Po.[pom_order_id] + '.SBCoil1') THEN 'Coiler'
					WHEN (Po.[pom_order_id] + '.SBCoil2') THEN 'Coiler'
					WHEN (Po.[pom_order_id] + '.SBCoil3') THEN 'Coiler'
					WHEN (Po.[pom_order_id] + '.SBCoil4') THEN 'Coiler'
				END
			  ,REPLACE(Po.[plant_name],'.PLN','')
			  ,Pe.[pom_entry_id]
			  ,Po.[pom_customer_order]
			  ,REPLACE(Po.[ppr_name],'PPR_','')
			  ,Pe.initial_qty
		  FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
			INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] PeS On PeS.pom_entry_status_pk=Pe.pom_entry_status_pk
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po	ON	Po.pom_order_pk=Pe.pom_order_pk
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.pom_order_status_pk=Po.pom_order_status_pk
		  WHERE PeS.id IN('Scheduled','Initial','Download')
			AND PoS.id in('Download','Initial','Scheduled')
			AND (Pe.pom_entry_id=Po.pom_order_id
					OR  Pe.pom_entry_id  like'%.BHC1'
					OR  Pe.pom_entry_id  like'%.BHC2'
					OR  Pe.pom_entry_id  like'%.THC1'
					OR  Pe.pom_entry_id  like'%.THC2'
					OR  Pe.pom_entry_id  like'%.MCCHL1'
					OR  Pe.pom_entry_id  like'%.PanelQuilt1'
					OR  Pe.pom_entry_id  like'%.PanelQuilt2'
					OR  Pe.pom_entry_id  like'%.CU1'
					OR  Pe.pom_entry_id  like'%.SBCoil1'
					OR  Pe.pom_entry_id  like'%.SBCoil2'
					OR  Pe.pom_entry_id  like'%.SBCoil3'
					OR  Pe.pom_entry_id  like'%.SBCoil4')
	UPDATE @tblOrders
		SET EntryID='NULL'		,
			SAPart='NULL'		,	
			SAPartDesc='NULL'
		WHERE ProcessType='Line'
END
BEGIN	/* Get Order Properties & Update Entry Properties */
	INSERT INTO @tblPOProperty (OrderID,PropertyID,PropValue)
		SELECT	POprop.[pom_order_id]						,
				CONVERT(nvarchar(255),DM.[APSProperty])		,
				CONVERT(nvarchar(50),POprop.[pom_cf_value])
		  FROM [SitMesDB].[dbo].[POMV_ORDR_PRP_VAL] POprop
			INNER JOIN  [SitMesDB].[dbo].[POMV_PRP_GRP_CFG] PropCfg ON PropCfg.pom_custom_fld_name=POprop.[pom_custom_fld_name]
			INNER JOIN  [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=POprop.[pom_custom_fld_name]
			INNER JOIN @tblOrders PO on PO.OrderID=POprop.pom_order_id
		  WHERE DM.[DataFlow]='MES2Preactor'
			AND DM.[catagory]='Order'
	UPDATE @tblOrders							/* TruckID  */
			SET	TruckID = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='TruckID'
	UPDATE @tblOrders							/* StopID  */
			SET	StopID = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='StopID'
	UPDATE @tblOrders							/* CustomerName  */
			SET	CustomerName = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='CustomerName'
	UPDATE @tblOrders							/* CustomerOrderNo  */
			SET	CustomerOrderNo = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='CustomerOrderNo'
	UPDATE @tblOrders							/* CustomerOrderLineNo  */
			SET	CustomerOrderLineNo = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='CustomerOrderLineNo'
	UPDATE @tblOrders							/* DueDate  */
			SET	DueDate = Convert(date,Prop.PropValue,103) 
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='DueDate'
	UPDATE @tblOrders							/* DueTime  */
			SET	DueTime = Convert(time(7),Prop.PropValue)	
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='DueTime'
	UPDATE @tblOrders							/* ActualLine  */
			SET	ActualLine = Prop.PropValue
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='ActualLine'
	UPDATE @tblOrders							/* WaveGroup */
			SET	WaveGroup = Prop.PropValue	
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='WaveGroup'
	UPDATE @tblOrders							/* UnitType  */
			SET	UnitType = Prop.PropValue
			FROM @tblPOProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='UnitType'
END
BEGIN	/* Update SKU properties */
	UPDATE @tblOrders							/* SKU Description  */
			SET	FGPartDesc = [Descript]		
			FROM @tblOrders AS Po
				INNER JOIN  [SitMesDB].[dbo].[MMDefinitions] MM on  MM.DefID= Po.FGPart
	INSERT INTO @tblSKUProperty (SKU,PropertyID	,PropValue)
		SELECT	Po.FGPart		,
				CONVERT(nvarchar(255),DM.[APSProperty])	,
				CONVERT(nvarchar(50),SKU.[PValue])		
		  FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] SKU
			INNER JOIN @tblOrders Po ON Po.FGPart=SKU.[DefID]
			INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=SKU.[PropertyID]
		  WHERE DM.[DataFlow]='MES2Preactor'
					AND DM.[catagory]='SKU'
	UPDATE @tblOrders							/* ProductType  */
			SET	ProductType = Prop.PropValue		
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='ProductType '	
	UPDATE @tblOrders							/* BorderType  */
			SET	BorderType = Prop.PropValue		
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='BorderType'
	UPDATE @tblOrders							/* BedSize */
			SET	BedSize = Prop.PropValue		
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='BedSize'	
	UPDATE @tblOrders							/* Length */
		SET	[Length] = CONVERT(real,Prop.PropValue)		
		FROM @tblSKUProperty AS Prop
			INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			WHERE PropertyID='Length'
	UPDATE @tblOrders							/* Width */
			SET	[Width] = CONVERT(real,Prop.PropValue	)	
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='Width'
	UPDATE @tblOrders							/* NumberOfMULayers */
			SET	NumberOfMULayers =  CONVERT(int,Prop.PropValue	)	
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='NumberOfMULayers'
	UPDATE @tblOrders							/* CoreType  */
			SET	CoreType = CASE Prop.PropValue	
								WHEN '1' THEN 'Make'
								WHEN '0' THEN 'Buy'	
							END
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='CoreType'
	UPDATE @tblOrders							/* PanelType   */
			SET	[PanelType] = CASE Prop.PropValue	
									WHEN 'Q'	THEN 'Quilt'
									WHEN 'NQ'	THEN 'nonQuilt'	
									ELSE Prop.PropValue	
							  END
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='PanelType'
	UPDATE @tblOrders							/* PanelType2  */
			SET	[PanelType2] = CASE Prop.PropValue	
									WHEN 'Q'	THEN 'Quilt'
									WHEN 'NQ'	THEN 'nonQuilt'	
									ELSE Prop.PropValue	
							  END		
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='PanelType2'
	UPDATE @tblOrders							/* FEC  */
			SET	FEC = CASE Prop.PropValue	
							WHEN 'FEC'	THEN '1'
							WHEN 'non-FEC'	THEN '0'
							WHEN 'nonFEC'	THEN '0'		
							ELSE Prop.PropValue	
						END		
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='FEC'
	
	UPDATE @tblOrders							/* MattressSides  */
			SET	MattressSides = Prop.PropValue	
			FROM @tblSKUProperty AS Prop
				INNER JOIN @tblOrders AS Po on  Po.FGPart	=Prop.SKU
			 WHERE PropertyID='MattressSides'
END
UPDATE @tblOrders
	SET SAPart		=	ml.def_id		,
		ItemClass	=	ml.class		, 
		SAPartDesc	=	Mdef.[Descript]	,
		[Quantity]			=	ml.quantity
	FROM [SitMesDB].dbo.POM_ENTRY e
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MDef ON MDef.DefID=ml.def_id
		INNER JOIN @tblOrders Po ON Po.EntryID	=e.pom_entry_id
	WHERE ms.name='PRODUCED'
BEGIN	/* Panel Quilter */
	INSERT INTO @tblEntryProperty(EntryID,PropertyID,PropValue)
		SELECT	Po.EntryID,
				CONVERT(nvarchar(50),DM.[APSProperty]),
				CONVERT(nvarchar(50),EntryProp.[pom_cf_value])
		FROM [SitMesDB].[dbo].[POMV_ETRY_PRP_VAL] EntryProp
			INNER JOIN @tblOrders Po ON Po.EntryID=EntryProp.[pom_entry_id]
			INNER JOIN  [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=Entryprop.[pom_custom_fld_name]
		WHERE DM.[DataFlow]='MES2Preactor'
				AND DM.[catagory]='Quilt'
				AND  Po.ProcessType='Quilter'
	UPDATE @tblOrders							/* QuiltNeedleSetting  */
		SET	QuiltNeedleSetting = Prop.PropValue		
		FROM @tblEntryProperty  AS Prop
			INNER JOIN @tblOrders AS Po on  Po.EntryID	=Prop.EntryID
		WHERE PropertyID='QuiltNeedleSetting'		
	UPDATE @tblOrders							/* QuiltPatternCAM  */
		SET	QuiltPatternCAM = Prop.PropValue		
		FROM @tblEntryProperty  AS Prop
			INNER JOIN @tblOrders AS Po on  Po.EntryID	=Prop.EntryID
		WHERE PropertyID='QuiltPatternCAM'	
	UPDATE @tblOrders							/* QuiltTick  */
		SET	QuiltTick = ml.def_id
		FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
			INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
			INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
			INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
			INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
			INNER JOIN @tblOrders Po ON  Po.EntryID=e.pom_entry_id
		WHERE ms.name='CONSUMED'
			AND ml.class='RMTK'		
			AND Po.ProcessType	='Quilter'	
	UPDATE @tblOrders							/* QuiltBacking */
		SET	QuiltBacking =  ml.def_id
		FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
			INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
			INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
			INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
			INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
			INNER JOIN @tblOrders Po ON Po.EntryID=e.pom_entry_id
		WHERE ms.name='CONSUMED'
			AND ml.class='RMBK'		
			AND Po.ProcessType	='Quilter'
	BEGIN										/* Update Fill Layer Information */
		INSERT INTO @tblSABOM (SAPartNo)
			SELECT DISTINCT(SAPart)
				FROM @tblOrders
				WHERE ProcessType='Quilter'			
		SELECT @StartRow=min(RowID),
			   @EndRow=max(RowID)
		FROM @tblSABOM 
		WHILE @StartRow<=@EndRow
			BEGIN
				SELECT @EntryID=SAPartNo
				FROM @tblSABOM
				WHERE RowID=@StartRow	
				INSERT INTO @tblEntryBOM (EntryID,ItemClass,PartNo)
					SELECT @EntryID,MBOMItems.AltGroupID,MBOMItems.ItemAltName
					FROM [SitMesDB].[dbo].[MMDefinitions] MDef
						INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
						INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
						INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
					WHERE MDef.DefID=@EntryID 
						AND MBOMItems.AltGroupID<>'RMTK'
						AND MBOMItems.AltGroupID<>'RMBK'
					ORDER BY MBOMItems.BomItemAltPK ASC
				SELECT @StartRow=@StartRow +1
			END
		SELECT @StartRow=min(RowID),
			   @EndRow=max(RowID)
		FROM @tblEntryBOM
		WHILE @StartRow<=@EndRow
			BEGIN
				SELECT @EntryID=EntryID
				FROM @tblEntryBOM
				WHERE RowID=@StartRow
				IF @EntryID=@LastEntry
					BEGIN
						SELECT @ItemCount=@ItemCount+1
						UPDATE @tblEntryBOM
							SET [UID]='QuiltLayer' + CONVERT(nvarchar(3),@ItemCount)
							WHERE RowID=@StartRow
					END
				ELSE
					BEGIN
						SELECT @ItemCount=1
						UPDATE @tblEntryBOM
							SET [UID]='QuiltLayer' + CONVERT(nvarchar(3),@ItemCount)
							WHERE RowID=@StartRow
						SELECT @LastEntry=@EntryID
					END
				SELECT @StartRow=@StartRow+1
			END			
		UPDATE @tblOrders							/* QuiltLayer1  */
			SET	QuiltLayer1	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.SAPart	=BOM.EntryID
		WHERE BOM.UID='QuiltLayer1'	
		UPDATE @tblOrders							/* QuiltLayer2  */
			SET	QuiltLayer2	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.SAPart	=BOM.EntryID
		WHERE BOM.UID='QuiltLayer2'		
		UPDATE @tblOrders							/* QuiltLayer3  */
			SET	QuiltLayer3	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.SAPart	=BOM.EntryID
		WHERE BOM.UID='QuiltLayer3'	
		UPDATE @tblOrders							/* QuiltLayer4  */
			SET	QuiltLayer4	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.SAPart	=BOM.EntryID
		WHERE BOM.UID='QuiltLayer4'		
		UPDATE @tblOrders							/* QuiltLayer5  */
			SET	QuiltLayer5	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.SAPart	=BOM.EntryID
		WHERE BOM.UID='QuiltLayer5'	
		UPDATE @tblOrders							/* QuiltLayer6  */
			SET	QuiltLayer6	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.SAPart	=BOM.EntryID
		WHERE BOM.UID='QuiltLayer6'		
	END

END 
BEGIN	/* Border Decoration*/
	DELETE FROM @tblEntryProperty
	DELETE FROM @tblEntryBOM
	DELETE FROM @tblSABOM	
	BEGIN   /* Border Roll */
		INSERT INTO @tblSABOM(SAPartNo)
			SELECT DISTINCT(OrderID)
			FROM @tblOrders	
		INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo)
			SELECT Po.SAPartNo,ml.class, ml.def_id
			FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
				INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
				INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=o.pom_order_id
			WHERE ms.name='CONSUMED'
				AND e.pom_entry_id=Po.SAPartNo + '.BorderDecRoll1'
		UPDATE @tblOrders							/* BorderTick */
			SET	BorderTick	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='RMTK'
				AND Po.ProcessType='MCCH'	
		UPDATE @tblOrders							/* BorderBacking */
			SET	BorderBK	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='RMBK'
				AND Po.ProcessType='MCCH'			
		UPDATE @tblOrders							/* Border Roll Fiber */
			SET	BorderRF	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='RMRF'
				AND Po.ProcessType='MCCH'			
		UPDATE @tblOrders							/* Border Roll Poly */
			SET	BorderRP	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='RMRP'
				AND Po.ProcessType='MCCH'	
		
		INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
			SELECT	Po.SAPartNo		,
					DM.[APSProperty]	,
					CONVERT(nvarchar(50),Prop.[pom_cf_value])
			FROM [SitMesDB].[dbo].[POMV_ETRY_PRP_VAL] Prop
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=Prop.pom_order_id
				INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=Prop.[pom_custom_fld_name]	
			WHERE Prop.[pom_entry_id]=Po.SAPartNo + '.BorderDecRoll1'
				AND DM.[DataFlow]='MES2Preactor'
				AND DM.[Catagory]='BorderRoll'
		UPDATE @tblOrders							/* BorderNeedleBar	  */
			SET	BorderNeedleBar = Prop.PropValue	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='BorderNeedleBar'	
			AND Po.ProcessType='MCCH'	
		UPDATE @tblOrders							/* Borderpattern	  */
			SET	Borderpattern = Prop.PropValue	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='Borderpattern'	
			AND Po.ProcessType='MCCH'
		UPDATE @tblOrders							/* BorderBDRGroup	  */
			SET	BorderBDRGroup = Prop.PropValue	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='BorderBDRGroup'	
			AND Po.ProcessType='MCCH'
		UPDATE @tblOrders							/* BorderNletHeight  */
			SET	BorderNletHeight = CONVERT(float,Prop.PropValue)	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='BorderNletHeight'	
			AND Po.ProcessType='MCCH'		
		UPDATE @tblOrders							/* BorderWidth  */
			SET	BorderWidth = CONVERT(float,Prop.PropValue)	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='BorderWidth'	
			AND Po.ProcessType='MCCH'	
	END
	BEGIN	/* MCCH */
		DELETE FROM @tblEntryBOM
		INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo)
			SELECT Po.SAPartNo,ml.class, ml.def_id
			FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
				INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
				INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=o.pom_order_id
			WHERE ms.name='CONSUMED'
				AND e.pom_entry_id=Po.SAPartNo + '.MCCHL1'
				AND ml.class IN ('RMLB','SAHNAY','SABROY','SABRCY','SABRSY','SABNLY','SABBPY')				
		UPDATE @tblOrders							/* BorderLabel */
			SET	BorderLabel	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='RMLB'
				AND Po.ProcessType='MCCH'
		UPDATE @tblOrders							/*BorderHandle */
			SET	BorderHandle = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='SAHNAY'
				AND Po.ProcessType='MCCH'
		UPDATE @tblOrders							/* BDSAPart */
			SET	BDSAPart	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass IN  ('SABROY','SABRCY','SABRSY','SABNLY','SABBPY')
				AND Po.ProcessType='MCCH'
		UPDATE @tblOrders							/* BDType */
			SET	BDType	 = CASE (BOM.ItemClass	)
								WHEN 'SABROY' THEN 'Ribbon'	
								WHEN 'SABRCY' THEN 'RibbonCord'
								WHEN 'SABRSY' THEN 'RibbonDecStitch'
								WHEN 'SABNLY' THEN 'Nlet'
								WHEN 'SABBPY' THEN 'ByPass'
							END
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass IN  ('SABROY','SABRCY','SABRSY','SABNLY','SABBPY')
				AND Po.ProcessType='MCCH'
		UPDATE @tblOrders							/* BorderCord */
			SET	BorderCord	 = CASE (BOM.ItemClass	)
								WHEN 'SABROY' THEN 'Ribbon'	
								WHEN 'SABRCY' THEN 'RibbonCord'
								WHEN 'SABRSY' THEN 'RibbonDecStitch'
								WHEN 'SABNLY' THEN 'Nlet'
								WHEN 'SABBPY' THEN 'ByPass'
							END
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass IN  ('SABROY','SABRCY','SABRSY','SABNLY','SABBPY')
				AND Po.ProcessType='MCCH'
		
		UPDATE @tblOrders							/* BorderRibbon */
			SET	BorderRibbon	 = BOM.PartNo
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='SABROY'
				AND Po.ProcessType='MCCH'							
		UPDATE @tblOrders							/* BorderStitch */
			SET	BorderStitch	 = BOM.PartNo
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='SABRSY'
				AND Po.ProcessType='MCCH'	
		UPDATE @tblOrders							/* BorderRibbonCord */
			SET	BorderRibbonCord	 = BOM.PartNo
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='SABRCY'
				AND Po.ProcessType='MCCH'
		UPDATE @tblOrders							/* NLET */
			SET	NLET	 = BOM.PartNo
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='SABNLY'
				AND Po.ProcessType='MCCH'	
		UPDATE @tblOrders							/* ByPass */
			SET	ByPass	 = BOM.PartNo
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='SABBPY'
				AND Po.ProcessType='MCCH'
	END
	BEGIN	/* Ribbon */
		DELETE FROM @tblEntryBOM
		INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo)
			SELECT Po.SAPartNo,ml.class, ml.def_id
			FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
				INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
				INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=o.pom_order_id
			WHERE ms.name='CONSUMED'
				AND e.pom_entry_id=Po.SAPartNo + '.Ribbon1'
				AND ml.class IN ('RMTP')							
		UPDATE @tblOrders							/* ThreadLineColor */
			SET	ThreadLineColor	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE BOM.ItemClass='RMTP'
				AND Po.ProcessType='MCCH'
	END
	BEGIN	/* Handle */
		DELETE FROM @tblEntryProperty
		DELETE FROM @tblEntryBOM
		DELETE FROM @tblSABOM
		INSERT INTO @tblSABOM(SAPartNo)
			SELECT DISTINCT(OrderID)
			FROM @tblOrders	
			WHERE BorderHandle<>'NULL'
		INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
			SELECT	Po.SAPartNo		,
					DM.[APSProperty]	,
					CONVERT(nvarchar(50),Prop.[pom_cf_value])
			FROM [SitMesDB].[dbo].[POMV_ETRY_PRP_VAL] Prop
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=Prop.pom_order_id
				INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=Prop.[pom_custom_fld_name]	
			WHERE Prop.[pom_entry_id]=Po.SAPartNo + '.Handle1'
				AND DM.[DataFlow]='MES2Preactor'
				AND DM.[Catagory]='Handle'		
		UPDATE @tblOrders							/* BorderHandleStyle   */
			SET	BorderHandleStyle = Prop.PropValue	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='BorderHandleStyle'	
			AND Po.ProcessType='MCCH'	
		UPDATE @tblOrders							/* BorderHandleWidth	  */
			SET	BorderHandleWidth = CONVERT(float,Prop.PropValue)	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='BorderHandleWidth'	
			AND Po.ProcessType='MCCH'
		
		
		INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
			SELECT	Po.SAPartNo		,
					DM.[APSProperty]	,
					CONVERT(nvarchar(50),Prop.[pom_cf_value])
			FROM [SitMesDB].[dbo].[POMV_ETRY_PRP_VAL] Prop
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=Prop.pom_order_id
				INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=Prop.[pom_custom_fld_name]	
			WHERE Prop.[pom_entry_id]=Po.SAPartNo + '.HandleRoll1'
				AND DM.[DataFlow]='MES2Preactor'
				AND DM.[Catagory]='HandleRoll'
		UPDATE @tblOrders							/* BorderHandleGroup	  */
			SET	BorderHandleGroup = Prop.PropValue	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='BorderHandleGroup'	
			AND Po.ProcessType='MCCH'
	END
	BEGIN	/* Gussett */
		DELETE FROM @tblEntryProperty
		DELETE FROM @tblEntryBOM
		DELETE FROM @tblSABOM
	END
END
BEGIN	/* Coil */
	DELETE FROM @tblEntryProperty
	DELETE FROM @tblEntryBOM
	DELETE FROM @tblSABOM
	BEGIN  /* Purchased Coil Assembly */
		INSERT INTO @tblSABOM(SAPartNo)
			SELECT DISTINCT(OrderID)
			FROM @tblOrders
			WHERE ProcessType='CU'		
		INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo)
			SELECT Po.SAPartNo,ml.class, ml.def_id
			FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
				INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
				INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=o.pom_order_id
			WHERE ms.name='CONSUMED'
				AND e.pom_entry_id like '%.PurchaseCoilAssem1'
				AND ml.class='SAMCAY'			
		UPDATE @tblOrders							/* BorderWire	  */
			SET	BorderWire	 = BOM.PartNo		
			FROM @tblEntryBOM  AS BOM
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=BOM.EntryID
			WHERE Po.ProcessType='CU'		
	END
	BEGIN	/* CU */
		INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
			SELECT	Po.SAPartNo		,
					DM.[APSProperty]	,
					CONVERT(nvarchar(50),Prop.[pom_cf_value])
			FROM [SitMesDB].[dbo].[POMV_ETRY_PRP_VAL] Prop
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=Prop.pom_order_id
				INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=Prop.[pom_custom_fld_name]	
			WHERE Prop.[pom_entry_id]=Po.SAPartNo + '.CU1'
				AND DM.[DataFlow]='MES2Preactor'
				AND DM.[Catagory]='CU'
		UPDATE @tblOrders							/* CoilsperRow	  */
			SET	CoilsperRow = CONVERT(int,CONVERT(NUMERIC,Prop.PropValue))	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='CoilsperRow'	
			AND Po.ProcessType='CU'	
		UPDATE @tblOrders							/* TotalNoofRows	  */
			SET	TotalNoofRows = CONVERT(int,CONVERT(NUMERIC,Prop.PropValue))
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.OrderID	=Prop.EntryID
			WHERE Prop.PropertyID='TotalNoofRows'	
			AND Po.ProcessType='CU'	
	END
	BEGIN	/* Coil */
		DELETE FROM @tblEntryProperty
		DELETE FROM @tblSABOM
		INSERT INTO @tblSABOM(SAPartNo)
			SELECT DISTINCT(EntryID)
			FROM @tblOrders
			WHERE ProcessType='Coil'
		INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
			SELECT	Po.SAPartNo 		,
					DM.[APSProperty]	,
					CONVERT(nvarchar(50),Prop.[pom_cf_value])
			FROM [SitMesDB].[dbo].[POMV_ETRY_PRP_VAL] Prop
				INNER JOIN @tblSABOM Po ON Po.SAPartNo=Prop.Pom_entry_id	
				INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=Prop.[pom_custom_fld_name]	
			WHERE DM.[DataFlow]='MES2Preactor'
				AND DM.[Catagory]='Coil'
		UPDATE @tblOrders							/* CoilWireGage	  */
			SET	CoilWireGage = CONVERT(float,CONVERT(NUMERIC,Prop.PropValue))	
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.EntryID	=Prop.EntryID
			WHERE Prop.PropertyID='CoilWireGage'	
			AND Po.ProcessType='Coil'	
		UPDATE @tblOrders							/* CoilSeries	  */
			SET	CoilSeries = Prop.PropValue
			FROM @tblEntryProperty  AS Prop
				INNER JOIN @tblOrders AS Po on  Po.EntryID	=Prop.EntryID
			WHERE Prop.PropertyID='CoilSeries'	
			AND Po.ProcessType='Coil'	
		UPDATE @tblOrders							/* CoilQuantity	  */
			SET CoilQuantity= ml.quantity
			FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
				INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
				INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
				INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
				INNER JOIN @tblOrders Po ON Po.EntryID=e.pom_entry_id
			WHERE ms.name='PRODUCED'
				AND Po.ProcessType='Coil'
		INSERT INTO @tblCU (iOrderID,iEntryID,iSAPart,iSAPartDesc,iBorderWire,iCoilsperRow,iTotalNoofRows)	/* Logic May Change in Future	  */
			SELECT	OrderID			,
					EntryID			,
					SAPart			,
					SAPartDesc		,
					BorderWire		,
					CoilsperRow		,
					TotalNoofRows
			FROM @tblOrders	Po
			WHERE ProcessType='CU'	
		UPDATE @tblOrders							/* Logic May Change in Future	  */
			SET EntryID			=	iEntryID			,
				SAPart			=	iSAPart			,
				SAPartDesc		=	iSAPartDesc		,
				BorderWire		=	iBorderWire		,
				CoilsperRow		=	iCoilsperRow		,
				TotalNoofRows	=	iTotalNoofRows
			FROM @tblCU
			WHERE ProcessType='Coil'
	END
END	
BEGIN	/* THC/BHC */
	INSERT INTO @tblMCCHData(PID,OrderID,ProcessType,PlantNo,EntryID,FGPart,FGPartDesc,Qty,SAPart,SAPartDesc,
							BedSize,ItemClass,BorderTick,BorderRP,BorderRF,BorderBK,BorderWidth,BorderNeedleBar,
							Borderpattern,BorderNletHeight,BorderBDRGroup,ThreadLineColor,BorderLabel,
							BDType,BDSAPart,BorderStitch,BorderRibbon,BorderRibbonCord,NLET,
							ByPass,BorderHandle	,BorderHandleStyle,BorderHandleWidth,BorderHandleGroup	)
			SELECT PID,OrderID,ProcessType,PlantNo,EntryID,FGPart,FGPartDesc,[Quantity],SAPart,SAPartDesc,BedSize,
					ItemClass,BorderTick,BorderRP,BorderRF,BorderBK,BorderWidth,BorderNeedleBar,Borderpattern,BorderNletHeight	,
					BorderBDRGroup,ThreadLineColor,BorderLabel,BDType,BDSAPart,BorderStitch,BorderRibbon,BorderRibbonCord,NLET,ByPass,
					BorderHandle,BorderHandleStyle,BorderHandleWidth,BorderHandleGroup	
			FROM @tblOrders
			WHERE ProcessType='MCCH'
	DELETE FROM @tblEntryBOM
	INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo,[UID])
		SELECT e.pom_entry_id,  ml.class,ml.def_id,o.Pom_order_id
		FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
			INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
			INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
			INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
			INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
			INNER JOIN @tblOrders Po ON Po.EntryID= e.pom_entry_id
		  WHERE (Po.ProcessType='THC' 
					OR Po.ProcessType='BHC')
				AND ms.name='CONSUMED'
				AND ml.class='SAFBAY'
	UPDATE @tblOrders
		SET Po.BorderTick=	MCCH.BorderTick,
			Po.BorderRP	=MCCH.BorderRP,
			Po.BorderRF=	MCCH.BorderRF,
			Po.BorderBK=MCCH.BorderBK,
			Po.BorderWidth=MCCH.BorderWidth,
			Po.BorderNeedleBar=MCCH.BorderNeedleBar,
			Po.Borderpattern=MCCH.Borderpattern,
			Po.BorderNletHeight=MCCH.BorderNletHeight	,
			Po.BorderBDRGroup=MCCH.BorderBDRGroup,
			Po.ThreadLineColor=MCCH.ThreadLineColor,
			Po.BorderLabel=MCCH.BorderLabel,
			Po.BDType=MCCH.BDType,
			Po.BDSAPart=MCCH.BDSAPart,
			Po.BorderStitch=MCCH.BorderStitch,
			Po.BorderRibbon=MCCH.BorderRibbon,
			Po.BorderRibbonCord=MCCH.BorderRibbonCord,
			Po.NLET=MCCH.NLET,
			Po.ByPass=MCCH.ByPass,
			Po.BorderHandle=MCCH.BorderHandle,
			Po.BorderHandleStyle=MCCH.BorderHandleStyle,
			Po.BorderHandleWidth=MCCH.BorderHandleWidth,
			Po.BorderHandleGroup=MCCH.BorderHandleGroup	
		FROM @tblMCCHData MCCH
			INNER JOIN @tblEntryBOM EnB	on EnB.UID=MCCH.OrderID
			INNER JOIN @tblOrders Po ON Po.EntryID=EnB.EntryID
		WHERE EnB.PartNo=MCCH.SAPart
	UPDATE @tblOrders
		SET GussettSAPart =ml.def_id
		FROM   [SitMesDB].dbo.POM_CAMPAIGN AS c 
			INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk 
			INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
			INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
			INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
			INNER JOIN @tblOrders Po ON Po.EntryID=e.pom_entry_id
		  WHERE (Po.ProcessType='THC' 
					OR Po.ProcessType='BHC')
				AND ( ml.class='SAGS2Y'
					OR ml.class='SAGSAY')
		  AND ms.name='CONSUMED'
END
BEGIN	/* Gussett */
	DELETE FROM @tblEntryBOM
	INSERT INTO @tblEntryBOM(EntryID,PartNo,[UID])
				SELECT EntryID,GussettSAPart,OrderID
				FROM @tblOrders
				WHERE 	GussettSAPart<>''
	
	DELETE FROM @tblEntryProperty
	INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
		SELECT	Po.EntryID	,
				DM.[APSProperty]	,
				CONVERT(nvarchar(50),Prop.[pom_cf_value])
		FROM [SitMesDB].[dbo].[POMV_ETRY_PRP_VAL] Prop
			INNER JOIN @tblEntryBOM Po ON Po.[UID]=Prop.pom_order_id
			INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=Prop.[pom_custom_fld_name]	
		WHERE Prop.[pom_entry_id] like Po.[UID] + '.Gussett%'
			AND DM.[DataFlow]='MES2Preactor'
			AND DM.[Catagory]='Gussett'
	UPDATE @tblOrders							/* GussettHeight */
		SET	GussettHeight = CONVERT(float,Prop.PropValue)	
		FROM @tblEntryProperty  AS Prop
			INNER JOIN @tblOrders AS Po on  Po.EntryID	=Prop.EntryID
		WHERE Prop.PropertyID='GussettHeight'	

	DELETE FROM @tblEntryProperty
	INSERT INTO @tblEntryProperty( EntryID	,PropertyID	,PropValue)
		SELECT	Po.EntryID	,
				DM.[APSProperty]	,
				CONVERT(nvarchar(50),Prop.[pom_cf_value])
		FROM [SitMesDB].[dbo].[POMV_ETRY_PRP_VAL] Prop
			INNER JOIN @tblEntryBOM Po ON Po.[UID]=Prop.pom_order_id
			INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=Prop.[pom_custom_fld_name]	
		WHERE Prop.[pom_entry_id] like Po.[UID] + '.GussettRoll%'
			AND DM.[DataFlow]='MES2Preactor'
			AND DM.[Catagory]='GussettRoll'
	UPDATE @tblOrders							/* GussettGroup */
		SET	GussettGroup = Prop.PropValue	
		FROM @tblEntryProperty  AS Prop
			INNER JOIN @tblOrders AS Po on  Po.EntryID	=Prop.EntryID
		WHERE Prop.PropertyID='GussettGroup'
END


SELECT @StartRow=Count(RowID)
FROM @tblOrders /* Update Order to Preactor and SitMesDB DB */
IF @StartRow>0
	BEGIN
		BEGIN	/* Update Preactor Interface Table */	
			DELETE FROM [SSB].[dbo].[SSB_MES2Preactor]
			INSERT INTO  [SSB].[dbo].[SSB_MES2Preactor]
				([OrderNo]
				  ,[ProcessType]
				  ,[PlantNo]
				  ,[EntryID]
				  ,[CustomerNo]
				  ,[CustomerName]
				  ,[CustomerOrderNo]
				  ,[CustomerOrderLineNo]
				  ,[TruckID]
				  ,[StopID]
				  ,[DueDate]
				  ,[DueTime]
				  ,[Quantity]
				  ,[FGPart]
				  ,[FGPartDesc]
				  ,[SAPart]
				  ,[SAPartDesc]
				  ,[BedSize]
				  ,[Width]
				  ,[Length]
				  ,[ItemClass]
				  ,[ProductType]
				  ,[CoreType]
				  ,[BorderType]
				  ,[PanelType]
				  ,[QuiltNeedleSetting]
				  ,[QuiltPatternCAM]
				  ,[QuiltTick]
				  ,[QuiltBacking]
				  ,[QuiltLayer1]
				  ,[QuiltLayer2]
				  ,[QuiltLayer3]
				  ,[QuiltLayer4]
				  ,[QuiltLayer5]
				  ,[QuiltLayer6]
				  ,[BorderTick]
				  ,[BorderRP]
				  ,[BorderRF]
				  ,[BorderBK]
				  ,[BorderWidth]
				  ,[BorderNeedleBar]
				  ,[Borderpattern]
				  ,[BorderNletHeight]
				  ,[BorderBDRGroup]
				  ,[ThreadLineColor]
				  ,[BorderLabel]
				  ,[BDType]
				  ,[BDSAPart]
				  ,[BorderStitch]
				  ,[BorderRibbon]
				  ,[BorderRibbonCord]
				  ,[NLET]
				  ,[ByPass]
				  ,[BorderHandle]
				  ,[BorderHandleStyle]
				  ,[BorderHandleWidth]
				  ,[BorderHandleGroup]
				  ,[GussettSAPart]
				  ,[GussettGroup]
				  ,[GussettHeight]
				  ,[BorderWire]
				  ,[CoilSeries]
				  ,[CoilType]
				  ,[CoilWireGage]
				  ,[CoilsperRow]
				  ,[CoilQuantity]
				  ,[TotalNoofRows]
				  ,[FEC]
				  ,[NumberOfMULayers]
				  ,[ActualLine]
				  ,[WaveGroup]
				  ,[UnitType]
				  ,[BorderCord]
				  ,[MattressSides])
			SELECT [OrderID]
				  ,[ProcessType]
				  ,[PlantNo]
				  ,[EntryID]
				  ,[CustomerNo]
				  ,[CustomerName]
				  ,[CustomerOrderNo]
				  ,[CustomerOrderLineNo]
				  ,[TruckID]
				  ,[StopID]
				  ,[DueDate]
				  ,[DueTime]
				  ,[Quantity]
				  ,[FGPart]
				  ,[FGPartDesc]
				  ,[SAPart]
				  ,[SAPartDesc]
				  ,[BedSize]
				  ,[Width]
				  ,[Length]
				  ,[ItemClass]
				  ,[ProductType]
				  ,[CoreType]
				  ,[BorderType]
				  ,[PanelType]
				  ,[QuiltNeedleSetting]
				  ,[QuiltPatternCAM]
				  ,[QuiltTick]
				  ,[QuiltBacking]
				  ,[QuiltLayer1]
				  ,[QuiltLayer2]
				  ,[QuiltLayer3]
				  ,[QuiltLayer4]
				  ,[QuiltLayer5]
				  ,[QuiltLayer6]
				  ,[BorderTick]
				  ,[BorderRP]
				  ,[BorderRF]
				  ,[BorderBK]
				  ,[BorderWidth]
				  ,[BorderNeedleBar]
				  ,[Borderpattern]
				  ,[BorderNletHeight]
				  ,[BorderBDRGroup]
				  ,[ThreadLineColor]
				  ,[BorderLabel]
				  ,[BDType]
				  ,[BDSAPart]
				  ,[BorderStitch]
				  ,[BorderRibbon]
				  ,[BorderRibbonCord]
				  ,[NLET]
				  ,[ByPass]
				  ,[BorderHandle]
				  ,[BorderHandleStyle]
				  ,[BorderHandleWidth]
				  ,[BorderHandleGroup]
				  ,[GussettSAPart]
				  ,[GussettGroup]
				  ,[GussettHeight]
				  ,[BorderWire]
				  ,[CoilSeries]
				  ,[CoilType]
				  ,[CoilWireGage]
				  ,[CoilsperRow]
				  ,[CoilQuantity]
				  ,[TotalNoofRows]
				  ,[FEC]
				  ,[NumberOfMULayers]
				  ,[ActualLine]
				  ,[WaveGroup]
				  ,[UnitType]
				  ,[BorderCord]
				  ,[MattressSides]
		  FROM @tblOrders
		END
		BEGIN	/* Update Order Status in SitMesDB */
			SELECT @PoStatusID= [pom_order_status_pk]
			FROM [SitMesDB].[dbo].[POM_ORDER_STATUS]
			  Where id='Scheduled'
			UPDATE [SitMesDB].[dbo].[POM_ORDER]
				SET [pom_order_status_pk]=@PoStatusID
				FROM  [SitMesDB].[dbo].[POM_ORDER_STATUS] Pos
					INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON Po.[pom_order_status_pk]=Pos.[pom_order_status_pk]
					INNER JOIN @tblOrders tblPo ON tblPo.OrderID=Po.Pom_order_Id
				WHERE tblPo.ProcessType='Line'
		END
	END
GO
