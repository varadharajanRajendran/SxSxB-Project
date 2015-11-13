SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_BOM_Coil_GetPLCDS]
		@EntryID nvarchar(255)	
AS
 
 
DECLARE @PPRName nvarchar(50)			,
        @PPRVer  nvarchar(10)			,
		@OrderID		nvarchar(255)	

/*		
		,@EntryID nvarchar(255)
		
SELECT @EntryID ='107937814.SBCoil1'

*/
			

DECLARE	@tblBOMItems AS Table	(	RowId			int	IDENTITY	,
									PartNo			nvarchar(100)	,
									Class			nvarchar(255)	)
																		
DECLARE	@tblProperty AS Table	(	RowId			int	IDENTITY	,
									PropertyName	nvarchar(100)	,
									PropertyValue	nvarchar(100)	)

DECLARE	@tblPLCDS AS Table	(	RowId		int	IDENTITY	,
								RTDSTag		nvarchar(100)	,
								Value		nvarchar(50)	,
								[DataType]	nvarchar(2550)	)


SELECT @OrderID=Po.[pom_order_id]
FROM [SitMesDB].[dbo].[POM_ORDER] Po
	INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] Pe on Pe.pom_order_pk=Po.pom_order_pk
WHERE Pe.pom_entry_id=@EntryID

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	VALUES ('JOBID',@OrderID,'String')

INSERT INTO @tblBOMItems
	SELECT  ML.[def_id],
			ML.[Class]
	FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
		INNER JOIN [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq On Pe.equip_pk=Eq.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] PMs ON PMS.[pom_entry_pk]=Pe.[pom_entry_pk]
		INNER JOIN  [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML ON ML.pom_material_specification_pk=PMs.pom_material_specification_pk
	 WHERE pom_entry_id =@EntryID
	   AND PMs.[name]='CONSUMED'

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'WirePNo',ISNULL(PartNo, 'EMPTY'	),'String'
	FROM @tblBOMItems
	WHERE Class='RMCW'

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'PackPNo',ISNULL(PartNo, 'EMPTY'	),'String'
	FROM @tblBOMItems
	WHERE Class='RMBK'

INSERT INTO @tblProperty (PropertyName,PropertyValue)
	SELECT CONVERT(nvarchar(255),[pom_custom_fld_name]),	
		   CONVERT(nvarchar(255),[VAL])
	  FROM [SitMesDB].[dbo].[POM_CUSTOM_FIELD_RT] RT
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PE ON PE.pom_entry_pk=RT.pom_entry_pk
	  WHERE PE.pom_entry_id=@EntryID
		
INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'WireGauge',ISNULL(PropertyValue, 'EMPTY'),'String'
	FROM @tblProperty
	WHERE PropertyName='PROD_CoilDiameter'
  
INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'CoilSeries',ISNULL(PropertyValue, 'EMPTY'),'String'
	FROM @tblProperty
	WHERE PropertyName='PROD_CoilSeries'

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'Recipecode',ISNULL(PropertyValue, 'EMPTY'),'String'
	FROM @tblProperty
	WHERE PropertyName='PROD_MCCNumber'

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'Qty',ISNULL([quantity],0),'Numeric'
	FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS ON MS.[pom_material_specification_pk]=ML.[pom_material_specification_pk]
		INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] Pe ON pe.pom_entry_pk= MS.pom_entry_pk
	WHERE Pe.pom_entry_id=@EntryID
		AND MS.name='PRODUCED'

SELECT RTDSTag,Value,[DataType] FROM @tblPLCDS
GO
