SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_BOM_PCA_GetPLCDS]
		@EntryID nvarchar(255)	
AS
 
 
DECLARE @PPRName	nvarchar(50)	,
        @PPRVer		nvarchar(10)	,
		@OrderID	nvarchar(50)	,
		@SelPartno	nvarchar(50)	,
		@PCAOrder	int				,
		@FECByPass	int			

/*
SELECT @EntryID='107937907.PurchaseCoilAssem1'
*/

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
