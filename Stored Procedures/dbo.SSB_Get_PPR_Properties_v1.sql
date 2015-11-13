SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[SSB_Get_PPR_Properties_v1]
		@SAPartNo nvarchar(255)	
AS
 
DECLARE @ItemClass	nvarchar(20),
		@Segment	nvarchar(20),
		@GroupID	nvarchar(20)

DECLARE	@tblBOMProp AS Table	(	RowId			int	IDENTITY	,
									[PropertyID]	nvarchar(255)	,
									[PValue]		nvarchar(100)	,
									[DataType]		nvarchar(20)	)



SELECT @ItemClass=MMC.[ClassID]
  FROM [SitMesDB].[dbo].[MMClasses] MMC
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD on MMD.ClassPk=MMC.ClassPk
  WHERE MMD.DefID=@SAPartNo

SELECT  @GroupID=[DSC],
		@Segment=[VAL]
  FROM [SitMesDB].[dbo].[PDMT_GBL_PARM]
  WHERE PPR='SSB_CML'
	AND PPR_VER='0001.00'
	AND [ID]=@ItemClass

/* Properties */
IF @GroupID<>'NULL'
	BEGIN
		INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
			SELECT	 PPRProp.[NAME],
					 CONVERT(varchar(max),MMProp.[PValue]),
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


		/* Quality */
		INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
			SELECT	QCParam.[Param_Name]		,
					BOMProp.[PValue]			,
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
	/* GroupID */
	INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
		SELECT 'PROD_GroupID',@GroupID,'String'


SELECT PropertyID as PropertyName	,
	   [PValue]	  as PropertyValue	,
	   [DataType]
FROM @tblBOMProp
GO
