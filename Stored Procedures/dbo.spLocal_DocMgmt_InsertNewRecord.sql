SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE PROCEDURE [dbo].[spLocal_DocMgmt_InsertNewRecord]
						@Description		nvarchar(255) ,
						@FilePath			nvarchar(500) ,
						@FileType			nvarchar(255) ,
						@UnitGroup			nvarchar(255) ,
						@DocProcessGroup	nvarchar(255) ,
						@ActiveUser			nvarchar(255) 
AS

DECLARE	@UnitGroupID		int			  ,
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

	INSERT INTO [SSB].[dbo].[SSB_DocMgmt] 
				(	[Description]			,
					[FilePath]				,
					[DocProcessGroup]		,
					[UnitGroup]				,
					[FileType]				,
					[Status]				,
					[ModifiedDataTime]		,
					[ModifiedBy]			)
			VALUES
				(	@Description			,
					@FilePath				,
					@DocProcessGroupID		,
					@UnitGroupID			,
					@FileType	,
					1						,
					CURRENT_TIMESTAMP	,
					@ActiveUser			)


RETURN
GO
