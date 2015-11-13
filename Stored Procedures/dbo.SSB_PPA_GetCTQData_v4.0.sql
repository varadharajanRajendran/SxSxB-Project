SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_PPA_GetCTQData_v4.0]
		@EntryID	nvarchar(255)	
AS

DECLARE @intStartRow	int				,
        @intEndRow		int				,
        @CTQDescription	nvarchar(255)	,
		@DataType		nvarchar(50)	,
		@Actual			nvarchar(50)	,
		@LTL			nvarchar(50)	,
		@LPCL			nvarchar(50)	,
		@Target			nvarchar(50)	,
		@UPCL			nvarchar(50)	,
		@UTL			nvarchar(50)	,
		@VLD			nvarchar(50)	,
        @Mandatory		bit				
        
DECLARE	@tblCTQData AS Table	(	RowId			int	IDENTITY	,
									CTQDescription	nvarchar(255)	,
									DataType		nvarchar(50)	,
									Actual			nvarchar(50)	,
									LTL				nvarchar(50)	,
									LPCL			nvarchar(50)	,
									[Target]		nvarchar(50)	,
									UPCL			nvarchar(50)	,
									UTL				nvarchar(50)	,
									VLD				nvarchar(50)	,
									Mandatory		bit				)
									
DECLARE	@tblPPAData AS Table	(	RowId		int	IDENTITY	,
									RTDSTag		nvarchar(100)	,
									Value		nvarchar(50)	,
									[DataType]	nvarchar(255)	)

								
INSERT INTO @tblCTQDAta	(CTQDescription,DataType,Actual,LTL	,LPCL,[Target],UPCL,UTL, VLD,Mandatory	)  
	SELECT DISTINCT REPLACE(PS.[name],'QUALITY_','')
		  ,PS.[type]
		  ,ISNULL(NULLIF(PS.[value],' '), '0')
		  ,ISNULL(NULLIF(CONVERT(float, PS.[LOW_MIN])+CONVERT(float, PS.[default_val]),' '), '0') 
		  ,ISNULL(NULLIF(CONVERT(float, PS.[min_val])+CONVERT(float, PS.[default_val]),' '), '0') 
		  ,ISNULL(NULLIF(PS.[default_val],' '), '0')
		  ,ISNULL(NULLIF(CONVERT(float, PS.[max_val])+CONVERT(float, PS.[default_val]),' '), '0') 
		  ,ISNULL(NULLIF(CONVERT(float, PS.[HIGH_MAX])+CONVERT(float, PS.[default_val]),' '), '0') 
		  ,PS.[VLD]
		  ,PM.Param_Mandatory
	  FROM [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER] PS
	   INNER JOIN [SitMesDB].[dbo].[POM_ENTRY]PE on PE.pom_entry_pk=PS.pom_entry_pk
	   INNER JOIN  [SitMesDB].[dbo]. PDefM_PS_Param PM on PM.Param_Name= PS.[name]
	  Where PE.pom_entry_id like  @EntryID +'%'
	   AND PS.[name] like 'QUALITY_%'
	   AND PS.[name] <> 'QUALITY_LogStatus'
	   AND PM.PARAM_PPR='SSB_CML'
	   AND PM.Param_PPRVersion='0001.00'

SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@tblCTQDAta

    
/* Get Item Description */
WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT	@CTQDescription	=	[CTQDescription]	,
			@DataType		=	[DataType]			,
			@Actual			=	[Actual]			,
			@LTL			=	LTL					,
			@LPCL			=	LPCL				,
			@Target			=	[Target]			,
			@UPCL			=	UPCL				,
			@UTL			=	UTL					,
			@VLD			=	VLD					,
			@Mandatory		=	Mandatory	
	FROM @tblCTQDAta	
	WHERE RowId=@intStartRow
	
	IF  @Mandatory='0'
		BEGIN
			IF @DataType='TRUTH-VALUE'
				BEGIN
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'FLD','False' ,'Boolean'
				END
			ELSE IF @DataType='FLOAT'
				BEGIN
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'ACT','0' ,'Numeric'
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'TGT','0' ,'Numeric'	
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'LTL','0' ,'Numeric'
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'LPCL','0' ,'Numeric'
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'UPCL','0' ,'Numeric'	
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'UTL','0' ,'Numeric'					
				END
		END
	ELSE IF  @Mandatory='1'
		BEGIN
			IF @DataType='TRUTH-VALUE'
				BEGIN
					IF (UPPER(@Actual) = 'TRUE' OR UPPER(@Actual) = '1')
						BEGIN
							INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
							SELECT 	@CTQDescription +'FLD','False' ,'Boolean'
						END
					ELSE
						BEGIN
							INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
							SELECT 	@CTQDescription +'FLD','True' ,'Boolean'
						END
				END
			ELSE IF @DataType='FLOAT'
				BEGIN
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'ACT',@Actual ,'Numeric'
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'TGT',@Target ,'Numeric'	
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'LTL',@LTL ,'Numeric'
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'LPCL',@LPCL,'Numeric'
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'UPCL',@UPCL ,'Numeric'	
					
					INSERT INTO @tblPPAData (RTDSTag ,	Value , [DataType])
						SELECT 	@CTQDescription +'UTL',@UTL ,'Numeric'					
				END
		END
	SELECT @intStartRow = @intStartRow + 1
END

SELECT * FROM @tblPPAData	
GO
