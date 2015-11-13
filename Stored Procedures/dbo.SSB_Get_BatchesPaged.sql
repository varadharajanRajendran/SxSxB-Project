SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SSB_Get_BatchesPaged]
	-- Add the parameters for the stored procedure here
	@Count int,
	@EquipmentID nvarchar(50),
	@GroupProperty nvarchar(50),
	@Statuses XML
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	CREATE TABLE #TempBatchData (
		[BatchID] varchar(MAX),
		[BatchCount] int,
		[FirstOrder] varchar(MAX),
		[Sequence] int
	)
	
	INSERT INTO #TempBatchData
	SELECT
		CONVERT(varchar(MAX), OrderPropVals.pom_cf_value) [BatchID],
		COUNT(Entries.pom_entry_id) [BatchCount],
		MIN(Orders.pom_order_id) [FirstOrder],
		/*ROW_NUMBER() OVER(PARTITION BY Entries.pom_order_id ORDER BY Entries.sequence ASC) as [FirstOrder],*/ 
		MIN(Entries.sequence) [Sequence]
	FROM [SitMesDB].[dbo].[POMV_ORDR] as Orders
		INNER JOIN [SitMesDB].[dbo].[POMV_ORDR_PRP] OrderProps on OrderProps.pom_order_id = Orders.pom_order_id
		INNER JOIN [SitMesDB].[dbo].[POMV_ORDR_PRP_VAL] OrderPropVals on OrderPropVals.pom_custom_field_rt_pk = OrderProps.pom_custom_field_rt_pk
		INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] Entries on Entries.pom_order_id = Orders.pom_order_id
		
		/*INNER JOIN (SELECT TOP 1 
			* FROM [SitMesDB].[dbo].[POMV_ETRY]
			ORDER BY [SitMesDB].[dbo].[POMV_ETRY].Sequence ASC) Entry on Entry.pom_order_id = Orders.pom_order_id*/
		/*
		INNER JOIN (SELECT TOP 1 
			[SitMesDB].[dbo].[POMV_ETRY].pom_order_id FROM [SitMesDB].[dbo].[POMV_ETRY] 
			ORDER BY [SitMesDB].[dbo].[POMV_ETRY].Sequence) [FirstOrder] on Entries.pom_order_id = Orders.pom_order_id*/
	WHERE
		Entries.equip_long_name = @EquipmentID
		AND OrderProps.pom_custom_fld_name = @GroupProperty
		AND Entries.pom_entry_status_id IN (
			SELECT 
				XTbl.Items.value('.', 'varchar(50)')
			FROM @Statuses.nodes('/ArrayOfString/string') AS XTbl(Items)
		)
	GROUP BY OrderPropVals.pom_cf_value
	ORDER BY [Sequence] ASC
	
	SELECT TOP (@Count)
		* 
	FROM #TempBatchData
	
	SELECT
		COUNT(*) [TotalOrderCount]
	FROM #TempBatchData
	/*SELECT 
		COUNT(Orders.pom_order_id) [OrderCount] 
	FROM [SitMesDB].[dbo].[POMV_ORDR] as Orders
		INNER JOIN [SitMesDB].[dbo].[POMV_ORDR_PRP] OrderProps on OrderProps.pom_order_id = Orders.pom_order_id
		INNER JOIN [SitMesDB].[dbo].[POMV_ORDR_PRP_VAL] OrderPropVals on OrderPropVals.pom_custom_field_rt_pk = OrderProps.pom_custom_field_rt_pk
		INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] Entries on Entries.pom_order_id = Orders.pom_order_id
	WHERE
		Entries.equip_long_name = @EquipmentID
		AND OrderProps.pom_custom_fld_name = @GroupProperty
		AND Entries.pom_entry_status_id IN (
			SELECT 
				XTbl.Items.value('.', 'varchar(50)')
			FROM @Statuses.nodes('/ArrayOfString/string') AS XTbl(Items)
		)*/
END
GO
