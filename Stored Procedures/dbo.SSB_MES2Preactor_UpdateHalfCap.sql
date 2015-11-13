SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateHalfCap]	
AS

DECLARE @tblEntryBOM as Table	(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									ItemClass		nvarchar(255)	,
									PartNo			nvarchar(50)	,
									[UID]			nvarchar(50)	)
DECLARE	@tblMCCHData AS Table	(	RowId				int	IDENTITY	,
								PID					int				,
								OrderID				nvarchar(50)	,
								ProcessType			nvarchar(50)	,
								PlantNo				nvarchar(50)	,
								EntryID				nvarchar(50)	,
								FGPart				nvarchar(50)	,
								FGPartDesc			nvarchar(255)	,
								Qty					int				,
								SAPart				nvarchar(50)	,
								SAPartDesc			nvarchar(255)	,
								BedSize				nvarchar(50)	,
								ItemClass			nvarchar(50)	,
								BorderTick			nvarchar(50)	,
								BorderRP			nvarchar(50)	,
								BorderRF			nvarchar(50)	,
								BorderBK			nvarchar(50)	,
								BorderWidth			float			,
								BorderNeedleBar		nvarchar(50)	,
								Borderpattern		nvarchar(50)	,
								BorderNletHeight	float			,
								BorderBDRGroup		nvarchar(50)	,
								ThreadLineColor		nvarchar(50)	,
								BorderLabel			nvarchar(50)	,
								BDType				nvarchar(50)	,
								BDSAPart			nvarchar(50)	,
								BorderStitch		nvarchar(50)	,
								BorderRibbon		nvarchar(50)	,
								BorderRibbonCord	nvarchar(50)	,
								NLET				nvarchar(50)	,
								ByPass				nvarchar(50)	,
								BorderHandle		nvarchar(50)	,
								BorderHandleStyle	nvarchar(50)	,
								BorderHandleWidth	float			,
								BorderHandleGroup	nvarchar(50)	)

INSERT INTO @tblMCCHData(PID,OrderID,ProcessType,PlantNo,EntryID,FGPart,FGPartDesc,Qty,SAPart,SAPartDesc,
						BedSize,ItemClass,BorderTick,BorderRP,BorderRF,BorderBK,BorderWidth,BorderNeedleBar,
						Borderpattern,BorderNletHeight,BorderBDRGroup,ThreadLineColor,BorderLabel,
						BDType,BDSAPart,BorderStitch,BorderRibbon,BorderRibbonCord,NLET,
						ByPass,BorderHandle	,BorderHandleStyle,BorderHandleWidth,BorderHandleGroup	)
		SELECT PID,OrderID,ProcessType,PlantNo,EntryID,FGPart,FGPartDesc,[Quantity],SAPart,SAPartDesc,BedSize,
				ItemClass,BorderTick,BorderRP,BorderRF,BorderBK,BorderWidth,BorderNeedleBar,Borderpattern,BorderNletHeight	,
				BorderBDRGroup,ThreadLineColor,BorderLabel,BDType,BDSAPart,BorderStitch,BorderRibbon,BorderRibbonCord,NLET,ByPass,
				BorderHandle,BorderHandleStyle,BorderHandleWidth,BorderHandleGroup	
		FROM [SSB].[dbo].Temp_MES2Preactor
		WHERE ProcessType='MCCH'
INSERT INTO @tblEntryBOM(EntryID,ItemClass,PartNo,[UID])
	SELECT e.pom_entry_id,  ml.class,ml.def_id,o.Pom_order_id
	FROM   [SitMesDB].dbo.POM_ORDER AS o 
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor Po ON Po.EntryID= e.pom_entry_id
	WHERE (Po.ProcessType='THC' 
			OR Po.ProcessType='BHC')
		AND ms.name='CONSUMED'
		AND ml.class='SAFBAY'
UPDATE [SSB].[dbo].Temp_MES2Preactor
	SET BorderTick=	MCCH.BorderTick,
		BorderRP	=MCCH.BorderRP,
		BorderRF=	MCCH.BorderRF,
		BorderBK=MCCH.BorderBK,
		BorderWidth=MCCH.BorderWidth,
		BorderNeedleBar=MCCH.BorderNeedleBar,
		Borderpattern=MCCH.Borderpattern,
		BorderNletHeight=MCCH.BorderNletHeight	,
		BorderBDRGroup=MCCH.BorderBDRGroup,
		ThreadLineColor=MCCH.ThreadLineColor,
		BorderLabel=MCCH.BorderLabel,
		BDType=MCCH.BDType,
		BDSAPart=MCCH.BDSAPart,
		BorderStitch=MCCH.BorderStitch,
		BorderRibbon=MCCH.BorderRibbon,
		BorderRibbonCord=MCCH.BorderRibbonCord,
		NLET=MCCH.NLET,
		ByPass=MCCH.ByPass,
		BorderHandle=MCCH.BorderHandle,
		BorderHandleStyle=MCCH.BorderHandleStyle,
		BorderHandleWidth=MCCH.BorderHandleWidth,
		BorderHandleGroup=MCCH.BorderHandleGroup	
	FROM @tblMCCHData MCCH
		INNER JOIN @tblEntryBOM EnB	on EnB.UID=MCCH.OrderID
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor Po ON Po.EntryID=EnB.EntryID
	WHERE EnB.PartNo=MCCH.SAPart
UPDATE [SSB].[dbo].Temp_MES2Preactor
	SET GussettSAPart =ml.def_id
	FROM   [SitMesDB].dbo.POM_ORDER AS o  
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor Po ON Po.EntryID=e.pom_entry_id
	WHERE (Po.ProcessType='THC' 
			OR Po.ProcessType='BHC')
		AND ( ml.class='SAGS2Y'
			OR ml.class='SAGSAY')
		AND ms.name='CONSUMED'

GO
