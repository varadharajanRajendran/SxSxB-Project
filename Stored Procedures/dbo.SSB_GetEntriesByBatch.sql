SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SSB_GetEntriesByBatch]
	@BatchID		nvarchar(50),
	@GroupProperty	nvarchar(50),
	@EquipmentID	nvarchar(50),
	@Statuses		XML
AS
BEGIN
	DECLARE @status nvarchar(50)
	/*EXEC sp_xml_preparedocument @status OUTPUT, @Statuses;*/
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		Entries.pom_entry_id [EntryID],
		Entries.pom_order_id [OrderID]
	FROM [SitMesDB].[dbo].[POMV_ORDR_PRP_VAL] as OrderPropVals
		INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] Entries on Entries.pom_order_id = OrderPropVals.pom_order_id
	WHERE
		OrderPropVals.pom_cf_value = @BatchID
		AND OrderPropVals.pom_custom_fld_name = @GroupProperty
		AND Entries.equip_long_name = @EquipmentID
		AND Entries.pom_entry_status_id IN (
			SELECT 
				XTbl.Items.value('.', 'varchar(50)')
			FROM @Statuses.nodes('/ArrayOfString/string') AS XTbl(Items)
		)
		ORDER BY Entries.pom_order_id
END

GO
