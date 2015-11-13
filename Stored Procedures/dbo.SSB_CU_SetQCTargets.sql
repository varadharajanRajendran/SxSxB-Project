SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_CU_SetQCTargets]
		@OrderID	nvarchar(255)	,
		@MachineID	nvarchar(255)	,
		@EntryID				int	
AS
 
 DECLARE @PPR_name				nvarchar(255)	,
		 @PPR_Ver				nvarchar(255)	,
		 @QUALITY_ColumnCount	nvarchar(255)	,
		 @QUALITY_RowCount		nvarchar(255)	

/*
 SELECT  @OrderID		='nnnn1'	,
		 @MachineID		='CU'		,
		 @EntryID		=48082	
*/

SELECT @PPR_name=[ppr_name],
       @PPR_Ver=[ppr_version]
  FROM [SitMesDB].[dbo].[POM_ORDER]
  WHERE pom_order_id=@OrderID

SELECT @QUALITY_ColumnCount=VAL
  FROM [SitMesDB].[dbo].[PDMT_PS_PRP]
  WHERE PPR=@PPR_name
	AND PPR_VER=@PPR_Ver
	AND PS=@MachineID + '1'
	AND NAME='PROD_NoofColumns'

SELECT  @QUALITY_RowCount=VAL
  FROM [SitMesDB].[dbo].[PDMT_PS_PRP]
  WHERE PPR=@PPR_name
	AND PPR_VER=@PPR_Ver
	AND PS=@MachineID + '1'
	AND NAME='PROD_NoofRows'

UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]
	SET Default_Val=@QUALITY_RowCount
	WHERE  pom_entry_pk=@EntryID
		AND Name='QUALITY_RowCount'

UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]
	SET Default_Val=@QUALITY_ColumnCount
	WHERE  pom_entry_pk=@EntryID
		AND Name='QUALITY_ColumnCount'


GO
