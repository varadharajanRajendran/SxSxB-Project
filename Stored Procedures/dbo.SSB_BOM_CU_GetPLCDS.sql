SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_BOM_CU_GetPLCDS]
		@EntryID nvarchar(255)	
AS
 		

DECLARE @PPRName	nvarchar(50)	,
        @PPRVer		nvarchar(10)	,
		@OrderID	nvarchar(50)	,
		@SelPartno	nvarchar(50)	,
		@PCAOrder	int				,
		@FECByPass	int			
/*
SELECT @EntryID='QC0000001.CU1'
*/

DECLARE	@tblBOMItems AS Table	(	RowId			int	IDENTITY	,
									PartNo			nvarchar(100)	,
									MachineID		nvarchar(255)	)
																		
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


INSERT INTO @tblProperty (PropertyName,PropertyValue)
	SELECT CONVERT(nvarchar(255),[pom_custom_fld_name]),	
		   CONVERT(nvarchar(255),[VAL])
	  FROM [SitMesDB].[dbo].[POM_CUSTOM_FIELD_RT] RT
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PE ON PE.pom_entry_pk=RT.pom_entry_pk
	  WHERE PE.pom_entry_id=@EntryID

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'C1PNO',PropertyValue ,'String'
	FROM @tblProperty
	WHERE PropertyName='PROD_C1PartNo'

SELECT @SelPartno=PropertyValue 
	FROM @tblProperty
	WHERE PropertyName='PROD_C1PartNo'

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'C1McID',MachineID ,'Numeric'
	FROM @tblBOMItems
	WHERE PartNo=@SelPartno

SELECT @SelPartno=PropertyValue 
	FROM @tblProperty
	WHERE PropertyName='PROD_C2PartNo'

IF @SelPartno IS NULL OR @SelPartno=''
	BEGIN	
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('C2PNO','EMPTY','String')

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('C2McID','0','Numeric')
	END
ELSE
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'C2PNO',ISNULL(PropertyValue ,'EMPTY'),'String'
			FROM @tblProperty
			WHERE PropertyName='PROD_C2PartNo'
		
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'C2McID',ISNULL(MachineID ,0),'Numeric'
			FROM @tblBOMItems
			WHERE PartNo=@SelPartno
	END


SELECT @SelPartno=PropertyValue 
	FROM @tblProperty
	WHERE PropertyName='PROD_C3PartNo'

IF @SelPartno IS NULL OR @SelPartno=''
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('C3PNO','EMPTY','String')
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('C3McID','0','Numeric')
	END
ELSE
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'C3PNO',ISNULL(PropertyValue  ,'EMPTY'),'String'
			FROM @tblProperty
			WHERE PropertyName='PROD_C3PartNo'

		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			SELECT 'C3McID',ISNULL(MachineID ,0),'Numeric'
			FROM @tblBOMItems
			WHERE PartNo=@SelPartno
	END


INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'CoilsinRow',PropertyValue ,'Numeric'
	FROM @tblProperty
	WHERE PropertyName='PROD_NoofColumns'

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'RowCount',PropertyValue ,'Numeric'
	FROM @tblProperty
	WHERE PropertyName='PROD_NoofRows'

INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	SELECT 'Recipecode',PropertyValue ,'Numeric'
	FROM @tblProperty
	WHERE PropertyName='PROD_RecipeCode'


SELECT @PCAOrder=COUNT(PT.[id])
FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON Po.[pom_order_pk]=Pe.pom_order_pk
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] Pt ON Pt.pom_entry_type_pk=pe.pom_entry_type_pk
WHERE  Po.[pom_order_id]=@OrderID
	AND PT.ID='HMB_OC_BUY'

IF @PCAOrder=0 
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('TransferHGA','0','Numeric')
	END
ELSE IF @PCAOrder>0 
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('TransferHGA','1','Numeric')
	END

SELECT @FECByPass=COUNT(PT.[id])
FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON Po.[pom_order_pk]=Pe.pom_order_pk
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] Pt ON Pt.pom_entry_type_pk=pe.pom_entry_type_pk
WHERE  Po.[pom_order_id]=@OrderID
	AND PT.ID='FEC'

IF @FECByPass=0 
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('FECByPass','1','Numeric')
	END
ELSE IF @FECByPass>0 
	BEGIN
		INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
			VALUES ('FECByPass','0','Numeric')
	END


SELECT RTDSTag,Value,[DataType] FROM @tblPLCDS
GO
