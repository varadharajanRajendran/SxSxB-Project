SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PLC_UtilityGetEntryProperties]
	@ProdLine		nvarchar(10),
	@Entry			nvarchar(20),
	@SelField		nvarchar(20),
	@TransactionType nvarchar(5)
AS

/*
Purpose   : Update Entry Properties for MES to Line Control Interface Data Preparation
Author    : Varadha R (Varadharajan.Rajendran@b-wi.com)
Revision  : Initial (July.22.2015)
            11-06-2015 - Script modified to handle all PCL,HYL,CML and SPL Line
			             Script modified to handle BC and Dynamic Interface 
*/

DECLARE @SQLStringCreateTable	varchar(8000)	
BEGIN TRY
	SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[PLC_' + @TransactionType + '_' + @ProdLine + ']
									SET [' + @Selfield + ']= CONVERT(nvarchar(50),ocf_val.pom_cf_value)
									FROM [SSB].[dbo].[PLC_' + @TransactionType + '_' + @ProdLine + '] AS o 
										INNER JOIN [SitMesDB].[dbo].POM_Order AS Po ON Po.Pom_order_id=o.Jobid
										INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_Order_Pk
										INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
										INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
										INNER JOIN  [SSB].[dbo].[PLC_DataMap]  M2LM ON M2LM.[MESFnName]=ocf_rt.pom_custom_fld_name
									WHERE Pe.[pom_entry_id]=o.Jobid+'+ char(39) + '.' + @Entry + char(39) + ' AND [LCFnName]='  + char(39) +  @Selfield  + char(39)
	EXEC (@SQLStringCreateTable)
END TRY
BEGIN CATCH
	SELECT @@Error as 'ErrorCode'
	SELECT ERROR_MESSAGE() AS 'ErrorMessage'
END CATCH
GO
