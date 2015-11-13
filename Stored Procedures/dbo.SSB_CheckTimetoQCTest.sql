SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_CheckTimetoQCTest]
	@EntryID	nvarchar(255)
AS
 
 DECLARE @PS				nvarchar(255)	,
		 @EqID				nvarchar(255)	,
		 @Freq				decimal(5,2)	,
		 @TimeDiff			decimal(10,2)	,
		 @LastSampleTime	nvarchar(255)	,
		 @ParmCounter		int				,
		 @EntryPK			int				,
		 @EqPK				int				,
		 @MachineName		nvarchar(255)	,
		 @OrderID			nvarchar(255)	,
		 @MachineID			nvarchar(255)	,
		 @SqlTrace			nvarchar(1000)	
/*
		 ,@OrderID			nvarchar(50)	,
		 @MachineID			nvarchar(255)	
SELECT @MachineID='MCCH',
		@OrderID ='107931002'
*/

/*
 SELECT @EqID			=	Eq.equip_id		,
	    @EntryID		=	PoE.pom_entry_pk	,
		@MachineName	=	REPLACE(PS.PS,'*0001.00','')
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk]
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]
	WHERE PS.PS_PPR='SSB_CML'
		AND PT.[id] like '%'+ @MachineID	 + '%'
		AND Po.pom_order_id =@OrderID
 */
  SELECT @EqID			=	Eq.equip_id		,
	     @EntryPK		=	PoE.pom_entry_pk	,
		@MachineName	=	REPLACE(PS.PS,'*0001.00',''),
		@OrderID=Po.pom_order_id,
		@MachineID=Pt.id
  FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk]
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]
  WHERE PS.PS_PPR='SSB_CML'
		AND PoE.pom_entry_id=@EntryID
		
SELECT @ParmCounter=COUNT([Param_Desc])
  FROM [SitMesDB].[dbo].[PDefM_PS_Param]
  WHERE Param_PPR='SSB_CML'
	AND Param_PS like '%'+ @MachineName	 + '%'
	AND Param_Name like 'QUALITY%'


IF @ParmCounter>0 
BEGIN
	SELECT @Freq=EP.equip_prpty_value,
		   @EqPK=E.equip_pk
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] EP
		INNER JOIN  [SitMesDB].[dbo].[BPM_EQUIPMENT] E ON E.equip_pk=EP.equip_pk
	WHERE EP.equip_prpty_id ='Sample_Frequency' 
		AND E.equip_id =@EqID
 
	SELECT @LastSampleTime=EP.equip_prpty_value
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] EP
		INNER JOIN  [SitMesDB].[dbo].[BPM_EQUIPMENT] E ON E.equip_pk=EP.equip_pk
	WHERE EP.equip_prpty_id ='Last_Sample_Time' 
		AND E.equip_id =@EqID
 
	

	IF @LastSampleTime='' OR @LastSampleTime IS NULL 
		BEGIN
			IF @MachineName='CU'
				BEGIN
					EXEC [dbo].[SSB_CU_SetQCTargets] @OrderID,	@MachineName,	@EntryPK	
				END
			ELSE IF @MachineName='MCCHL'
				BEGIN
					EXEC [dbo].[SSB_MCCHL_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
				END
			ELSE IF @MachineName='Gussett'
				BEGIN
					EXEC [dbo].[SSB_Gussett_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
				END
			ELSE IF @MachineName='PanelQuilt'
				BEGIN
					EXEC [dbo].[SSB_PanelQuilt_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
				END
			ELSE IF @MachineName='OverCast' 
				BEGIN
					EXEC [dbo].[SSB_OverCast_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
				END
			ELSE IF @MachineName='ClosingStation'
				BEGIN
					EXEC [dbo].[SSB_CLS_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
				END

			UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]
						SET VALUE=1
						WHERE pom_entry_pk=@EntryPK
							AND name ='TimetoCTQ'	
			
			UPDATE [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY]
				SET equip_prpty_value=GETDATE()
				WHERE equip_pk=@EqPK
					AND equip_prpty_id ='Last_Sample_Time' 

			EXEC  [dbo].[SSB_UpdateQCFreqeuency] @EqID,@MachineName

		END
	ELSE
		BEGIN
			SELECT @TimeDiff=DATEDIFF(MINUTE,@LastSampleTime,GETDATE())
			
			SELECT @SqlTrace ='EntryID=' + 	@EntryID +'  ; EqID=' + @EqID  +'  ; MCName=' + @MachineName+'  ; TimeStamp=' + CONVERT(nvarchar(max),@TimeDiff)  +'  ; Freq=' + CONVERT(nvarchar(max),@Freq)
			PRINT @SqlTrace
			exec sp_trace_generateevent 82, @sqlTrace

			IF @TimeDiff>=@Freq OR @Freq is NULL
				BEGIN
					IF @MachineName='CU'
						BEGIN
							EXEC [dbo].[SSB_CU_SetQCTargets] @OrderID,	@MachineName,	@EntryPK	
						END
					ELSE IF @MachineName='MCCHL'
						BEGIN
							EXEC [dbo].[SSB_MCCHL_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
						END
					ELSE IF @MachineName='Gussett'
						BEGIN
							EXEC [dbo].[SSB_Gussett_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
						END
					ELSE IF @MachineName='PanelQuilt'
						BEGIN
							EXEC [dbo].[SSB_PanelQuilt_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
						END
					ELSE IF @MachineName='OverCast' 
						BEGIN
							EXEC [dbo].[SSB_OverCast_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
						END
					ELSE IF @MachineName='ClosingStation'
						BEGIN
							EXEC [dbo].[SSB_CLS_SetQCTargets] @OrderID,	@MachineName,	@EntryPK
						END

					UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]
						SET VALUE=1
						WHERE pom_entry_pk=@EntryPK
							AND name ='TimetoCTQ'	
					
					UPDATE [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY]
						SET equip_prpty_value=GETDATE()
						WHERE equip_pk=@EqPK
							AND equip_prpty_id ='Last_Sample_Time' 

					EXEC  [dbo].[SSB_UpdateQCFreqeuency] @EqID,@MachineName
			END
		END
END




GO
