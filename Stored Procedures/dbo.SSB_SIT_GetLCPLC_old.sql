SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[SSB_SIT_GetLCPLC_old]
		@OrderID	nvarchar(20)		
 AS


/*  DECLARE @OrderID nvarchar(20) */

DECLARE @tblMES2LCMap as Table(	RowId			int IDENTITY	,
								MESfnName		nvarchar(50)	,
								LCFnName		nvarchar(255)	)

DECLARE @tblLCDataSet as Table(	RowId			int IDENTITY	,
								TagName			nvarchar(50)	,
								Value			nvarchar(20)	)

DECLARE @Temp	as Table (TagValue nvarchar(20)	)

DECLARE @OrderCount	int,
		@MESFnName	nvarchar(20)	,
		@LCFnName	nvarchar(20)	,
		@StartRow	int				,
		@EndRow		int				,
		@MESValue	nvarchar(20)
 
/* SELECT @OrderID='122507703' */
 
 SELECT @OrderCount=COUNT([Rowid])
 FROM [SSB].[dbo].[MES2LC]
 WHERE Job_ID=@OrderID
 
 IF @OrderCount<=0
	BEGIN
		EXEC [SSB].[dbo].[SSB_Update_tblMES2LC_new]
	END
 
 
 SELECT @OrderCount=COUNT([Rowid])
 FROM [SSB].[dbo].[MES2LC]
 WHERE Job_ID=@OrderID
 IF @OrderCount>0
    BEGIN 
		INSERT INTO @tblMES2LCMap ([MESFnName],[LCFnName])
			SELECT [MESFnName]
				  ,[LCFnName]
			  FROM [SSB].[dbo].[MES2LCDataMap]
			WHERE [PLCSequence]>0
			ORDER BY [PLCSequence]
		SELECT	@StartRow=MIN(RowID),
				@EndRow	=MAX(RowID)
		FROM @tblMES2LCMap
		WHILE @StartRow<=@EndRow
			BEGIN
				SELECT	@MESFnName=MESFnName,
						@LCFnName=LCFnName
				FROM @tblMES2LCMap
				WHERE RowID=@StartRow
				IF @MESFnName<>'RowCount'
					/*
					BEGIN
						INSERT INTO @tblLCDataSet (TagName,Value)
							SELECT @LCFnName,[RowCount] FROM [SSB].[dbo].[MES2LC] WHERE [Job_ID] = + @OrderID
					END	
						ELSE
					*/
					BEGIN
						DELETE FROM @Temp
						INSERT INTO @Temp (TagValue)
							EXEC [dbo].[SSB_GetPLCValue]
								@ColumnName = @LCFnName,
								@OrderID = @OrderID
						SELECT Top(1) @MESValue=TagValue FROM @Temp	
						INSERT INTO @tblLCDataSet (TagName,Value)
							VALUES(@LCFnName,@MESValue)					
					END	
				SELECT @StartRow=@StartRow+1
			END	
	END

SELECT  TagName	, ISNULL(Value,0) as Value FROM  @tblLCDataSet
GO
