SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spLocal_DocMgmt_ObsoleteDocument]
						@Description		nvarchar(255) ,
						@FilePath			nvarchar(500) ,
						@UnitGroup			nvarchar(255) ,
						@DocProcessGroup	nvarchar(255) ,
						@ActiveUser			nvarchar(255) 
AS

DECLARE	@UnitGroupID		int ,
		@DocProcessGroupID	int          

    SELECT @UnitGroup=equip_Property.equip_prpty_value
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] as equip_Property
		INNER JOIN [SitMesDB].[dbo].[BPM_EQUIPMENT] as equip_list 
			on equip_list.equip_pk=equip_Property.equip_pk 
			AND equip_Property.equip_prpty_id='MACHINE_MODEL'
			AND equip_list.[equip_label]=@UnitGroup
			AND equip_id like 'WPB.CML01.%' 

    SELECT @UnitGroupID =UG.pk
	FROM [SSB].[dbo].[SSB_UnitGroup] as UG
	WHERE	UG.[Description]=@UnitGroup

	SELECT @DocProcessGroupID=DPG.pk
	FROM [SSB].[dbo].[SSB_DocProcessGroup] as DPG
	WHERE DPG.[Description]=@DocProcessGroup


	SELECT @UnitGroupID,@DocProcessGroupID,CURRENT_TIMESTAMP

	UPDATE [SSB].[dbo].[SSB_DocMgmt] 
		SET Status=3,
		[ModifiedDataTime]=	CURRENT_TIMESTAMP,
		[ModifiedBy]=@ActiveUser	
	WHERE 
		[Description]		= @Description			
		AND [FilePath]			= @FilePath				
		AND [DocProcessGroup]	= @DocProcessGroupID	
		AND [UnitGroup]			= @UnitGroupID			

RETURN
GO
