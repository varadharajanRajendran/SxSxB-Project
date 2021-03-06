SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_PanelQuilt_SetQCTargets]
		@OrderID	nvarchar(255)	,
		@MachineID	nvarchar(255)	,
		@EntryID				int	
AS
 
 DECLARE @PPR_name				nvarchar(255)	,
		 @PPR_Ver				nvarchar(255)	,
		 @QUALITY_PanelLength	nvarchar(255)	,
		 @QUALITY_PanelWidth	nvarchar(255)	

/*
 SELECT  @OrderID		='nnnn1'	,
		 @MachineID		='CU'		,
		 @EntryID		=48082	
*/


SELECT @PPR_name=[ppr_name],
       @PPR_Ver=[ppr_version]
  FROM [SitMesDB].[dbo].[POM_ORDER]
  WHERE pom_order_id=@OrderID

SELECT @QUALITY_PanelLength=[PanelLength],
	   @QUALITY_PanelWidth=[PanelWidth]
  FROM [SSB].[dbo].[SSB_MattresSize]
  WHERE MattressSize=RIGHT(@PPR_name,2)


UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]
	SET Default_Val=@QUALITY_PanelLength
	WHERE  pom_entry_pk=@EntryID
		AND Name='QUALITY_PanelLength'

UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]
	SET Default_Val=@QUALITY_PanelWidth
	WHERE  pom_entry_pk=@EntryID
		AND Name='QUALITY_PanelWidth'


GO
