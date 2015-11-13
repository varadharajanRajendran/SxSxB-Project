SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_MES2Preactor_Download]
AS


DECLARE @StartRow	int				,
		@EndRow		int				,
		@ItemCount	int				,
		@EntryID	nvarchar(50)	,
		@LastEntry	nvarchar(50)	,
		@PoStatusID int
BEGIN TRY
EXEC [SSB].[dbo].[SSB_MES2Preactor_GetOrders]						/* Get Order and Entries */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateOrderProperties]			/* Get Order Properties and Entry Properties */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateSKUProperties]				/* Get SKU properties */

EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateQuiltData]					/* Get Quilter Properties */
UPDATE [SSB].[dbo].Temp_MES2Preactor								/* Update Part Description and Quantity */
	SET SAPart		=	ml.def_id		,
		ItemClass	=	ml.class		, 
		SAPartDesc	=	Mdef.[Descript]	,
		[Quantity]	=	ml.quantity
	FROM [SitMesDB].dbo.POM_ENTRY e
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MDef ON MDef.DefID=ml.def_id
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor Po ON Po.EntryID	=e.pom_entry_id
	WHERE ms.name='PRODUCED'

EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateBorderDecRoll]				/* Update Border Decoration roll */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateMCCH]						/* Update MCCH Data */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateRibbon]					/* Update Ribbon Data */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateHandle]					/* Update Handle Data */

EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateHGA]						/* Update BorderWire Part No */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateCU]						/* Update CoilUnit Part No */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateCoil]						/* Update Coil Part No */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateHalfCap]					/* Update Top Half Cap and Bottom Half Cap */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateGussett]					/* Update Gussett */
EXEC [SSB].[dbo].[SSB_MES2Preactor_UpdateGussettRoll]				/* Update Gussett Roll */


SELECT @StartRow=Count(RowID)
FROM [SSB].[dbo].Temp_MES2Preactor /* Update Order to Preactor and SitMesDB DB */
IF @StartRow>0
	BEGIN
		BEGIN	/* Update Preactor Interface Table */	
			DELETE FROM [SSB].[dbo].[SSB_MES2Preactor]
			INSERT INTO  [SSB].[dbo].[SSB_MES2Preactor]
				(	[OrderNo]
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
				  ,[GussettTick]
				  ,[GussettRP]
				  ,[GussettRF]
				  ,[GussettBK]
				  ,[GussettNeedleBar]
				  ,[Gussettpattern]
				  ,[GussettHeight]
				  ,[GussettGroup]
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
				  ,REPLACE([EntryID],'NULL','')
				  ,[CustomerNo]
				  ,IsNULL([CustomerName],'')
				  ,IsNULL([CustomerOrderNo],'')
				  ,IsNULL([CustomerOrderLineNo],'')
				  ,IsNULL([TruckID],'')
				  ,IsNULL([StopID],'')
				  ,[DueDate]
				  ,[DueTime]
				  ,[Quantity]
				  ,[FGPart]
				  ,[FGPartDesc]
				  ,REPLACE([SAPart],'NULL','')
				  ,REPLACE([SAPartDesc],'NULL','')
				  ,[BedSize]
				  ,IsNULL([Width],0)
				  ,IsNULL([Length],0)
				  ,IsNULL([ItemClass],'FGM')
				  ,[ProductType]
				  ,[CoreType]
				  ,[BorderType]
				  ,[PanelType]
				  ,IsNULL([QuiltNeedleSetting],'')
				  ,IsNULL([QuiltPatternCAM],'')
				  ,IsNULL([QuiltTick],'')
				  ,IsNULL([QuiltBacking],'')
				  ,IsNULL([QuiltLayer1],'')
				  ,IsNULL([QuiltLayer2],'')
				  ,IsNULL([QuiltLayer3],'')
				  ,IsNULL([QuiltLayer4],'')
				  ,IsNULL([QuiltLayer5],'')
				  ,IsNULL([QuiltLayer6],'')
				  ,IsNULL([BorderTick],'')
				  ,IsNULL([BorderRP],'')
				  ,IsNULL([BorderRF],'')
				  ,IsNULL([BorderBK],'')
				  ,IsNULL([BorderWidth],'')
				  ,IsNULL([BorderNeedleBar],'')
				  ,IsNULL([Borderpattern],'')
				  ,IsNULL([BorderNletHeight],'')
				  ,IsNULL([BorderBDRGroup],'')
				  ,IsNULL([ThreadLineColor],'')
				  ,IsNULL([BorderLabel],'')
				  ,IsNULL([BDType],'')
				  ,IsNULL([BDSAPart],'')
				  ,IsNULL([BorderStitch],'')
				  ,IsNULL([BorderRibbon],'')
				  ,IsNULL([BorderRibbonCord],'')
				  ,IsNULL([NLET],'')
				  ,IsNULL([ByPass],'')
				  ,IsNULL([BorderHandle],'')
				  ,IsNULL([BorderHandleStyle],'')
				  ,IsNULL([BorderHandleWidth],'')
				  ,IsNULL([BorderHandleGroup],'')
				  ,IsNULL([GussettSAPart],'')
				  ,IsNULL([GussettTick],'')
				  ,IsNULL([GussettRP],'')
				  ,IsNULL([GussettRF],'')
				  ,IsNULL([GussettBK],'')
				  ,IsNULL([GussettNeedleBar],'')
				  ,IsNULL([Gussettpattern],'')
				  ,IsNULL([GussettHeight],'')
				  ,IsNULL([GussettGroup],'')
				  ,IsNULL([BorderWire],'')
				  ,IsNULL([CoilSeries],'')
				  ,IsNULL([CoilType],'')
				  ,IsNULL([CoilWireGage],'')
				  ,IsNULL([CoilsperRow],'')
				  ,IsNULL([CoilQuantity],'')
				  ,IsNULL([TotalNoofRows],'')
				  ,IsNULL([FEC],'')
				  ,IsNULL([NumberOfMULayers],'')
				  ,IsNULL([ActualLine],'')
				  ,IsNULL([WaveGroup],'')
				  ,IsNULL([UnitType],'')
				  ,IsNULL([BorderCord],'')
				  ,IsNULL([MattressSides],'')
		  FROM [SSB].[dbo].Temp_MES2Preactor
		  Order By RowID ASC
		END
		
	
		BEGIN	/* Update Order Status in SitMesDB */
			SELECT @PoStatusID= [pom_order_status_pk]
			FROM [SitMesDB].[dbo].[POM_ORDER_STATUS]
			  Where id='To Be Scheduled' /* Scheduled */
			UPDATE [SitMesDB].[dbo].[POM_ORDER]
				SET [pom_order_status_pk]=@PoStatusID
				FROM  [SitMesDB].[dbo].[POM_ORDER_STATUS] Pos
					INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON Po.[pom_order_status_pk]=Pos.[pom_order_status_pk]
					INNER JOIN [SSB].[dbo].Temp_MES2Preactor tblPo ON tblPo.OrderID=Po.Pom_order_Id
				WHERE tblPo.ProcessType='Line'

		END
	

	END
END TRY
BEGIN CATCH
	SELECT @@Error as 'ErrorCode'
	SELECT ERROR_MESSAGE() AS 'ErrorMessage'
END CATCH
	
GO
