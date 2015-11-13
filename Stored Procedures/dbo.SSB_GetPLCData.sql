SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_GetPLCData]
	@Interface nvarchar(10)
AS

/*
Purpose   : Get PLC Data for Open Orders
Author    : Varadha R (Varadharajan.Rajendran@b-wi.com)
Revision  : Initial (July.24.2015)
*/
/*
DECLARE @Interface nvarchar(10)
SELECT  @Interface		= 'PLC'
*/

DECLARE @FieldList as Table ( RowId				int IDENTITY  ,
							  FieldName			nvarchar(50)  ,
							  Findstr			nvarchar(20)  ,
							  ReplaceStr		nvarchar(20)  ,
							  TypeConversion	nvarchar(20)  ,
							  OrderBySeq		int			  ,
							  UniqueID			int		      )
DECLARE  @StartRow				int				 ,
		 @EndRow				int				 ,
		 @OrderBySeq			int			  	 ,
		 @SelField				varchar(50)		 ,
		 @Findstr				varchar(50)		 ,
		 @ReplaceStr			varchar(50)		 ,
		 @TypeConversion		varchar(50)		 ,
		 @intField				varchar(100)	 ,
		 @AllFields			    varchar(5000)	 ,
		 @SQLStringDynamicQuery varchar(8000)	 
SELECT @AllFields		=''		,	
	    @SelField		=''		,
	    @Findstr		=''		,
	    @ReplaceStr		=''		,
		@TypeConversion =''     ,
		@OrderBySeq	=''


BEGIN TRY
	IF @Interface = 'PLC'
		BEGIN
			INSERT INTO @FieldList (FieldName,Findstr,ReplaceStr,TypeConversion,OrderBySeq,UniqueID	)
				SELECT [LCFnName]
				  ,[FindString]
				  ,[ReplaceString]
				  ,[TypeConversion]
				  ,[OrderBySeq]
				  ,[UniqueID]
				FROM [SSB].[dbo].[MES2LCDataMap]
				WHERE [PLCSequence] is NOT NULL
				ORDER BY [PLCSequence] ASC
		END
	ELSE IF @Interface = 'Report'
		BEGIN
			INSERT INTO @FieldList (FieldName,Findstr,ReplaceStr,TypeConversion,OrderBySeq,UniqueID	)
				SELECT [LCFnName]
					  ,[FindString]
					  ,[ReplaceString]
					  ,[TypeConversion]
					  ,[OrderBySeq]
					  ,[UniqueID]
				  FROM [SSB].[dbo].[MES2LCDataMap]
				  WHERE [ReportSequence] is NOT NULL
				  ORDER BY [ReportSequence] ASC
		END
	SELECT @StartRow	= MIN(RowID) ,
		   @EndRow      = MAX(RowID)
	FROM @FieldList
	WHILE @StartRow <=@EndRow
	BEGIN
		SELECT @SelField		= FieldName			,
			   @Findstr			= Findstr			,
			   @ReplaceStr		= ReplaceStr		,
			   @TypeConversion	= TypeConversion	,
			   @OrderBySeq	= OrderBySeq
		FROM @FieldList
		WHERE RowID=@StartRow	
		IF @Findstr is NULL
			BEGIN
				SELECT @intField='ISNULL([' + @SelField +  '],' + char(39) + @ReplaceStr + char(39) + ')'
			END
		ELSE IF @Findstr<>''
			BEGIN
				SELECT @intField='REPLACE([' + @SelField + '],' + char(39) + @Findstr + char(39) + ',' + char(39) +@ReplaceStr + char(39) + ')'
			END 
		ELSE
			BEGIN
				SELECT @intField= @SelField
			END 	
		IF @TypeConversion ='int'
			BEGIN
				SELECT @intField='CONVERT(int, ROUND('  + @intField + ',5,3))'
			END
		ELSE IF @TypeConversion <>''
			BEGIN
				SELECT @intField='CONVERT(' + @TypeConversion + ',' + @intField + ')'
			END
		IF @SelField ='FECType'
			BEGIN
				SELECT @intField= CHAR(39) + @SelField + CHAR(39) + ' as FECType'
			END
		ELSE IF @SelField='SNo'
			BEGIN
				SELECT @intField='ROW_NUMBER() OVER (ORDER BY [EstTime]) AS [' + @SelField + ']'
			END
		ELSE
			BEGIN
				IF @intField=@SelField
					BEGIN
						SELECT @intField= '[' + @SelField + '] as '  + @SelField
					END
				ELSE
				BEGIN
					SELECT @intField= @intField +  ' as ' + @SelField
				END
			END
		IF @SelField is NOT NULL
		BEGIN
			SELECT @AllFields=@AllFields + ',' + @intField	
		END
		SELECT @StartRow=@StartRow + 1
END

SET @SQLStringDynamicQuery = 'SELECT ' + SUBSTRING(@AllFields,2,LEN(@AllFields)-1) + ' FROM [SSB].[dbo].[MES2LC]  ORDER BY [EstTime] ASC' 
EXEC (@SQLStringDynamicQuery)
END TRY
BEGIN CATCH
	SELECT @@Error as 'ErrorCode'
	SELECT ERROR_MESSAGE() AS 'ErrorMessage'
END CATCH
	
GO
