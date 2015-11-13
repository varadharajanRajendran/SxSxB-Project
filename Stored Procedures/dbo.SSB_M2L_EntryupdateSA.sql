SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_M2L_EntryupdateSA]
	@Entry	  nvarchar(20)
AS

/*
Purpose   : Update Entry produced sub-assembly for MES to Line Control Interface Data Preparation
Author    : Varadha R (Varadharajan.Rajendran@b-wi.com)
Revision  : Initial (July.22.2015)
*/
/*
DECLARE @SelField nvarchar(20),
		@Entry	  nvarchar(20)
*/

DECLARE @SQLStringCreateTable	varchar(8000),
		@SelField nvarchar(20)


BEGIN TRY
	SELECT @Selfield=CASE(@Entry)
						WHEN 'MU1' THEN 'MUSA'
						WHEN 'FEC1' THEN 'FECSA'
						WHEN 'PCA1' THEN 'PCASA'
					END
	SET @SQLStringCreateTable = 'UPDATE [SSB].[dbo].[MES2LC]
									SET [' + @Selfield + ']= CONVERT(nvarchar(50),	ml.def_id)
									FROM   [SSB].[dbo].MES2LC AS o 
											INNER JOIN  [SitMesDB].[dbo].[POM_Order] Po ON Po.Pom_order_id=o.Jobid
											INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON e.pom_order_pk =Po.pom_order_pk 
											INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
											INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
											INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
											LEFT OUTER JOIN [SitMesDB].[dbo].[MESUoMs] AS uoms1 ON ml.uom = uoms1.UomPK 
									 WHERE  ms.name='+ char(39) + 'PRODUCED'+ char(39) + ' 
											AND e.pom_entry_id like ' + char(39)  + '%.' + @Entry + char(39) 

	EXEC (@SQLStringCreateTable)
END TRY
BEGIN CATCH
	SELECT @@Error as 'ErrorCode'
	SELECT ERROR_MESSAGE() AS 'ErrorMessage'
END CATCH
GO
