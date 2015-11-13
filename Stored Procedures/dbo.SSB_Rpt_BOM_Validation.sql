SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_Rpt_BOM_Validation]
		@FGPartNo		nvarchar(255)
AS



/*
DECLARE @FGPartNo		nvarchar(255)
SELECT @FGPartNo = N'700024367-1050'
*/
DECLARE @intCoilCount		int				,
		@intHMBCount		int				,
		@intHGACount		int				,
		@intFECCount		int				,
		@intRBACount		int				,
		@intHNCount			int				,
		@intTHCCount		int				,
		@intBHCCount		int				,
		@intGACount			int				,
		@intBACount			int				,
		@intPQCount			int				,
		@intnPQCount		int				,
		@intPOCCount		int				,
		@intPACount			int				,
		@intMUCount			int				,
		@intCLSCount		int				,
		@intINSCount		int				,
		@intPKGCount		int				,
		@intBPKGCount		int				,
		@intCoilSelCount	int			,
		@SubAssmPartNo		nvarchar(255)	,
		@ItemCount			int				,
		@PartsItemCount		int				,
		@Item				nvarchar(255)	,
		@PartExistcount		int				,
		@SelPart			nvarchar(255)	,
		@PropertCount		int				,
		@SelProperty		nvarchar(255)	,
		@SelPropValue		nvarchar(255)	,
		@SetPanelType		nvarchar(50)	,
		@FGProperty			nvarchar(50)	,
		@BorderType			nvarchar(50)	,
		@Handle				nvarchar(50)	,
		@Ribbon				nvarchar(50)	,
		@RibbonCord			nvarchar(50)	,
		@RibbonStitch		nvarchar(50)	,
		@MattressType		nvarchar(50)	,
		@ByPass				nvarchar(50)	,
		@CoreType			nvarchar(50)	,
		@SelCoil			nvarchar(50)	,
		@strnewID			nvarchar(255)	,
		@CurrentDateTime	DateTime		,
		@LogStatus			int	

DECLARE	@tblFGBOMItems AS Table	(	RowId			int	IDENTITY	,
									ItemClass		nvarchar(10)	,
									PartNo			nvarchar(100)	,
									PartDescription	nvarchar(255)	)

DECLARE	@tblFGBOMProp AS Table	(	RowId			int	IDENTITY	,
									PropertyID		nvarchar(100)	,
									PValue			nvarchar(255)	)

DELETE FROM [SSB].[dbo].SSB_MES_IssueLog
DELETE  FROM [SSB].[dbo].SSB_MES_Log

INSERT INTO @tblFGBOMProp (PropertyID,PValue)
	EXEC [SSB].[dbo].[SSB_BOM_GetProperties] @FGPartNo
INSERT INTO @tblFGBOMItems (ItemClass	,PartNo	,PartDescription)
	EXEC [SSB].[dbo].[SSB_BOM_GetItems] @FGPartNo

SELECT @BorderType	=PValue
FROM @tblFGBOMProp
WHERE PropertyID='BorderType'
SELECT @Handle	=PValue
FROM @tblFGBOMProp
WHERE PropertyID='Handle'
SELECT @Ribbon	=PValue
FROM @tblFGBOMProp
WHERE PropertyID='Ribbon'
SELECT @RibbonCord	=PValue
FROM @tblFGBOMProp
WHERE PropertyID='RibbonCord'
SELECT @RibbonStitch	=PValue
FROM @tblFGBOMProp
WHERE PropertyID='RibbonStitch'
SELECT @MattressType=PValue
FROM @tblFGBOMProp
WHERE PropertyID='MattressType'
SELECT @CoreType=PValue
FROM @tblFGBOMProp
WHERE PropertyID='CoreType'


/* Coil Assembly */
SELECT @intCoilCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass like'SACMY%' 
SELECT @intCoilSelCount=1
IF @intCoilCount>0 and @CoreType='Make'
	BEGIN
		SELECT @intCoilSelCount=1
		WHILE @intCoilSelCount <=@intCoilCount
			BEGIN
				SELECT @SelCoil='SACMY' + CONVERT(nvarchar(5), @intCoilSelCount)
				SELECT @SubAssmPartNo=PartNo
				FROM @tblFGBOMItems
				WHERE ItemClass=@SelCoil 
				IF @SubAssmPartNo IS NOT NULL OR @SubAssmPartNo<>'' OR @SubAssmPartNo<>NULL
				BEGIN
					INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
					VALUES (@FGPartNo,'Coil',@SubAssmPartNo,'BOM contains COIL Sub-Assembly with Item Class ' + @SelCoil ,'Information','BOM Item')
					EXEC [SSB].[dbo].[SSB_BOM_ValidateCoil] @FGPartNo,@SubAssmPartNo
				END
				SELECT @intCoilSelCount=@intCoilSelCount + 1
			END
	END
ELSE IF @intCoilCount>0 and @CoreType<>'Make'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Coil',@SubAssmPartNo,'BOM contains COIL Sub-Assembly but the Core Type Property is not HMB MAKE','ERROR','BOM Item')
	END
ELSE IF @intCoilCount=0 and @CoreType='Make'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Coil',@SubAssmPartNo,'BOM contains does not contains Coil Sub-Assembly but the Core Type Property is HMB MAKE','ERROR','BOM Item')
	END
ELSE IF @intCoilCount=0 and @CoreType<>'Make'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Coil',@SubAssmPartNo,'BOM contains does not contains Coil Sub-Assembly','Information','BOM Item')
	END

/* HMB Assembly */
SELECT @intHMBCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAMCAY' 
IF @intHMBCount>0 and @CoreType='Make'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMCAY' 
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'HMB',@SubAssmPartNo,'BOM contains HMB Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateHMB] @FGPartNo,@SubAssmPartNo,@intCoilCount
	END
ELSE IF @intHMBCount>0 and @CoreType='Make'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMCAY' 
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'HMB',@SubAssmPartNo,'BOM contains HMB Sub-Assembly but the Core Type Property is not HMB MAKE','ERROR','BOM Item')
	END
ELSE IF @intHMBCount=0 and @CoreType='Make'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMCAY' 
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'HMB',@SubAssmPartNo,'BOM contains does not contains HMB Sub-Assembly but the Core Type Property is HMB MAKE','ERROR','BOM Item')
	END
ELSE IF @intHMBCount=0 and @MattressType<>'Make'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMCAY' 
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'HMB',@SubAssmPartNo,'BOM contains does not contains HMB Sub-Assembly ','Information','BOM Item')
	END

/* HGA Assembly */
SELECT @intHGACount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAMWUY' 
IF @intHGACount>0 and @CoreType='Buy'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMWUY' 
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'HGA',@SubAssmPartNo,'BOM contains HOG RING Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateHGA] @FGPartNo,@SubAssmPartNo
	END
ELSE IF @intHGACount>0 and @CoreType='Buy'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMWUY' 
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'HGA',@SubAssmPartNo,'BOM contains HOG RING Sub-Assembly but the Core Type Property is not HMB BUY','ERROR','BOM Item')
	END
ELSE IF @intHGACount=0 and @CoreType='Buy'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMWUY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'HGA',@SubAssmPartNo,'BOM contains does not contains HOG RING Sub-Assembly but the Core Type Property is HMB BUY','ERROR','BOM Item')
	END
ELSE IF @intHGACount=0 and @MattressType<>'Buy'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMWUY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'HGA',@SubAssmPartNo,'BOM contains does not contains HOG RING Sub-Assembly ','Information','BOM Item')
	END

/* FEC Assembly */
SELECT @intFECCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAMFUY' 
IF @intFECCount>0 and @MattressType='FEC'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMFUY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'FEC',@SubAssmPartNo,'BOM contains FEC Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateFEC] @FGPartNo,@SubAssmPartNo
	END
ELSE IF @intFECCount>0 and @MattressType<>'FEC'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMFUY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'FEC',@SubAssmPartNo,'BOM contains FEC Sub-Assembly but the Mattress Type Property is non FEC','ERROR','BOM Item')
	END
ELSE IF @intFECCount=0 and @MattressType='FEC'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMFUY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'FEC',@SubAssmPartNo,'BOM does not contains FEC Sub-Assembly but the Mattress Type Property is FEC','ERROR','BOM Item')
	END
ELSE IF @intFECCount=0 and @MattressType<>'FEC'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMFUY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'FEC','','BOM does not contains FEC Sub-Assembly ','Information','BOM Item')
	END

/* MU Assembly */
SELECT @intMUCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAMFAY' 
IF @intMUCount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMFAY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'MU',@SubAssmPartNo,'BOM contains MU Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateMU] @FGPartNo,@SubAssmPartNo
	END
ELSE 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMFAY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'MU','','BOM does not contains MU Sub-Assembly ','Information','BOM Item')
	END
	
/* RIBBON Assembly */
SELECT @intRBACount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SABDAY'
IF @intRBACount=0 AND ( @Ribbon<>'Yes' OR @RibbonCord<>'Yes' OR @RibbonStitch<>'Yes')
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Ribbon','','BOM does not contains RIBBON Segments (SABDAY) due to BYPASS','Information','BOM Item')
	END
ELSE IF @intRBACount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SABDAY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Ribbon',@SubAssmPartNo,'BOM contains RIBBON Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateRBA] @FGPartNo,@SubAssmPartNo, @Ribbon,@RibbonCord,@RibbonStitch
	END
ELSE IF @intRBACount=0
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Ribbon','','BOM does not contains RIBBON Segments (SABDAY)','ERROR','BOM Item')
	END

/* Handle Assembly */
SELECT @intHNCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAHNAY'
IF @intHNCount>0 and @Handle='Yes'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAHNAY'
		
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Handle',@SubAssmPartNo,'BOM contains HANDLE Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateHN] @FGPartNo,@SubAssmPartNo
	END
ELSE IF @intHNCount>0 AND @Handle<>'Yes'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Handle',@SubAssmPartNo,'BOM contains HANDLE Segments (SAHNAY) but the Mattress Trait Handle =YES','ERROR','BOM Item')
	END
ELSE IF @intHNCount=0 AND @Handle='Yes'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Handle','','Mattress Trait Handle =YES but BOM does not contains  HANDLE (SAHNAY) Segment','ERROR','BOM Item')
	END	

/* MCCH Finished Border */
SELECT @intBHCCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAFBAY'
IF @intBHCCount=0 
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'MCCH','','BOM does not contains MCCH/FINISHED BORDER Segments (SAFBAY)','ERROR','BOM Item')
	END
ELSE IF @intBHCCount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAFBAY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'MCCH',@SubAssmPartNo,'BOM contains MCCH/FINISHED BORDER Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateMCCH] @FGPartNo,@SubAssmPartNo,@Handle, @Ribbon,@RibbonCord,@RibbonStitch
	END

/* Bottom Half Cap */
SELECT @intBHCCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SABCAY'
SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SABCAY'
IF @BorderType='TT' and @intBHCCount>0 
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Bottom Half Cap',@SubAssmPartNo,'BOM contains BOTTOM HALF CAP Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateBHC] @FGPartNo,@SubAssmPartNo,@BorderType
	END
ELSE IF @intBHCCount>0 AND @BorderType<>'TT'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Bottom Half Cap',@SubAssmPartNo,'BOM contains BOTTOM HALF CAP Segments (SABCAY) but the Mattress Border Type Trait is not TT','WARNING','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateBHC] @FGPartNo,@SubAssmPartNo,@BorderType
	END
ELSE IF @intBHCCount=0 AND @BorderType='TT'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Bottom Half Cap','','Mattress Border Type Trait is TT but BOM does not contains  BOTTOM HALF CAP (SABCAY) Segment','ERROR','BOM Item')
	END	

/* Top Half Cap */
SELECT @intTHCCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SATCAY'
IF @BorderType='PT' and @intTHCCount>0 
	BEGIN
			SELECT @SubAssmPartNo=PartNo
			FROM @tblFGBOMItems
			WHERE ItemClass='SATCAY'
			INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
				VALUES (@FGPartNo,'Top Half Cap',@SubAssmPartNo,'BOM contains TOP HALF CAP Sub-Assembly','Information','BOM Item')
			EXEC [SSB].[dbo].[SSB_BOM_ValidateTHC] @FGPartNo,@SubAssmPartNo,@BorderType
	END
ELSE IF @intTHCCount>0 AND @BorderType<>'PT'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Top Half Cap',@SubAssmPartNo,'BOM contains TOP HALF CAP Segments (SATCAY) but the Mattress Border Type Trait is not PT','ERROR','BOM Item')
	END
ELSE IF @intTHCCount=0 AND @BorderType='PT'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Top Half Cap','','Mattress Border Type Trait is PT but BOM does not contains  TOP HALF CAP (SATCAY) Segment','ERROR','BOM Item')
	END	

/* Gussett */
SELECT @intGACount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAGSAY'
IF @BorderType='PT' and @intGACount>0
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAGSAY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Gussett Assembly',@SubAssmPartNo,'BOM contains GUSSETT Sub-Assembly','Information','BOM Item')
			EXEC [SSB].[dbo].[SSB_BOM_ValidateGA] @FGPartNo,@SubAssmPartNo
	END
ELSE IF @intGACount>0 AND @BorderType<>'PT'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Gussett Assembly',@SubAssmPartNo,'BOM contains GUSSETT Segments (SAGSAY) but the Mattress Border Type Trait is not PT','ERROR','BOM Item')
	END
ELSE IF @intGACount=0 AND @BorderType='PT'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Gussett Assembly','','Mattress Border Type Trait is PT but BOM does not contains GUSSETT Segment','ERROR','BOM Item')
	END	

/* Border Assembly */
SELECT @intBACount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAT1AY'
IF @intBACount=0 
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Border Assembly','','BOM does not contains BORDER ASSEMBLY Segments (SAT1AY)','ERROR','BOM Item')
	END
ELSE IF @intBACount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAT1AY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Border Assembly',@SubAssmPartNo,'BOM contains BORDER ASSEMBLY Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateBA] @FGPartNo,@SubAssmPartNo,@BorderType
	END

/* Panel Quilter */
SELECT @intPQCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAQPAY'
SELECT @intnPQCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SANQPY'
SELECT @FGProperty	=PValue
FROM @tblFGBOMProp
WHERE PropertyID='PanelType'
IF @intPQCount=0 and @intnPQCount=0
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Panel Quilter','','BOM does not contains Quilted/non-Quilted Segments (SAQPAY/SANQPY)','ERROR','BOM Item')
	END
ELSE IF @intPQCount>0 
	BEGIN
		SELECT @SetPanelType='SAQPAY'
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAQPAY'	

		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Panel Quilter',@SubAssmPartNo,'BOM contains Quilted Panel Sub-Assembly','Information','BOM Item')
		IF @FGProperty<>'Quilt'
			BEGIN
				INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
					VALUES (@FGPartNo,'Panel Quilter',@SubAssmPartNo,'BOM contains Quilted Panel Sub-Assembly but Mattress Panel Type is not QUILT','ERROR','BOM Item')
			END
		ELSE
			BEGIN
				INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
					VALUES (@FGPartNo,'Panel Quilter',@SubAssmPartNo,'Mattress Panel Type matches with Quilted Panel Sub-Assembly ','Information','BOM Item')
			END
		EXEC [SSB].[dbo].[SSB_BOM_ValidatePQ] @FGPartNo,@SubAssmPartNo
	END
ELSE IF @intnPQCount>0
	BEGIN
		SELECT @SetPanelType='SANQPY'
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SANQPY'
		
		IF @FGProperty<>'non-Quilt'
			BEGIN
				INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
					VALUES (@FGPartNo,'Panel Quilter',@SubAssmPartNo,'BOM contains non-Quilted Panel Sub-Assembly but Mattress Panel Type is not non-QUILT','ERROR','BOM Item')
			END
		ELSE
			BEGIN
				INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
					VALUES (@FGPartNo,'Panel Quilter',@SubAssmPartNo,'Mattress Panel Type matches with non-Quilted Panel Sub-Assembly ','Information','BOM Item')
			END
		INSERT INTO [SSB].[dbo].SSB_MES_Log(FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'NonQuilt Panel',@SubAssmPartNo,'BOM contains non-Quilted Panel Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidatenPQ] @FGPartNo,@SubAssmPartNo
	END

/* Over-Caster */
SELECT @intPOCCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAQPOY'
IF @intPOCCount=0 
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'OverCast','','BOM does not contains OVERCAST Segments (SAQPOY)','ERROR','BOM Item')
	END
ELSE IF @intPOCCount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAQPOY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'OverCast',@SubAssmPartNo,'BOM contains OVERCAST Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidatePOC] @FGPartNo,@SubAssmPartNo,@SetPanelType
	END

/* Panel Assembly */
SELECT @intPACount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAT2AY'
IF @intPACount=0 
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Panel Assembly','','BOM does not contains PANEL ASSEMBLY Segments (SAT2AY)','ERROR','BOM Item')
	END
ELSE IF @intPACount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAT2AY'
		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Panel Assembly',@SubAssmPartNo,'BOM contains PANEL ASSEMBLY Sub-Assembly','Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidatePA] @FGPartNo,@SubAssmPartNo,@BorderType
	END

/* Closing Station */
SELECT @intCLSCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAMCLY'
IF @intCLSCount=0 
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Closing Station','','BOM does not contains CLOSING STATION Segments (SAMCLY)','ERROR','BOM Item')
	END
ELSE IF @intCLSCount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAMCLY'

		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Closing Station',@SubAssmPartNo,'BOM contains CLOSING STATION Sub-Assembly ' + @SubAssmPartNo,'Information','BOM Item')
		EXEC [SSB].[dbo].[SSB_BOM_ValidateCLS] @FGPartNo,@SubAssmPartNo
	END

/* Inspection Station */
SELECT @intINSCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAINSY'
IF @intINSCount=0 
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Inspection Station','','BOM does not contains INSPECTION STATION Segments (SAINSY)','ERROR','BOM Item')
	END
ELSE IF @intINSCount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAINSY'

		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Inspection Station',@SubAssmPartNo,'BOM contains  INSPECTION STATION Sub-Assembly ' + @SubAssmPartNo,'Information','BOM Item')
	END

/* Packaging Station */
SELECT @intPKGCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SAPKGY'
IF @intPKGCount=0 
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Film Packaging Station','','BOM does not contains FILM PACKAGING Segments (SAPKGY)','ERROR','BOM Item')
	END
ELSE IF @intPKGCount>0 
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SAPKGY'

		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Film Packaging Station',@SubAssmPartNo,'BOM contains  FILM PACKAGING Sub-Assembly ' + @SubAssmPartNo,'Information','BOM Item')
	END

/* Box Packaging Station */
SELECT @intBPKGCount=COUNT(PartNo)
FROM @tblFGBOMItems
WHERE ItemClass='SACBXY'
SELECT @FGProperty	=PValue
FROM @tblFGBOMProp
WHERE PropertyID='BoxPkg'
IF @intBPKGCount=0  and @FGProperty='Yes'
	BEGIN
		INSERT INTO [SSB].[dbo].SSB_MES_Log (	FGPartNo	,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Box Packaging Station','','BOM does not contains BOX PACKAGING Segments (SACBXY)','ERROR','BOM Item')
	END
ELSE IF @intBPKGCount>0 and @FGProperty='Yes'
	BEGIN
		SELECT @SubAssmPartNo=PartNo
		FROM @tblFGBOMItems
		WHERE ItemClass='SACBXY'

		INSERT INTO [SSB].[dbo].SSB_MES_Log(	FGPartNo ,SubAssembly	,SAPartNo	,LogDesc	,Catagory,IssueIn)
			VALUES (@FGPartNo,'Box Packaging Station',@SubAssmPartNo,'BOM contains BOX PACKAGING Sub-Assembly ' + @SubAssmPartNo,'Information','BOM Item')
	END

SELECT	RowID		,
		FGPartNo	,
		SubAssembly	,
		SAPartNo	,
		LogDesc		,
		Catagory
FROM [SSB].[dbo].SSB_MES_Log
ORDER BY RowID ASC

/*
SELECT @strnewID=NEWID()
SELECT @LogStatus=pk 
FROM  [AlarmManager].[dbo].[SSB_LogStatus]
WHERE StatusDescription='Open'


INSERT INTO  [AlarmManager].[dbo].[SSB_LogProdMgmt] 
	(
		[FGPartNo]			,
		[SubAssembly]		,
		[SAPartNo]			,
		[LogDesc]			,
		[Catagory]			,
		[IssueIn]			,
		[Status]			,
		[LogDateTime]		,
		[LoggedBy]			,
		[UpdatedDateTime]	,
		[ProdPK]
	)
	SELECT	FGPartNo			,
			SubAssembly			,
			SAPartNo			,
			LogDesc				,
			Catagory			,
			IssueIn				,
			@LogStatus			,
			GETDATE()			,
			'Production Management'	,
			GETDATE()			,
			@strnewID
	FROM [SSB].[dbo].SSB_MES_Log
	WHERE (Catagory='ERROR' OR Catagory='WARNING')
	ORDER BY RowID ASC

SELECT	*
FROM [SSB].[dbo].SSB_MES_Log
ORDER BY RowID ASC

*/
GO
