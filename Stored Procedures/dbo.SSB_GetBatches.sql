SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SSB_GetBatches]
	-- Add the parameters for the stored procedure here
	@EquipmentID nvarchar(50),
	@GroupProperty nvarchar(50),
	@Statuses XML
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	SELECT
		OrderPropVals.pom_cf_value [BatchID]
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
		)
	GROUP BY OrderPropVals.pom_cf_value
	
	
END
GO
