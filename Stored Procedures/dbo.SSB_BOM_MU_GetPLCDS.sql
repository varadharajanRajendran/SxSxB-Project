SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_BOM_MU_GetPLCDS]
		@OrderID nvarchar(255)	
AS
 


 

---------------------------------Declare Variables and Tables----------------------

DECLARE @PPRName			nvarchar(50)	,
        @PPRVer				nvarchar(10)	,
		@SelectedFoamType	nvarchar(10)	,
		@MUEntryID			nvarchar(10)	,
	    @POMMatSpecID		nvarchar(10)	,
		@intStartRow		int				,
        @intEndRow			int				,
        @intelProc			int				,
		@PartNo				nvarchar(100)	,
		@MUSubAssm			nvarchar(255)	,
		@OIrderID			nvarchar(255)	,	
		@ProcRow			int				,
		@SelParamVal		nvarchar(255)	,
		@SelParamDesc		nvarchar(255)	,
		@EntryID			nvarchar(255)	,
		@FECSAPartNo		nvarchar(255)	,
		@TopPick			nvarchar(255)	,
		@EntryCount			int				,	
		@selEntry			nvarchar(255)	,
		@CoreHeight			decimal (5,2)	,
		@GussettCount		int				,
		@MUEntryCount		int				,	
		@UnitSize			int				,
		@AdditionalCoreHeight decimal (5,2)	,
		@SelData			nvarchar(255)	


DECLARE	@tblPOMBOM AS Table	(	RowId		int	IDENTITY	,
								DefID		nvarchar(100)	,
								PickLight	nvarchar(10)	)

DECLARE	@tblBOMItems AS Table	(	RowId			int	IDENTITY	,
									PartNo			nvarchar(100)	)
																		
DECLARE	@tblProperty AS Table	(	RowId			int	IDENTITY	,
									PropertyName	nvarchar(100)	,
									PropertyValue	nvarchar(100)	)
									
DECLARE	@tblBFProperty AS Table	(	RowId			int	IDENTITY	,
									PropertyName	nvarchar(100)	,
									PropertyValue	nvarchar(100)	)

DECLARE	@tblTempProperty AS Table	(	RowId		int	IDENTITY	,
									PropertyName	nvarchar(100)	,
									PropertyValue	nvarchar(100)	)

DECLARE	@tblPLCDS AS Table	(	RowId		int	IDENTITY	,
								RTDSTag		nvarchar(100)	,
								Value		nvarchar(50)	,
								[DataType]	nvarchar(255)	)

SELECT @ProcRow=1

SELECT @GussettCount=COUNT(Pe.pom_entry_id)
FROM[SitMesDB].[dbo].[POM_ENTRY] Pe
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=Pe.pom_order_pk
WHERE Pe.pom_entry_id like '%Gussett%'
	AND Po.[pom_order_id]=@OrderID
			
SELECT @MUEntryCount=COUNT(Pe.pom_entry_id)
FROM [SitMesDB].[dbo].[POM_ENTRY] Pe 
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=pe.pom_order_pk
WHERE Po.pom_order_id=@orderID
	AND Pe.pom_entry_id like '%MU1%'


IF @MUEntryCount>0
	BEGIN			
		SELECT @EntryID=Pe.pom_entry_id
		FROM [SitMesDB].[dbo].[POM_ENTRY] Pe 
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=pe.pom_order_pk
		WHERE Po.pom_order_id=@orderID
			AND Pe.pom_entry_id like '%MU1%'

		SELECT @PPRName=ppr_name,
			   @PPRVer= ppr_version  
		FROM [SitMesDB].[dbo].[POM_ORDER] PO
		  WHERE PO.[pom_order_id]=@OrderID

		SELECT @PPRName=ppr_name,
			   @PPRVer= ppr_version  
		FROM [SitMesDB].[dbo].[POM_ORDER] PO
		  WHERE PO.[pom_order_id]=@OrderID
		  
		SELECT @EntryCount=COUNT(Pe.pom_entry_id)
		FROM[SitMesDB].[dbo].[POM_ENTRY] Pe
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=Pe.pom_order_pk
		WHERE Pe.pom_entry_id like '%PurchaseCoilAssem%'
			AND Po.[pom_order_id]=@OrderID
		
		IF @EntryCount>0
			BEGIN
				SELECT @selEntry=Pe.pom_entry_id
				FROM[SitMesDB].[dbo].[POM_ENTRY] Pe
					INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=Pe.pom_order_pk
				WHERE Pe.pom_entry_id like '%PurchaseCoilAssem%'
					AND Po.[pom_order_id]=@OrderID
		
				SELECT @PartNo=ML.def_id
				FROM [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS
					INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] PE on PE.[pom_entry_pk]=Ms.pom_entry_pk
					INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML on ML.pom_material_specification_pk=MS.pom_material_specification_pk
				WHERE MS.name='PRODUCED'
					AND PE.pom_entry_id like '%' + @selEntry + '%'		
				
				SELECT @UnitSize=RIGHT(@PartNo,2)

				SELECT @CoreHeight=CONVERT(nvarchar(255),[SitMesDB].[dbo].[MMfBinToPropVal](MMPV.[PropValue], 0) )
				FROM [SitMesDB].[dbo].[MMBoms] MMB
					INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD on MMB.DefPK=MMD.DefPK
					INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MMBA	on MMBa.BomPK=MMB.BomPK
					INNER JOIN [SitMesDB].[dbo].[MMBomAltPrpVals] MMPV on MMPV.BomAltPK=MMBA.BomAltPK
					INNER JOIN [SitMesDB].[dbo].[MMProperties] MMP on MMP.PropertyPK=MMPV.PropertyPK
				 WHERE MMD.DefID=@PartNo
					AND MMP.PropertyID='COILUNITHEIGHT'
				
				
				SELECT @AdditionalCoreHeight=ISNULL(Sum(CONVERT(Decimal(10,2),BIAPV.PValue)),0)
				FROM [SitMesDB].[dbo].[MMDefinitions] MDef
				  INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
				  INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
				  INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
				  INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD on MMD.DefID=MBOMItems.ItemAltName
				  INNER JOIN [SitMesDB].[dbo].[MMClasses] MMC on MMC.ClassPK=MMD.ClassPK
				  INNER JOIN [SitMesDB].[dbo].MMvBomItemAltPrpVals BIAPV on BIAPV.BomItemAltPK=MBOMItems.BomItemAltPK
				  INNER JOIN [SitMesDB].[dbo].MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BIAPV.PropertyPK AND (P.IsSpecial = 0 OR P.VisibleOnRT = 1) 
				  INNER JOIN [SitMesDB].[dbo].MMPrpGroups AS PG WITH (NOLOCK) ON PG.PrpGroupPK = P.PrpGroupPK 
				  INNER JOIN [SitMesDB].[dbo].MESUoMs AS UM WITH (NOLOCK) ON UM.UomPK = P.UoMPK 
				WHERE MDef.DefID=@PartNo
				   AND ( P.PropertyID='FOAMTOPPERHEIGHT')
				
				SELECT @CoreHeight=ISNULL(@CoreHeight,0) + ISNULL(@AdditionalCoreHeight,0)
			END
			
		SELECT @EntryCount=COUNT(Pe.pom_entry_id)
		FROM[SitMesDB].[dbo].[POM_ENTRY] Pe
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=Pe.pom_order_pk
		WHERE Pe.pom_entry_id like '%FEC%'
			AND Po.[pom_order_id]=@OrderID

		IF @EntryCount>0
			BEGIN
				SELECT @selEntry=Pe.pom_entry_id
				FROM[SitMesDB].[dbo].[POM_ENTRY] Pe
					INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=Pe.pom_order_pk
				WHERE Pe.pom_entry_id like '%FEC%'
					AND Po.[pom_order_id]=@OrderID
		
				SELECT @FECSAPartNo=ML.def_id
				FROM [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS
					INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] PE on PE.[pom_entry_pk]=Ms.pom_entry_pk
					INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML on ML.pom_material_specification_pk=MS.pom_material_specification_pk
				WHERE MS.name='PRODUCED'
					AND PE.pom_entry_id like '%' + @selEntry + '%'		
				
				
				SELECT @SelData=COUNT(MBOMItems.ItemAltName)
				FROM [SitMesDB].[dbo].[MMDefinitions] MDef
				  INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
				  INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
				  INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
				WHERE MDef.DefID=@FECSAPartNo  
					AND MBOMItems.AltGroupID='RMFT'
				
				
				IF @SelData>0
					BEGIN
						SELECT @PartNo=MBOMItems.ItemAltName
						FROM [SitMesDB].[dbo].[MMDefinitions] MDef
						  INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
						  INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
						  INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
						WHERE MDef.DefID=@FECSAPartNo  
							AND MBOMItems.AltGroupID='RMFT'
						
						SELECT @SelData=COUNT([PValue])
						FROM [SitMesDB].[dbo].[MMvdDefVerPrpVals]
						WHERE DefID=@PartNo
							AND ( PropertyID='HEIGHT'  
								  OR PropertyID='FOAMTOPPERHEIGHT')
						IF @SelData>0
							BEGIN
								SELECT @AdditionalCoreHeight=(  SELECT DISTINCT TOP(1)(CONVERT(Decimal(5,2),[PValue]))
																FROM [SitMesDB].[dbo].[MMvdDefVerPrpVals]
																WHERE DefID=@PartNo
																	AND (PropertyID='HEIGHT'  
																		OR PropertyID='FOAMTOPPERHEIGHT'))
								SELECT @CoreHeight=ISNULL(@CoreHeight,0) +ISNULL(@AdditionalCoreHeight,0)
							END
					END
				ELSE
					BEGIN
						SELECT @PartNo=MBOMItems.ItemAltName
						FROM [SitMesDB].[dbo].[MMDefinitions] MDef
						  INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
						  INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
						  INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
						WHERE MDef.DefID=@FECSAPartNo  
							AND MBOMItems.AltGroupID='SABSMY'
						
						SELECT  @AdditionalCoreHeight =SUM(CONVERT(decimal(5,2),BIAPV.PValue) )
						FROM [SitMesDB].[dbo].[MMDefinitions] MDef
						  INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
						  INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
						  INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
						  INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD on MMD.DefID=MBOMItems.ItemAltName
						  INNER JOIN [SitMesDB].[dbo].[MMClasses] MMC on MMC.ClassPK=MMD.ClassPK
						  INNER JOIN [SitMesDB].[dbo].MMvBomItemAltPrpVals BIAPV on BIAPV.BomItemAltPK=MBOMItems.BomItemAltPK
						  INNER JOIN [SitMesDB].[dbo].MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BIAPV.PropertyPK AND (P.IsSpecial = 0 OR P.VisibleOnRT = 1) 
						  INNER JOIN [SitMesDB].[dbo].MMPrpGroups AS PG WITH (NOLOCK) ON PG.PrpGroupPK = P.PrpGroupPK 
						  INNER JOIN [SitMesDB].[dbo].MESUoMs AS UM WITH (NOLOCK) ON UM.UomPK = P.UoMPK 
						WHERE MDef.DefID=@PartNo
							AND P.PropertyID='FOAMTOPPERHEIGHT'
		
						SELECT @CoreHeight= ISNULL(@CoreHeight,0) + ISNULL(@AdditionalCoreHeight,0)	
					END
				
			END
			
		INSERT INTO @tblProperty (PropertyName,PropertyValue)
		  SELECT NAME,VAL  FROM [SitMesDB].[dbo].[PDMT_PS_PRP] PRP
		  WHERE PPR=@PPRName 
			 AND PPR_VER=@PPRVer
			 AND PS='MU1'
		  ORDER BY seq ASC

		/* Product Properties*/
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('JOBID',@OrderID , 'String')

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'NOOFLAYERS',PropertyValue ,'Numeric'
			FROM @tblProperty
			WHERE PropertyName='PROD_NoofLayers'

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'LENGTH',PropertyValue ,'Numeric'
			FROM @tblProperty
			WHERE PropertyName='PROD_Length'

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'WIDTH',PropertyValue ,'Numeric'
			FROM @tblProperty
			WHERE PropertyName='PROD_Width'

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('CoreHeight',@CoreHeight ,'Numeric')

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('UnitSize',@UnitSize ,'Numeric')

	   	INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('ByPass','0' ,'Numeric')
		
		WHILE @ProcRow<=6
			BEGIN		
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT 'L' + CONVERT(nvarchar(255),@ProcRow) + 'THICKNESS',PropertyValue ,'Numeric'
					FROM @tblProperty
					WHERE PropertyName='PROD_L' +  CONVERT(nvarchar(255),@ProcRow) + 'Thickness'
						
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT 'L' + CONVERT(nvarchar(255),@ProcRow) + 'PATTERN',PropertyValue, 'Numeric'
					FROM @tblProperty
					WHERE PropertyName='PROD_L' +  CONVERT(nvarchar(255),@ProcRow) + 'GluePattern'
				
				/* Control Recipe */
				SELECT @SelectedFoamType=PropertyValue 
				FROM @tblProperty
				WHERE PropertyName='PROD_L' +  CONVERT(nvarchar(255),@ProcRow)+ 'FoamType'

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
						Values('L' +  CONVERT(nvarchar(255),@ProcRow) + 'Type',@SelectedFoamType ,'Numeric')
			/*
				IF @SelectedFoamType='43'
					BEGIN
						INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
						Values('L' +  CONVERT(nvarchar(255),@ProcRow) + 'Type','83' ,'Numeric')
					END
				ELSE IF @SelectedFoamType='83'
					BEGIN
						INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
						Values('L' +  CONVERT(nvarchar(255),@ProcRow) + 'Type','43' ,'Numeric')
					END
				ELSE
					BEGIN
						INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
						Values('L' +  CONVERT(nvarchar(255),@ProcRow) + 'Type',@SelectedFoamType ,'Numeric')
					END

				*/

				/*
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT 'L' +  CONVERT(nvarchar(255),@ProcRow) + 'Type',PropertyValue ,'Numeric'
					FROM @tblProperty
					WHERE PropertyName='PROD_L' +  CONVERT(nvarchar(255),@ProcRow) + 'FoamType'
				*/
				

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S1WidthFwd',[S1WidthFwd],'Numeric'
					FROM [SSB].[dbo].[SSB_MURecipe]
					WHERE [PK]=@SelectedFoamType

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S2WidthRev',[S2WidthRev],'Numeric'
					FROM [SSB].[dbo].[SSB_MURecipe]
					WHERE [PK]=@SelectedFoamType

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S3LengthFwd',[S3LengthFwd],'Numeric'
					FROM [SSB].[dbo].[SSB_MURecipe]
					WHERE [PK]=@SelectedFoamType

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S4LengthRev',[S4LengthRev],'Numeric'
					FROM [SSB].[dbo].[SSB_MURecipe]
					WHERE [PK]=@SelectedFoamType

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S5WidthFwd',[S5WidthFwd],'Numeric'
					FROM [SSB].[dbo].[SSB_MURecipe]
					WHERE [PK]=@SelectedFoamType

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'ClampPres',[ClampPres],'Numeric'
					FROM [SSB].[dbo].[SSB_MURecipe]
					WHERE [PK]=@SelectedFoamType

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					SELECT  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'BlowerPres',[BlowerPres],'Numeric'
					FROM [SSB].[dbo].[SSB_MURecipe]
					WHERE [PK]=@SelectedFoamType

				SELECT @ProcRow =@ProcRow +1
			END


		/* Line Side Storage */
		SELECT @MUEntryID=PE.[pom_entry_pk]
		  FROM [SitMesDB].[dbo].[POM_ENTRY]	PE
		  INNER JOIN [SitMesDB].[dbo].[POM_ORDER] PO ON PO.pom_order_pk=PE.pom_order_pk
		  WHERE PO.pom_order_id=@OrderID
			AND PE.ps_name='Mu1'

		SELECT @POMMatSpecID=[pom_material_specification_pk]
		FROM [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION]
		WHERE pom_entry_pk= @MUEntryID
			AND Name ='CONSUMED'


		INSERT INTO @tblPOMBOM (DefID,PickLight)
			SELECT MMList.[def_id]
				  ,MMLoc.LocAlias
			FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST]  MMList
				INNER JOIN [SitMesDB].[dbo].[MMLots] MMLot on MMLot.LotID=MMList.[lot]
				INNER JOIN [SitMesDB].[dbo].[MMLocations] MMLoc on MMLoc.LocPK=MMLot.LocPK
			 WHERE pom_material_specification_pk=@POMMatSpecID

		SELECT @MUSubAssm=MMList.Def_ID 
		FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST]  MMList
			INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] POMSpec on POMSpec.pom_material_specification_pk=MMList.pom_material_specification_pk
		WHERE POMSpec.pom_entry_pk= @MUEntryID
			AND POMSpec.Name ='PRODUCED'

	
		INSERT INTO @tblBOMItems (PartNo)
			SELECT MBOMItems.ItemAltName
			FROM [SitMesDB].[dbo].[MMDefinitions] MDef
			  INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
			  INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
			  INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
			WHERE MDef.DefID = @MUSubAssm
			ORDER BY MBOMItems.BomItemAltPK ASC

		SELECT	@intStartRow=	min(RowId)	,
				@intEndRow	=	max(RowId)	
		FROM	@tblBOMItems 

		WHILE	@intStartRow <=	@intEndRow	
			BEGIN
				SELECT @PartNo=PartNo
				FROM @tblBOMItems
				WHERE RowId=@intStartRow

				SELECT  @TopPick= ISNULL(PickID,0)
					FROM TempMULocation 
					WHERE PartNo=@PartNo
				
				IF @TopPick ='' or @TopPick is NULL
					BEGIN
						INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
							VALUES( 'L'+ CONVERT(nvarchar(255),@intStartRow) + 'PICKLOCATION','0','Numeric')
					END
				ELSE
					BEGIN
						INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
							VALUES( 'L'+ CONVERT(nvarchar(255),@intStartRow) + 'PICKLOCATION',@TopPick,'Numeric')
					END
				
				SELECT @intStartRow=@intStartRow+1
			END

		WHILE	@intStartRow <=	6
			BEGIN
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ( 'L'+ CONVERT(nvarchar(255),@intStartRow) + 'PICKLOCATION','0','Numeric')
				SELECT @intStartRow=@intStartRow+1
			END
	END
ELSE
	BEGIN
			/* Product Properties*/
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('JOBID',@OrderID , 'String')

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'NOOFLAYERS','0' ,'Numeric'
			FROM @tblProperty
			WHERE PropertyName='PROD_NoofLayers'

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'LENGTH','0' ,'Numeric'
			FROM @tblProperty
			WHERE PropertyName='PROD_Length'

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'WIDTH','0' ,'Numeric'
			FROM @tblProperty
			WHERE PropertyName='PROD_Width'

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('CoreHeight','0' ,'Numeric')
	
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('UnitSize','0' ,'Numeric')

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('ByPass','1' ,'Numeric')

		WHILE @ProcRow<=6
			BEGIN		
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ( 'L' + CONVERT(nvarchar(255),@ProcRow) + 'THICKNESS','0' ,'Numeric')
					
						
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ('L' + CONVERT(nvarchar(255),@ProcRow) + 'PATTERN','0', 'Numeric')
			
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES( 'L' +  CONVERT(nvarchar(255),@ProcRow) + 'Type','0' ,'Numeric')
		
				/* Control Recipe */
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ( 'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S1WidthFwd','0','Numeric')


				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ( 'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S2WidthRev','0','Numeric')

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES (  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S3LengthFwd','0','Numeric')

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ( 'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S4LengthRev','0','Numeric')

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ( 'L' +  CONVERT(nvarchar(255),@ProcRow) + 'S5WidthFwd','0','Numeric')

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES (  'L' +  CONVERT(nvarchar(255),@ProcRow) + 'ClampPres','0','Numeric')

				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ( 'L' +  CONVERT(nvarchar(255),@ProcRow) + 'BlowerPres','0','Numeric')

				SELECT @ProcRow =@ProcRow +1
			END


		/* Line Side Storage */
		SELECT @intStartRow =1
		WHILE	@intStartRow <=	6
			BEGIN
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES ( 'L'+ CONVERT(nvarchar(255),@intStartRow) + 'PICKLOCATION','0','Numeric')
				SELECT @intStartRow=@intStartRow+1
			END
		

	END


IF @GussettCount>0
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ( 'MattressType','0','Numeric')
	END
ELSE
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ( 'MattressType','1','Numeric')
	END
	
SELECT RTDSTag,Value,[DataType] FROM @tblPLCDS
GO
