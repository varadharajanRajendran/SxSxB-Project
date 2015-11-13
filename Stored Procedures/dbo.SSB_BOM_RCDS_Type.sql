SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Find Order Decortation Type

  Output Parameters:
	RibbonType

  Input Parameters:
	@SAPartNo - SubAssembly Part No


  Trigger:
	From SIT BPM ADO Socket

  Data Read Other Inputs:  
	---

  Data Written Results:
	---

  Assumptions:
	---

  Dependencies 

	---

  Variables:
	---

  Tables Modified
	---

  Modification Change History:
  ---------------------------
  10/24/2014	Varadharajan R	C00V00 - Intial code
  
  
*/

CREATE PROCEDURE [dbo].[SSB_BOM_RCDS_Type]
		@SAPartNo nvarchar(255)	
AS
 


----------------------------------Declare Variables and Tables----------------------
DECLARE @intStartRow	int				,
        @intEndRow		int				,
        @intelProc		int				,
        @RCDSType		varchar(20)		,
        @ItemCount		int				,
        @RMTP			int				,
        @RMTK			int				,
        @SABQAY			int				,
        @RMRB			int				,
        @RMCB			int				,
		@BorderHeight	nvarchar(255)	,
		@ThreadColor	nvarchar(255)	,
		@ThreadQty		nvarchar(255)	,
		@CordLines		nvarchar(255)	,	
		@IssueLog		nvarchar(500)	,
		@IssueFound		bit					
				
DECLARE	@tblBOMItems AS Table	(	RowId			int	IDENTITY	,
									ItemClass		nvarchar(10)	,
									PartNo			nvarchar(100)	,
									PartDescription	nvarchar(255)	)

DECLARE	@tblProperty AS Table	(	RowId			int	IDENTITY	,
									PropertyID		nvarchar(255)	,
									PropertyValue	nvarchar(255)	)


SELECT @IssueFound=0,
	   @IssueLog=NULL  /* @SAPartNo='BDAY-7RBA037-1050' */

									
/* Get BOM Items */
INSERT INTO @tblBOMItems (ItemClass,PartNo)
	SELECT MBOMItems.AltGroupID,MBOMItems.ItemAltName
	FROM [SitMesDB].[dbo].[MMDefinitions] MDef
	  INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
	  INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
	  INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
	WHERE MDef.DefID=@SAPartNo /* 'BDAY-7RBA019-1050' */
	ORDER BY MBOMItems.BomItemAltPK ASC


INSERT INTO @tblProperty
	SELECT       Prop.[PropertyID], CONVERT(varchar(max),[SitMesDB].dbo.MMfBinToPropVal(BAPV.PropValue, 0)) AS PValue
	FROM         [SitMesDB].dbo.MMBomAltPrpVals AS BAPV Inner Join 
				 [SitMesDB].[dbo].[MMBomAlts] AS BOMs on BOMS.BOMAltPK=BAPV.BOMAltPK inner Join
				 [SitMesDB].[dbo].[MMProperties] AS Prop on Prop.PropertyPK=BAPV.PropertyPK 
	WHERE      BOMS.[BomAltName]=@SAPartNo AND 
			   Prop.[PropertyID] <>'MES_ONLY'

 

SELECT @RMTP=COUNT(Rowid) FROM @tblBOMItems Where ItemClass='RMTP'
SELECT @RMTK=COUNT(Rowid) FROM @tblBOMItems Where ItemClass='RMTK'
SELECT @RMRB=COUNT(Rowid) FROM @tblBOMItems Where ItemClass='RMRB'
SELECT @RMCB=COUNT(Rowid) FROM @tblBOMItems Where ItemClass='RMCB'
SELECT @SABQAY=COUNT(Rowid) FROM @tblBOMItems Where ItemClass='SABQAY'

SELECT @BorderHeight=COUNT(Rowid) FROM @tblProperty Where PropertyID='BORDERHEIGHT'
SELECT @ThreadColor=COUNT(Rowid) FROM @tblProperty Where PropertyID='THREADCOLOR'
SELECT @ThreadQty=COUNT(Rowid) FROM @tblProperty Where PropertyID='THREADQUANTITY'
SELECT @CordLines=COUNT(Rowid) FROM @tblProperty Where PropertyID='CORDLINES'	



IF @RMTP>0 AND @ThreadColor>0 AND @ThreadQty>0 SELECT @RCDSType='RS'		/* Ribbon Decorative Stitch */
ELSE IF  @RMCB>0 AND @CordLines>0 SELECT @RCDSType='RC'						/* Ribbon Cord */
ELSE IF  @RMTP>0 AND @BorderHeight>0 SELECT @RCDSType='R'					/* Ribbon */
ELSE IF  @RMRB>0 AND @BorderHeight>0 SELECT @RCDSType='R'					/* Ribbon */
ELSE SELECT @RCDSType='ByPass'												/* non Decoration */


SELECT @RCDSType='ByPass'

declare @tempTable table
(
	RCDSType nvarchar(250)
)
insert @tempTable select @RCDSType
SELECT * from @tempTable temp




GO
