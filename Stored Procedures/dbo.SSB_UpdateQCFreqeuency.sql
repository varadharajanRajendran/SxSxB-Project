SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_UpdateQCFreqeuency]
		@EqID	nvarchar(255)	,	
		@MachineID	nvarchar(255)		
AS



DECLARE	@tblSamplingFreq AS Table ( RowId			int	IDENTITY	,
									FRQY			decimal(5,2)	,
									FRQY_UOM		decimal(5,2)	)

DECLARE @MinSampleFreq	decimal(5,2),
		@equip_pk		int		

INSERT INTO @tblSamplingFreq (FRQY,FRQY_UOM)
	SELECT DISTINCT PAR.FRQY, 
					CASE PAR.FRQY_UOM
						WHEN 'day'  THEN PAR.FRQY *60*24
						WHEN 'shift' THEN PAR.FRQY *60*8
						WHEN 'hour'	 THEN PAR.FRQY *60
						WHEN 'min'   THEN PAR.FRQY *1
					END
	FROM [SitMesDB].[dbo].[PDefM_PS] PS
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS_Param] PAR ON PS.PS=PAR.Param_PS
	WHERE PS.PS_PPR='SSB_CML'
		AND PAR.Param_Name Like 'QUALITY_%'
		AND PAR.FRQY>0
		AND PAR.Param_PS like '%' + @MachineID +'%'
		AND PAR.Param_Mandatory=1

SELECT @MinSampleFreq= MIN(FRQY_UOM) FROM @tblSamplingFreq

SELECT @equip_pk=equip_pk FROM [SitMesDB].[dbo].[BPM_EQUIPMENT]
WHERE equip_id=@EqID

UPDATE [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY]
	SET equip_prpty_value=@MinSampleFreq
	WHERE equip_prpty_id ='Sample_Frequency'
		AND equip_pk =@equip_pk


GO
