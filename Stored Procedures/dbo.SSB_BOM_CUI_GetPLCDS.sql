SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_BOM_CUI_GetPLCDS]
		@orderID nvarchar(255)		
AS

DECLARE @PPRName nvarchar(50)			,
        @PPRVer  nvarchar(10)			,
	    @POMMatSpecID nvarchar(10)		,
		@intStartRow int				,
        @intEndRow int					,
        @intelProc int					,
		@PartNo nvarchar(100)			,
		@SubAssm  nvarchar(255)		,
		@OIrderID	nvarchar(255)		,	
		@ProcRow int					,
		@SelParamVal	nvarchar(255)	,
		@SelParamDesc	nvarchar(255)	,
		@EntryCount	int					,
		@BFlength		decimal(5,2)	,
		@BFWidth		decimal(5,2)	,
		@BFThickness	decimal(5,2)	,
		@SRlength		decimal(5,2)	,
		@SRWidth		decimal(5,2)	,
		@SRThickness	decimal(5,2)	,
		@ERlength		decimal(5,2)	,
		@ERWidth		decimal(5,2)	,
		@ERThickness	decimal(5,2)	,
		@EntryID		nvarchar(255)


DECLARE	@tblPOMBOM AS Table	(	RowId		int	IDENTITY	,
								DefID		nvarchar(100)	,
								PickLight	nvarchar(10)	)

DECLARE	@tblBOMItems AS Table	(	RowId			int	IDENTITY	,
									PartNo			nvarchar(100)	,
									ItemClass		nvarchar(100)	)
																		
DECLARE	@tblProperty AS Table	(	RowId			int	IDENTITY	,
									PropertyName	nvarchar(100)	,
									PropertyValue	nvarchar(100)	)

DECLARE	@tblPLCDS AS Table	(	RowId		int	IDENTITY	,
								RTDSTag		nvarchar(100)	,
								Value		nvarchar(50)	,
								[DataType]	nvarchar(255)	)
SELECT @ProcRow=1
	   
SELECT @PPRName=ppr_name,
	   @PPRVer= ppr_version  
FROM [SitMesDB].[dbo].[POM_ORDER] PO
  WHERE PO.[pom_order_id]=@OrderID


INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	VALUES ('Mattress_Size_Type',RIGHT(@PPRName,2),'Numeric')

/* GET FEC Parameters */
SELECT @EntryCount=COUNT(Pe.pom_entry_id)
FROM [SitMesDB].[dbo].[POM_ENTRY] Pe 
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=pe.pom_order_pk
WHERE Po.pom_order_id=@orderID
	AND Pe.pom_entry_id like '%FEC1%'
IF @EntryCount>0
	BEGIN
		SELECT @EntryID=Pe.pom_entry_id
		FROM [SitMesDB].[dbo].[POM_ENTRY] Pe 
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=pe.pom_order_pk
		WHERE Po.pom_order_id=@orderID
			AND Pe.pom_entry_id like '%FEC1%'
			
		INSERT INTO @tblProperty (PropertyName,PropertyValue)
		  SELECT NAME,VAL  FROM [SitMesDB].[dbo].[PDMT_PS_PRP] PRP
		  WHERE PPR=@PPRName 
			 AND PPR_VER=@PPRVer
			 AND PS='FEC1'
		  ORDER BY seq ASC
		  
		SELECT @BFlength=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_BFLength'
		 
		SELECT @BFThickness=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_BFThickness'
		
		SELECT @BFWidth=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_BFWidth'
		
		SELECT @ERlength=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_ERLength'
		 
		SELECT @ERThickness=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_ERThickness'
		
		SELECT @ERWidth=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_ERWidth'
	
		SELECT @SRlength=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_SRLength'
		 
		SELECT @SRThickness=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_SRThickness'
		
		SELECT @SRWidth=PropertyValue 
		FROM @tblProperty
		WHERE PropertyName='PROD_SRWidth'
	
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('Mattress_PassThru','0' ,'Numeric')		
	END
ELSE
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('Mattress_PassThru','1' ,'Numeric')	
	END


/* Get HMB Make Parameters - NEED TO REVISIT */
SELECT @EntryCount=COUNT(Pe.pom_entry_id)
FROM [SitMesDB].[dbo].[POM_ENTRY] Pe 
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=pe.pom_order_pk
WHERE Po.pom_order_id=@orderID
	AND Pe.pom_entry_id like '%Coil1%'
IF @EntryCount>0
	BEGIN
		/* Need to REVISIT WHILE TESTING COIL SEGMENT */
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('open_coil','0' ,'String')	
	END
ELSE
	BEGIN
		SELECT @EntryID=Pe.pom_entry_id
		FROM [SitMesDB].[dbo].[POM_ENTRY] Pe 
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=pe.pom_order_pk
		WHERE Po.pom_order_id=@orderID
			AND Pe.pom_entry_id like '%PurchaseCoilAssem1%'
	
		 SELECT @PartNo= ML.def_id
		 FROM [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS
			INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] PE on PE.[pom_entry_pk]=Ms.pom_entry_pk
			INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML on ML.pom_material_specification_pk=MS.pom_material_specification_pk
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD on MMD.DefID=ML.def_id
			INNER JOIN [SitMesDB].[dbo].[MMClasses] MMC on MMC.ClassPK=MMD.ClassPK
		 WHERE MS.name='CONSUMED'
			AND PE.pom_entry_id like '%' + @EntryID + '%'
			AND MMC.ClassID ='RMMU'
	
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('CoilsInRow','0' ,'Numeric')
		
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('Coil_Diameter','0' ,'Numeric')
		
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('Coil_Staggered','0' ,'Numeric')
		
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES('open_coil',@PartNo ,'String')
				
	END


SELECT RTDSTag,Value,[DataType] FROM @tblPLCDS
GO
