SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_BOM_GetQuiltData]
		@PartNo nvarchar(255)	
AS

DECLARE @tblItems as Table(	RowId			int IDENTITY	,
									itemClass		nvarchar(50)	,
									PartNo			nvarchar(255)	,
									[Description]	nvarchar(255)	)

DECLARE	@tblBOMProp AS Table	(	RowId			int	IDENTITY	,
									[PropertyID]	nvarchar(255)	,
									[PValue]		nvarchar(100)	,
									[DataType]		nvarchar(20)	)
DECLARE @intStart		int			,
		@intEnd			int			,
		@FillCount		int			,
		@selitemClass	nvarchar(50),
		@selPNo			nvarchar(50)
		/*,@PartNo		nvarchar(50)

SELECT @PartNo='QPAY-500070553-1050' */

INSERT INTO @tblItems (itemClass	,PartNo	,[Description])
	EXEC [SSB].[dbo].[SSB_BOM_GetItems]
		@PartNo = @PartNo

SELECT  @FillCount=1,
		@intStart=Min(RowId),
		@intEnd=Max(RowId)
FROM @tblItems

WHILE @intStart<=@intEnd
	BEGIN
		SELECT @selitemClass=itemClass,
				@selPNo	=PartNo	
		FROM @tblItems
		WHERE RowId=@intStart
		IF @selitemClass='RMBK'
			BEGIN
				INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
					VALUES('PROD_BackingID',@selPNo,'String')
			END
		ELSE IF @selitemClass='RMTK'
			BEGIN
				INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
					VALUES('PROD_TickingID',@selPNo,'String')
			END
		ELSE IF (@selitemClass='RMRF' or  @selitemClass='RMRP')
			BEGIN
				INSERT INTO @tblBOMProp([PropertyID],[PValue],[DataType])
					VALUES('PROD_Fill' + CONVERT(nvarchar(10),@FillCount) +'ID',@selPNo,'String')
				SELECT  @FillCount=@FillCount + 1
			END	
		SELECT @intStart=@intStart + 1
	END

	SELECT [PropertyID]	,[PValue],[DataType] FROM @tblBOMProp
GO
