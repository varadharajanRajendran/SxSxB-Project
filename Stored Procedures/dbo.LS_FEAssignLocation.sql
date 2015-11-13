SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[LS_FEAssignLocation]
	@ProdLine NVARCHAR(20)
AS

/*
Purpose   : Reset the exisitng location and create the new location  for FEC during BC download
Author    : Varadha R (Varadharajan.Rajendran@b-wi.com)
Revision  : Initial (Nov.11.2015)
*/
DECLARE	@tblPartList AS Table	(	RowId			int	IDENTITY	,
									PartNo			nvarchar(100)	,
									iCMLPrimary		nvarchar(50))
DECLARE @intStart			int				,
        @intEnd				int				,
		@PartNo				nvarchar(100)	,
		@iCMLPrimary		varbinary(200)  ,
		@iCMLPrimaryPK		int				,
		@DefVerPK			int				

declare @p10 int
INSERT INTO @tblPartList (PartNo,iCMLPrimary)
	SELECT PartNo,CMLPrimary
  FROM [SSB].[dbo].[SSB_FTLocations]
SELECT @intStart=Min(RowId),
        @intEnd=Max(RowId)
FROM @tblPartList


WHILE @intStart<=@intEnd 
BEGIN
	SELECT	@PartNo				=PartNo,
			@iCMLPrimary		=[Sitmesdb].dbo.MMfPropValToBin('',iCMLPrimary,'','')
	FROM @tblPartList
	WHERE 	RowId=@intStart
	SELECT @DefVerPK=MMDV.[DefVerPK]
	FROM [SitMesDB].[dbo].[MMDefinitions] MMD
		INNER JOIN [SitMesDB].[dbo].[MMDefVers] MMDV ON MMDV.DefPK=MMD.DefPK
	WHERE MMD.DefID=@PartNo
	
	BEGIN /*Update CML Primary Location Alias*/
		SELECT @iCMLPrimaryPK= [PropertyPK]
		FROM [SitMesDB].[dbo].[MMProperties]
		WHERE PropertyID=@ProdLine+'_FTPrimaryLocationAlias' 
		UPDATE [SitMesDB].[dbo].MMDefVerPrpVals SET
			PropValue = @iCMLPrimary,
			PropValChar = [SitMesDB].dbo.MMfGetPropValChar( @iCMLPrimary),
			PropValDec  = [SitMesDB].dbo.MMfGetPropValDec( @iCMLPrimary),
			PropValDate = [SitMesDB].dbo.MMfGetPropValDate(@iCMLPrimary),
			LastUser = [SitMesDB].[dbo].MMfCtxUser(),
			LastUpdate = [SitMesDB].[dbo].MMfCtxDate(),
			RowUpdated = GetUTCDate(),
			LocalInfo = [SitMesDB].[dbo].MMfBuildLocalInfo(LocalInfo),
			ContextID = [SitMesDB].[dbo].MMfCtxContextID()
		WHERE   DefVerPK = @DefVerPK
			AND    PropertyPK = @iCMLPrimaryPK
			AND    RowDeleted = Convert(bit, 0)
	END
	
	SELECT @intStart=@intStart+1
	
END
GO
