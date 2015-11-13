SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[PLC_GetStorgeInfo]
		@OrderID			NVARCHAR(20)	,
		@transactionType	nvarchar(20)	
 AS


/*  DECLARE @OrderID nvarchar(20)
SELECT @OrderID='888009964'   */
 

/*
DECLARE @OrderID nvarchar(20),
		@transactionType NVARCHAR(20)
SELECT @OrderID='133643285'   ,
		@transactionType='BC'
*/
DECLARE @tblMES2LCMap as Table(	RowId			int IDENTITY	,
								MESfnName		nvarchar(50)	,
								LCFnName		nvarchar(255)	,
								PLCDataType		nvarchar(50)	)
DECLARE @tblLCDataSet as Table(	RowId			int IDENTITY	,
								TagName			nvarchar(50)	,
								Value			nvarchar(20)	,
								DataType		nvarchar(50)	)
DECLARE @Temp	as Table (TagValue nvarchar(20)	)
DECLARE @OrderCount		int				,
		@MESFnName		nvarchar(20)	,
		@LCFnName		nvarchar(20)	,
		@StartRow		int				,
		@EndRow			int				,
		@MESValue		nvarchar(20)	,
		@PLCDataType	nvarchar(50)    ,
		@ProdLine		nvarchar(20)	
		
SELECT @ProdLine=REPLACE(E3.[equip_id],E4.[equip_id] + '.','')
FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] PeS On PeS.pom_entry_status_pk=Pe.pom_entry_status_pk
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po	ON	Po.pom_order_pk=Pe.pom_order_pk
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.pom_order_status_pk=Po.pom_order_status_pk
	INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E ON E.Equip_pk=Pe.Equip_Pk
	INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E2 ON E.[equip_prnt_pk]=E2.Equip_pk
	INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E3 ON E2.[equip_prnt_pk]=E3.Equip_pk
	INNER JOIN SitMesDB.dbo.BPM_EQUIPMENT E4 ON E3.[equip_prnt_pk]=E4.Equip_pk
WHERE Po.[pom_order_id]=@OrderID
	AND PoS.id in('PreProduction')
	AND PeS.id IN('Scheduled')			
	AND (Pe.pom_entry_id  like '%.SBCoil1'
		OR  Pe.pom_entry_id  like '%.PurchaseCoilAssem1%')
BEGIN 
	INSERT INTO @tblMES2LCMap ([MESFnName],[LCFnName],[PLCDataType])
		SELECT [MESFnName]
				,[LCFnName]
				,CASE ([PLCDataType])
					WHEN 'String'	THEN 'String'
					WHEN 'DateTime' THEN 'String'
					WHEN 'Boolean'	THEN 'Numeric'
					WHEN 'Char'		THEN 'Numeric'
					WHEN 'Float'	THEN 'Numeric'
					WHEN 'Integer'	THEN 'Numeric'
					WHEN 'Short'	THEN 'Numeric'
 				END
			FROM [SSB].[dbo].[MES2LCDataMap]
		WHERE [PLCSequence]>0 AND  [PLCSequence]<999
		AND LCFnName IN ('BFLOC' ,'L1Loc','L2Loc','L3Loc','L4Loc','L5Loc','L6Loc')
		ORDER BY [PLCSequence]	
	SELECT	@StartRow=MIN(RowID),
			@EndRow	=MAX(RowID)
	FROM @tblMES2LCMap
	WHILE @StartRow<=@EndRow
		BEGIN
			SELECT	@MESFnName	=MESFnName		,
					@LCFnName	=LCFnName		,
					@PLCDataType=PLCDataType
			FROM @tblMES2LCMap
			WHERE RowID=@StartRow
			IF @MESFnName<>'RowCount'
					BEGIN
						DELETE FROM @Temp
						INSERT INTO @Temp (TagValue)
							EXEC [dbo].[PLC_GetValuebyTag]
								@ColumnName = @LCFnName,
								@OrderID = @OrderID,
								@ProdLine=@ProdLine,
								@transactionType=@transactionType
						SELECT Top(1) @MESValue=TagValue FROM @Temp	
						INSERT INTO @tblLCDataSet (TagName,Value,DataType)
							VALUES(@LCFnName,@MESValue,@PLCDataType)					
					END	
				SELECT @StartRow=@StartRow+1
		END	
END
	BEGIN
		SELECT  TagName	, ISNULL(Value,0) as Value,DataType  FROM  @tblLCDataSet
	END
GO
