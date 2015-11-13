SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[SSB_Get_PPR_Properties]
		@SAPartNo nvarchar(255)	
AS
/*
Purpose   : Get Properties from Material Manager for PDefM Properties
Author    : Varadha R (Varadharajan.Rajendran@b-wi.com)
Revision  : Initial (Auguest.05.2015)
Changes   : UoM Included
*/ 
/*
DECLARE @SAPartNo	nvarchar(20)
SELECT @SAPartNo='QPAY-500070553-1050'
*/

DECLARE @ItemClass		nvarchar(20),
		@Segment		nvarchar(20),
		@GroupID		nvarchar(20),
		@intStart		int			,
		@intEnd			int			,
		@FillCount		int			,
		@selitemClass	nvarchar(50),
		@selPNo			nvarchar(50),
		@PartNo			nvarchar(50) ,
		@UoM			nvarchar(100)

DECLARE	@tblBOMProp AS Table	(	RowId			int	IDENTITY	,
									[PropertyID]	nvarchar(255)	,
									[PValue]		nvarchar(100)	,
									[UoM]			nvarchar(100)	,
									[DataType]		nvarchar(20)	)
DECLARE @tblItems as Table		(	RowId			int IDENTITY	,
									itemClass		nvarchar(50)	,
									PartNo			nvarchar(255)	,
									[Description]	nvarchar(255)	,
									[UoM]			nvarchar(100)	)
BEGIN TRY
	SELECT @ItemClass	= MMC.[ClassID],
		   @GroupID		= PAR.[DSC],
		   @Segment		= PAR.[VAL]
	FROM [SitMesDB].[dbo].[MMClasses] MMC
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD on MMD.ClassPk=MMC.ClassPk
		INNER JOIN  [SitMesDB].[dbo].[PDMT_GBL_PARM] PAR ON PAR.[ID]= MMC.[ClassID]
    WHERE MMD.DefID=@SAPartNo
		AND PPR='SSB_CML'
		AND PPR_VER='0001.00'
	IF @GroupID<>'NULL'		/* Properties */
		BEGIN
			INSERT INTO @tblBOMProp([PropertyID],[PValue],[UoM],[DataType])
				SELECT	 PPRProp.[NAME],
						 CONVERT(varchar(max),MMProp.[PValue]),
						 MMProp.UoMID,
						 PPRProp.[Typ]
				  FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMProp
				  INNER JOIN [SitMesDB].[dbo].[PDMT_PS_PRP] PPRProp ON PPRProp.[NAME]=CONVERT(varchar(max),'PROD_' + MMProp.[PropertyID])
				  INNER JOIN [SitMesDB].[dbo].[POMV_PRP_GRP_CFG] PropCfg ON PropCfg.pom_custom_fld_name=PPRProp.[NAME]
				  WHERE MMProp.BomAltName=@SAPartNo
					AND MMProp.PropertyID<>'MES_ONLY'
					AND PPRProp.PPR='SSB_CML'
					AND PPRProp.PPR_VER='0001.00'
					AND PPRProp.PS=@Segment+'*0001.00'
					AND PropCfg.[pom_cf_category_id]='Route'
			INSERT INTO @tblBOMProp([PropertyID],[PValue],[UoM],[DataType])	/* Quality */
				SELECT	QCParam.[Param_Name]		,
						BOMProp.[PValue]			,
						BOMProp.[UoM]				,
						CASE QCParam.[Param_Type]
							WHEN 'FLOAT' THEN 'Numeric'
							WHEN 'TRUTH-VALUE' THEN 'Boolean'
						END
				  FROM [SitMesDB].[dbo].[PDefM_PS_Param] QCParam
				  INNER JOIN  @tblBOMProp BOMProp on REPLACE(BOMProp.[PropertyID],'PROD_','')= REPLACE(QCParam.[Param_Name],'QUALITY_','')
				  WHERE QCParam.Param_PPR='SSB_CML'
						AND QCParam.Param_PPRVersion='0001.00'
						AND QCParam.Param_PS=@Segment+'*0001.00'
						AND QCParam.Param_Name<>'Quality_LogStatus'
						AND QCParam.Param_Name<>'TimetoCTQ'
						AND QCParam.[DATA_INTRPRTN]='Product' 
		END 
	INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])	/* GroupID */
		SELECT 'PROD_GroupID',@GroupID,'String'
	IF @itemClass='SAQPAY' OR @itemClass='SAQP2Y'		/* Get Custom Properties  Quilter Material Spec */
		BEGIN
			INSERT INTO @tblItems (itemClass	,PartNo	,[Description],UoM)
				SELECT MBOMItems.AltGroupID,MBOMItems.ItemAltName,MMDef.Descript,UoM.UoMID
				FROM [SitMesDB].[dbo].[MMDefinitions] MDef
					INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
					INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
					INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
					INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMDef on MMDef.DefID=MBOMItems.ItemAltName
					INNER JOIN [SitMesDB].[dbo].[MESUoMs] UoM ON UoM.UoMPK=MBOMItems.UoMPK
				WHERE MDef.DefID=@SAPartNo
				ORDER BY MBOMItems.BomItemAltPK
			SELECT  @FillCount=1,
					@intStart=Min(RowId),
					@intEnd=Max(RowId)
			FROM @tblItems
			WHILE @intStart<=@intEnd
				BEGIN
					SELECT @selitemClass=itemClass,
						   @selPNo	=PartNo	,
						   @UoM=UoM
					FROM @tblItems
					WHERE RowId=@intStart
					IF @selitemClass='RMBK'
						BEGIN
							INSERT INTO @tblBOMProp([PropertyID],[PValue],[UoM],[DataType])
								VALUES('PROD_BackingID',@selPNo,@UoM,'String')
						END
					ELSE IF @selitemClass='RMTK'
						BEGIN
							INSERT INTO @tblBOMProp([PropertyID],[PValue],[UoM],[DataType])
								VALUES('PROD_TickingID',@selPNo,@UoM,'String')
						END
					ELSE IF (@selitemClass='RMRF' or  @selitemClass='RMRP')
						BEGIN
							INSERT INTO @tblBOMProp([PropertyID],[PValue],[UoM],[DataType])
								VALUES('PROD_Fill' + CONVERT(nvarchar(10),@FillCount) +'ID',@selPNo,@UoM,'String')
							SELECT  @FillCount=@FillCount + 1
						END	
					SELECT @intStart=@intStart + 1
				END
		END	
	ELSE IF @itemClass='SAHNQY'		/* Handle Group */
		BEGIN
			INSERT INTO @tblItems (itemClass,PartNo	,[UoM],[Description])
				SELECT MBOMItems.AltGroupID,MBOMItems.ItemAltName,MMDef.Descript,UoM.UoMID
				FROM [SitMesDB].[dbo].[MMDefinitions] MDef
					INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
					INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
					INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
					INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMDef on MMDef.DefID=MBOMItems.ItemAltName
					INNER JOIN [SitMesDB].[dbo].[MESUoMs] UoM ON UoM.UoMPK=MBOMItems.UoMPK
				WHERE MDef.DefID=@SAPartNo
				ORDER BY MBOMItems.BomItemAltPK
			SELECT  @FillCount=1,
					@intStart=Min(RowId),
					@intEnd=Max(RowId)
			FROM @tblItems
			Update @tblBOMProp
				SET [PValue]='Non-Quilt'
				WHERE [PropertyID]='PROD_GroupID'
			WHILE @intStart<=@intEnd
				BEGIN
					SELECT @selitemClass=itemClass,
							@selPNo	=PartNo	,
							@UoM=UoM
					FROM @tblItems
					WHERE RowId=@intStart
					IF (@selitemClass='RMRF' or  @selitemClass='RMBK')
						BEGIN
							Update @tblBOMProp
								SET [PValue]='Quilt'
								WHERE [PropertyID]='PROD_GroupID'
							SELECT  @FillCount=@FillCount + 1
						END	
					SELECT @intStart=@intStart + 1
				END
		END	
	ELSE IF @itemClass='SAGSBY'	OR @itemClass='SAGS2Y'	/* Handle Group */
		BEGIN
			INSERT INTO @tblItems (itemClass	,PartNo	,[Description])
				EXEC [SSB].[dbo].[SSB_BOM_GetItems]
					@PartNo = @SAPartNo
			SELECT  @FillCount=1,
					@intStart=Min(RowId),
					@intEnd=Max(RowId)
			FROM @tblItems
			Update @tblBOMProp
				SET [PValue]='Non-Quilt'
				WHERE [PropertyID]='PROD_GroupID'
			WHILE @intStart<=@intEnd
				BEGIN
					SELECT @selitemClass=itemClass,
							@selPNo	=PartNo	
					FROM @tblItems
					WHERE RowId=@intStart
					IF (@selitemClass='RMRF' or  @selitemClass='RMBK')
						BEGIN
							Update @tblBOMProp
								SET [PValue]='Quilt'
								WHERE [PropertyID]='PROD_GroupID'
							SELECT  @FillCount=@FillCount + 1
						END	
					SELECT @intStart=@intStart + 1
				END
		END	
	ELSE IF @itemClass='SAMFAY'	/* MU Layer */
		BEGIN
			INSERT INTO @tblItems (itemClass,PartNo	,[Description])
				EXEC [SSB].[dbo].[SSB_BOM_GetItems]
					@PartNo = @SAPartNo

			INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
				SELECT 'PROD_L1PNo',PartNo,'String'
				FROM @tblitems
				WHERE rowID=1
			INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
				SELECT 'PROD_L2PNo',PartNo,'String'
				FROM @tblitems
				WHERE rowID=2
			INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
				SELECT 'PROD_L3PNo',PartNo,'String'
				FROM @tblitems
				WHERE rowID=3
			INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
				SELECT 'PROD_L4PNo',PartNo,'String'
				FROM @tblitems
				WHERE rowID=4
			INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
				SELECT 'PROD_L6PNo',PartNo,'String'
				FROM @tblitems
				WHERE rowID=5
			INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
				SELECT 'PROD_L6PNo',PartNo,'String'
				FROM @tblitems
				WHERE rowID=6
		END
	SELECT PropertyID as PropertyName	,
		   [PValue]	  as PropertyValue	,
		   [DataType],
		   ISNULL([UoM],'NA') as UoM
	FROM @tblBOMProp
END TRY
BEGIN CATCH
	SELECT @@Error as 'ErrorCode'
	SELECT ERROR_MESSAGE() AS 'ErrorMessage'
END CATCH
GO
